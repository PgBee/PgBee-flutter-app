import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class HttpInterceptor {
  static const String _baseUrl = 'https://server.pgbee.in';
  
  /// Enhanced HTTP request with automatic JWT + Cookie handling
  static Future<http.Response> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool includeAuth = true,
  }) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    
    // Base headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add additional headers if provided
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    // Add authentication if required
    if (includeAuth) {
      await _addAuthHeaders(headers);
    }
    
    print('HttpInterceptor: Making $method request to $endpoint');
    print('HttpInterceptor: Headers: $headers');
    
    // Make the request
    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            url, 
            headers: headers, 
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url, 
            headers: headers, 
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            url, 
            headers: headers, 
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
      
      print('HttpInterceptor: Response status: ${response.statusCode}');
      print('HttpInterceptor: Response body: ${response.body}');
      
      // Save cookies from successful responses
      AuthService.saveCookies(response);
      
      // Handle 401 errors with token refresh
      if (response.statusCode == 401 && includeAuth) {
        print('HttpInterceptor: Got 401, checking if we should retry with cookies only...');
        
        // For cookie-based authentication, try the request again with only cookies
        if (AuthService.storedCookies != null && AuthService.storedCookies!.isNotEmpty) {
          print('HttpInterceptor: Retrying request with cookies only (no Authorization header)');
          
          // Remove Authorization header and retry with only cookies
          final cookieOnlyHeaders = Map<String, String>.from(headers);
          cookieOnlyHeaders.remove('Authorization');
          cookieOnlyHeaders['Cookie'] = AuthService.storedCookies!;
          
          // Retry the request with cookies only
          http.Response cookieResponse;
          switch (method.toUpperCase()) {
            case 'GET':
              cookieResponse = await http.get(url, headers: cookieOnlyHeaders);
              break;
            case 'POST':
              cookieResponse = await http.post(
                url, 
                headers: cookieOnlyHeaders, 
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'PUT':
              cookieResponse = await http.put(
                url, 
                headers: cookieOnlyHeaders, 
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'PATCH':
              cookieResponse = await http.patch(
                url, 
                headers: cookieOnlyHeaders, 
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'DELETE':
              cookieResponse = await http.delete(url, headers: cookieOnlyHeaders);
              break;
            default:
              throw ArgumentError('Unsupported HTTP method: $method');
          }
          
          // If cookie-only request succeeds, update our stored token and return success
          if (cookieResponse.statusCode == 200 || cookieResponse.statusCode == 201) {
            print('HttpInterceptor: Cookie-only request succeeded');
            AuthService.saveCookies(cookieResponse);
            return cookieResponse;
          }
        }
        
        // If cookie-only didn't work, try token refresh
        print('HttpInterceptor: Cookie-only failed, attempting token refresh...');
        
        final refreshed = await _refreshTokenAndRetry();
        if (refreshed) {
          print('HttpInterceptor: Token refreshed, retrying request...');
          
          // Update auth headers with new token
          await _addAuthHeaders(headers);
          
          // Retry the request
          switch (method.toUpperCase()) {
            case 'GET':
              response = await http.get(url, headers: headers);
              break;
            case 'POST':
              response = await http.post(
                url, 
                headers: headers, 
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'PUT':
              response = await http.put(
                url, 
                headers: headers, 
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'PATCH':
              response = await http.patch(
                url, 
                headers: headers, 
                body: body != null ? jsonEncode(body) : null,
              );
              break;
            case 'DELETE':
              response = await http.delete(url, headers: headers);
              break;
          }
          
          print('HttpInterceptor: Retry response status: ${response.statusCode}');
          
          // Save cookies from retry response
          AuthService.saveCookies(response);
        }
      }
      
      return response;
      
    } catch (e) {
      print('HttpInterceptor: Request failed with error: $e');
      rethrow;
    }
  }
  
  /// Add authentication headers (JWT token + cookies)
  static Future<void> _addAuthHeaders(Map<String, String> headers) async {
    try {
      // Add JWT token if available
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      if (accessToken != null && accessToken.isNotEmpty) {
        if (accessToken == 'cookie-session-active') {
          print('HttpInterceptor: Using cookie-only authentication');
        } else {
          headers['Authorization'] = 'Bearer $accessToken';
          print('HttpInterceptor: Added JWT token to headers');
        }
      }
      
      // Add cookies if available
      if (AuthService.storedCookies != null) {
        headers['Cookie'] = AuthService.storedCookies!;
        print('HttpInterceptor: Added cookies to headers');
      }
    } catch (e) {
      print('HttpInterceptor: Error adding auth headers: $e');
    }
  }
  
  /// Attempt to refresh token and return success status
  static Future<bool> _refreshTokenAndRetry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null || refreshToken.isEmpty) {
        print('HttpInterceptor: No refresh token available');
        return false;
      }
      
      // Don't attempt refresh for cookie-based sessions
      if (refreshToken == 'cookie-session-active') {
        print('HttpInterceptor: Cookie-based session - relying on cookies for auth');
        return false; // Let the 401 error propagate for cookie sessions
      }
      
      // Don't attempt refresh if refresh token is same as access token (backend doesn't support refresh)
      final storedAccessToken = prefs.getString('access_token');
      if (refreshToken == storedAccessToken) {
        print('HttpInterceptor: Refresh token same as access token - backend does not support refresh, switch to cookie auth');
        return false; // Don't try to refresh, let it handle via cookies
      }
      
      // For single-token backends (where refresh token = access token), 
      // try a simple token validation/refresh endpoint instead
      final currentAccessToken = prefs.getString('access_token');
      if (refreshToken == currentAccessToken) {
        print('HttpInterceptor: Single-token backend detected, trying cookie-based refresh');
        
        // For backends that use cookies + JWT, try refreshing with current cookies
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/token/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': AuthService.storedCookies ?? '',
          },
          body: jsonEncode({}), // Empty body for cookie-based refresh
        );
        
        if (response.statusCode == 200) {
          final refreshData = jsonDecode(response.body);
          final newAccessToken = refreshData['accessToken'] ?? refreshData['data']?['accessToken'];
          
          if (newAccessToken != null) {
            await prefs.setString('access_token', newAccessToken);
            await prefs.setString('refresh_token', newAccessToken); // Keep them the same
            AuthService.saveCookies(response);
            print('HttpInterceptor: Cookie-based token refresh successful');
            return true;
          }
        }
        
        print('HttpInterceptor: Cookie-based refresh failed, falling back to standard refresh');
      }
      
      // Call standard refresh endpoint
      final refreshResponse = await http.post(
        Uri.parse('$_baseUrl/auth/token/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': AuthService.storedCookies ?? '', // Include cookies as well
        },
        body: jsonEncode({
          'refreshToken': refreshToken,  // Try standard field name
          'refresh_token': refreshToken, // Alternative field name
        }),
      );
      
      if (refreshResponse.statusCode == 200) {
        final refreshData = jsonDecode(refreshResponse.body);
        final newAccessToken = refreshData['accessToken'];
        final newRefreshToken = refreshData['refreshToken'];
        
        if (newAccessToken != null) {
          // Save new tokens
          await prefs.setString('access_token', newAccessToken);
          if (newRefreshToken != null) {
            await prefs.setString('refresh_token', newRefreshToken);
          }
          
          // Save cookies from refresh response
          AuthService.saveCookies(refreshResponse);
          
          print('HttpInterceptor: Token refresh successful');
          return true;
        }
      }
      
      print('HttpInterceptor: Token refresh failed with status: ${refreshResponse.statusCode}');
      return false;
      
    } catch (e) {
      print('HttpInterceptor: Token refresh error: $e');
      return false;
    }
  }
  
  /// Convenience methods for different HTTP verbs
  static Future<http.Response> get(String endpoint, {Map<String, String>? headers, bool includeAuth = true}) {
    return request(method: 'GET', endpoint: endpoint, additionalHeaders: headers, includeAuth: includeAuth);
  }
  
  static Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers, bool includeAuth = true}) {
    return request(method: 'POST', endpoint: endpoint, body: body, additionalHeaders: headers, includeAuth: includeAuth);
  }
  
  static Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers, bool includeAuth = true}) {
    return request(method: 'PUT', endpoint: endpoint, body: body, additionalHeaders: headers, includeAuth: includeAuth);
  }
  
  static Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers, bool includeAuth = true}) {
    return request(method: 'PATCH', endpoint: endpoint, body: body, additionalHeaders: headers, includeAuth: includeAuth);
  }
  
  static Future<http.Response> delete(String endpoint, {Map<String, String>? headers, bool includeAuth = true}) {
    return request(method: 'DELETE', endpoint: endpoint, additionalHeaders: headers, includeAuth: includeAuth);
  }
}
