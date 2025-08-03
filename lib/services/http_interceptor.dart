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
      
      // Simple 401 handling - just return the response like simple_role_test.dart
      // Let the calling service handle 401 errors appropriately
      // Don't do complex retry logic that interferes with Bearer token auth
      if (response.statusCode == 401) {
        print('HttpInterceptor: Got 401 Unauthorized - letting service handle it');
      }
      
      return response;
      
    } catch (e) {
      print('HttpInterceptor: Request failed with error: $e');
      rethrow;
    }
  }
  
  /// Add authentication headers (JWT Bearer token only - like simple_role_test.dart)
  static Future<void> _addAuthHeaders(Map<String, String> headers) async {
    try {
      // Always use Bearer token like the simple_role_test.dart that works
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      if (accessToken != null && accessToken.isNotEmpty && accessToken != 'cookie-session-active') {
        // Always add Bearer token exactly like simple_role_test.dart
        headers['Authorization'] = 'Bearer $accessToken';
        print('HttpInterceptor: Added JWT Bearer token to headers (${accessToken.length} chars)');
      } else {
        print('HttpInterceptor: No valid access token available for Bearer auth');
      }
      
      // Don't use cookies - the test script works without them, so we should too
      // The simple_role_test.dart proves that Bearer token alone works perfectly
    } catch (e) {
      print('HttpInterceptor: Error adding auth headers: $e');
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
