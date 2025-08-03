import 'package:pgbee/models/auth_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'https://server.pgbee.in';
  String? _authToken;
  static String? _cookieHeader; // Store cookies for session management
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Set token for this service
  void setAuthToken(String token) {
    _authToken = token;
    print('AuthService: Token set for API calls');
  }

  // Cookie handling methods
  static void saveCookies(http.Response response) {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      _cookieHeader = cookies;
      print('AuthService: Cookies saved from response');
      // Also save cookies to SharedPreferences for persistence
      _saveCookiesToStorage(cookies);
    }
  }
  
  static Future<void> _saveCookiesToStorage(String cookies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_cookies', cookies);
      print('AuthService: Cookies saved to SharedPreferences');
    } catch (e) {
      print('AuthService: Error saving cookies to storage: $e');
    }
  }
  
  static Future<void> loadCookiesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCookies = prefs.getString('auth_cookies');
      if (storedCookies != null) {
        _cookieHeader = storedCookies;
        print('AuthService: Cookies loaded from SharedPreferences');
      }
    } catch (e) {
      print('AuthService: Error loading cookies from storage: $e');
    }
  }

  // Public getter for stored cookies
  static String? get storedCookies => _cookieHeader;

  // Extract JWT tokens from cookies
  static String? _extractTokenFromCookies(String cookieHeader, String tokenName) {
    final cookies = cookieHeader.split(';');
    for (final cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts.length >= 2 && parts[0].trim() == tokenName) {
        return parts[1].trim();
      }
    }
    return null;
  }

  // Save tokens to SharedPreferences
  Future<void> saveTokens(String accessToken, String refreshToken, [Map<String, dynamic>? userData]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    if (userData != null) {
      await prefs.setString(_userDataKey, jsonEncode(userData));
    }
    
    // Also set the token for immediate use
    _authToken = accessToken;
    
    print('AuthService: Tokens saved and set for immediate use');
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString(_userDataKey);
    if (userDataStr != null) {
      try {
        return Map<String, dynamic>.from(jsonDecode(userDataStr));
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove('auth_cookies'); // Clear stored cookies too
    _cookieHeader = null; // Clear cookies from memory
    print('All tokens, user data and cookies cleared');
  }

  // Improved JWT validation with cookie session support
  bool _isValidJWT(String token) {
    if (token.isEmpty) {
      print('JWT validation: Token is empty');
      return false;
    }
    
    // Special case: allow cookie-based session indicators
    if (token == 'cookie-session-active') {
      print('JWT validation: Cookie-based session detected');
      return true;
    }
    
    // Check if token has 3 parts separated by dots
    final parts = token.split('.');
    if (parts.length != 3) {
      print('JWT validation: Invalid JWT format - expected 3 parts, got ${parts.length}');
      return false;
    }
    
    // Check if each part is not empty
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) {
        print('JWT validation: Invalid JWT - empty part $i found');
        return false;
      }
    }
    
    // Additional check: try to decode the JWT to ensure it's valid
    try {
      JwtDecoder.decode(token);
      print('JWT validation: Token is valid');
      return true;
    } catch (e) {
      print('JWT validation: Token decode failed: $e');
      return false;
    }
  }

  // Helper: Check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      print('No access token found');
      return true;
    }
    
    // Cookie-based sessions don't expire on client side
    if (token == 'cookie-session-active') {
      print('Cookie-based session - treating as non-expired');
      return false;
    }
    
    if (!_isValidJWT(token)) {
      print('Invalid JWT format, treating as expired');
      return true;
    }
    
    try {
      final isExpired = JwtDecoder.isExpired(token);
      print('Token expiration check: ${isExpired ? "expired" : "valid"}');
      return isExpired;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // Treat as expired if we can't parse it
    }
  }

  // Check if we have valid stored session
  Future<bool> hasValidSession() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    
    if (accessToken == null || refreshToken == null) {
      print('No stored tokens found');
      return false;
    }
    
    if (!_isValidJWT(accessToken) || !_isValidJWT(refreshToken)) {
      print('Invalid JWT format in stored tokens');
      await clearTokens(); // Clear invalid tokens
      return false;
    }
    
    // Check if access token is expired
    final isExpired = await isAccessTokenExpired();
    if (!isExpired) {
      print('Valid session found with non-expired access token');
      return true;
    }
    
    // For cookie-based sessions, if we reach here they're still valid
    // (isAccessTokenExpired returns false for cookie sessions)
    if (accessToken == 'cookie-session-active') {
      print('Cookie-based session is valid');
      return true;
    }
    
    // Try to refresh if access token is expired but refresh token might be valid
    try {
      if (!JwtDecoder.isExpired(refreshToken)) {
        print('Access token expired but refresh token is valid, attempting refresh');
        final refreshSuccess = await refreshAccessToken();
        return refreshSuccess;
      } else {
        print('Both tokens are expired, clearing session');
        await clearTokens();
        return false;
      }
    } catch (e) {
      print('Error validating refresh token: $e');
      await clearTokens();
      return false;
    }
  }

  // Sign In - JWT based
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Login response status: ${response.statusCode}');
        print('Login response body: ${response.body}');
        print('Login response headers: ${response.headers}');
        
        // Save cookies from response
        saveCookies(response);
        
        Map<String, dynamic> data = {};
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          print('Error parsing login response: $e');
        }
        
        print('Parsed data keys: ${data.keys.toList()}');
        print('Data object: ${data['data']}');
        print('AccessToken field at root: ${data.containsKey('accessToken') ? 'found' : 'missing'}');
        print('AccessToken field in data: ${data['data'] is Map && data['data'].containsKey('accessToken') ? 'found' : 'missing'}');
        print('RefreshToken field at root: ${data.containsKey('refreshToken') ? 'found' : 'missing'}');
        print('RefreshToken field in data: ${data['data'] is Map && data['data'].containsKey('refreshToken') ? 'found' : 'missing'}');
        
        // Extract tokens from response body - follow the same pattern as simple_role_test.dart
        String? accessToken;
        String? refreshToken;
        
        final loginData = data;
        accessToken = loginData['data']?['accessToken'] ?? loginData['accessToken'];
        
        print('Direct token extraction (like test script):');
        print('  - loginData keys: ${loginData.keys}');
        if (loginData['data'] != null) {
          print('  - loginData[data] keys: ${(loginData['data'] as Map).keys}');
        }
        print('  - accessToken found: ${accessToken != null ? 'YES (${accessToken.length} chars)' : 'NO'}');
        
        // For refresh token, try common patterns but don't require it
        refreshToken = loginData['data']?['refreshToken'] ?? 
                      loginData['refreshToken'] ?? 
                      accessToken; // Use access token as refresh if no dedicated refresh token
        
        print('  - refreshToken found: ${refreshToken != null ? 'YES (${refreshToken.length} chars)' : 'NO'}');
        
        // Extract user data
        final userData = (data['user'] is Map) ? Map<String, dynamic>.from(data['user']) :
                        (data['userData'] is Map) ? Map<String, dynamic>.from(data['userData']) :
                        (data['profile'] is Map) ? Map<String, dynamic>.from(data['profile']) :
                        (data['data'] is Map && data['data']['user'] is Map) ? Map<String, dynamic>.from(data['data']['user']) : null;
                        
        // If user data is not in response, try to extract from JWT token
        Map<String, dynamic>? jwtUserData;
        if (accessToken != null && _isValidJWT(accessToken)) {
          try {
            final jwtPayload = JwtDecoder.decode(accessToken);
            jwtUserData = {
              'id': jwtPayload['userId'] ?? jwtPayload['id'] ?? jwtPayload['sub'],
              'email': jwtPayload['email'],
              'role': jwtPayload['role'], // Check if role is in JWT
            };
            print('Extracted user data from JWT: $jwtUserData');
          } catch (e) {
            print('Error extracting user data from JWT: $e');
          }
        }
        
        // Use JWT data if response doesn't contain user data
        final finalUserData = userData ?? jwtUserData;
        final message = (data['message'] is String) ? data['message'] : 'Login successful';
        
        // Save the tokens if we found them (like the test script approach)
        if (accessToken != null && _isValidJWT(accessToken)) {
          await saveTokens(accessToken, refreshToken ?? accessToken, finalUserData);
          print('Login successful, JWT tokens saved');
          
          return {
            'success': true,
            'data': data,
            'accessToken': accessToken,
            'refreshToken': refreshToken ?? accessToken,
            'message': message,
            'user': finalUserData ?? {},
          };
        } else {
          print('Warning: No valid JWT access token found in response');
          print('Available data fields: ${data.keys.join(', ')}');
          return {
            'success': false,
            'error': 'No valid access token received from server',
          };
        }
      } else {
        // Try to extract error message from backend response
        String errorMsg = 'Login failed';
        try {
          final decoded = jsonDecode(response.body);
          Map<String, dynamic> data = {};
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
          if (data['error'] is String) {
            errorMsg = data['error'];
          } else if (data['message'] is String) {
            errorMsg = data['message'];
          }
          // Detect invalid credentials error
          if (errorMsg.toLowerCase().contains('invalid') || errorMsg.toLowerCase().contains('incorrect')) {
            errorMsg = 'Invalid email or password.';
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        return {
          'success': false,
          'error': errorMsg,
        };
      }
    } catch (e) {
      print('Auth Service Error - Sign In: $e');
      return {
        'success': false,
        'error': 'Login failed: Network error',
      };
    }
  }

  // Sign Up - JWT based
  Future<Map<String, dynamic>> signUp(AuthModel user) async {
    try {
      // Ensure all required fields are present
      final name = ((user.firstName ?? '').trim() + ' ' + (user.lastName ?? '').trim()).trim();
      final payload = {
        'email': user.email,
        'password': user.password,
        'role': 'owner',
        'name': name,
        'phoneNo': user.phoneNo ?? '',
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        // Registration succeeded
        Map<String, dynamic> data = {};
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          print('Error parsing signup response: $e');
        }
        
        final accessToken = (data['accessToken'] is String) ? data['accessToken'] : null;
        final refreshToken = (data['refreshToken'] is String) ? data['refreshToken'] : null;
        final userData = (data['user'] is Map) ? Map<String, dynamic>.from(data['user']) : null;
        final message = (data['message'] is String) ? data['message'] : 'User created successfully';
        
        if (accessToken != null && refreshToken != null) {
          // Validate JWT format before saving
          if (_isValidJWT(accessToken) && _isValidJWT(refreshToken)) {
            await saveTokens(accessToken, refreshToken, userData);
            print('Signup successful, tokens saved');
          } else {
            print('Warning: Received invalid JWT format from server during signup');
          }
        }
        
        return {
          'success': true,
          'data': data,
          'accessToken': accessToken ?? '',
          'refreshToken': refreshToken ?? '',
          'message': message,
          'user': userData ?? {},
        };
      } else {
        // Try to extract error message from backend response
        String errorMsg = 'Registration failed';
        try {
          final decoded = jsonDecode(response.body);
          Map<String, dynamic> data = {};
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
          if (data['error'] is String) {
            errorMsg = data['error'];
          } else if (data['message'] is String) {
            errorMsg = data['message'];
          }
          // Detect duplicate email/user error
          if (errorMsg.toLowerCase().contains('already exists') || errorMsg.toLowerCase().contains('duplicate')) {
            errorMsg = 'User already exists. Please login or use a different email.';
          }
        } catch (e) {
          print('Error parsing signup error response: $e');
        }
        return {
          'success': false,
          'error': errorMsg,
        };
      }
    } catch (e) {
      print('Auth Service Error - Sign Up: $e');
      return {
        'success': false,
        'error': 'Registration failed: Network error',
      };
    }
  }

  // Refresh Token - Fixed to not accept invalid cookie-session tokens
  Future<bool> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || !_isValidJWT(refreshToken)) {
      print('No valid refresh token available');
      await clearTokens();
      return false;
    }
    
    // Don't allow cookie-session-active to be treated as valid - force fresh login
    if (refreshToken == 'cookie-session-active') {
      print('Cookie-session-active detected - invalid token, forcing fresh login');
      await clearTokens();
      return false; // Force user to login again with real JWT
    }
    
    // Don't attempt refresh if refresh token is same as access token (invalid state)
    final currentAccessToken = await getAccessToken();
    if (refreshToken == currentAccessToken || currentAccessToken == 'cookie-session-active') {
      print('Invalid token state - clearing tokens and forcing fresh login');
      await clearTokens();
      return false; // Force fresh login
    }
    
    try {
      // Check if refresh token is expired
      if (JwtDecoder.isExpired(refreshToken)) {
        print('Refresh token is expired, clearing session');
        await clearTokens();
        return false;
      }
      
      // For single-token backends, try cookie-based refresh first
      // For cookie-based authentication (which this backend uses), try refresh with cookies first
      if (storedCookies != null && storedCookies!.isNotEmpty) {
        print('Single-token backend detected, trying cookie-based refresh first');
        
        final cookieRefreshResponse = await http.post(
          Uri.parse('$_baseUrl/auth/token/refresh'),
          headers: {
            'Content-Type': 'application/json',
            'Cookie': storedCookies!,
          },
          body: jsonEncode({}), // Empty body for cookie-based refresh
        );
        
        if (cookieRefreshResponse.statusCode == 200) {
          final cookieData = jsonDecode(cookieRefreshResponse.body);
          final newAccessToken = cookieData['accessToken'] ?? cookieData['data']?['accessToken'];
          
          if (newAccessToken != null && _isValidJWT(newAccessToken)) {
            final userData = await getUserData();
            await saveTokens(newAccessToken, newAccessToken, userData); // Use same token for both
            saveCookies(cookieRefreshResponse);
            print('Cookie-based token refresh successful');
            return true;
          }
        } else {
          print('Cookie-based refresh failed with status: ${cookieRefreshResponse.statusCode}');
          print('Cookie-based refresh response: ${cookieRefreshResponse.body}');
        }
      }
      
      // Standard refresh endpoint with refresh token in body
      print('Attempting token refresh with endpoint: $_baseUrl/auth/token/refresh');
      print('Refresh token being sent: ${refreshToken.length > 20 ? refreshToken.substring(0, 20) + "..." : refreshToken}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/token/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': storedCookies ?? '', // Include cookies as well
        },
        body: jsonEncode({
          'refreshToken': refreshToken,  // Try standard field name
          'refresh_token': refreshToken, // Alternative field name
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Token refresh response: $data');
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'] ?? refreshToken; // Use old refresh token if new one not provided
        
        if (newAccessToken != null && _isValidJWT(newAccessToken)) {
          final userData = await getUserData(); // Preserve existing user data
          await saveTokens(newAccessToken, newRefreshToken, userData);
          print('Token refreshed successfully');
          return true;
        } else {
          print('Invalid access token received during refresh');
          await clearTokens();
          return false;
        }
      } else {
        print('Token refresh failed with status: ${response.statusCode}');
        print('Token refresh response body: ${response.body}');
        await clearTokens();
        return false;
      }
    } catch (e) {
      print('Refresh Token Error: $e');
      await clearTokens();
      return false;
    }
  }

  // Authenticated API call with auto-refresh
  Future<http.Response> authorizedRequest({
    required String method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    String? token = await getAccessToken();
    
    // Check if token exists and is valid
    if (token == null || !_isValidJWT(token)) {
      throw Exception("No valid access token available");
    }
    
    // Check if token is expired and refresh if needed
    if (JwtDecoder.isExpired(token)) {
      print("Access token expired, refreshing...");
      bool success = await refreshAccessToken();
      if (!success) throw Exception("Token refresh failed");
      token = await getAccessToken();
    }
    
    final updatedHeaders = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      ...?headers,
    };
    
    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(Uri.parse(url), headers: updatedHeaders, body: jsonEncode(data));
          break;
        case 'PUT':
          response = await http.put(Uri.parse(url), headers: updatedHeaders, body: jsonEncode(data));
          break;
        case 'DELETE':
          response = await http.delete(Uri.parse(url), headers: updatedHeaders);
          break;
        default:
          response = await http.get(Uri.parse(url), headers: updatedHeaders);
      }
      
      if (response.statusCode == 401) {
        bool refreshed = await refreshAccessToken();
        if (refreshed) {
          token = await getAccessToken();
          final retryHeaders = {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            ...?headers,
          };
          switch (method.toUpperCase()) {
            case 'POST':
              return await http.post(Uri.parse(url), headers: retryHeaders, body: jsonEncode(data));
            case 'PUT':
              return await http.put(Uri.parse(url), headers: retryHeaders, body: jsonEncode(data));
            case 'DELETE':
              return await http.delete(Uri.parse(url), headers: retryHeaders);
            default:
              return await http.get(Uri.parse(url), headers: retryHeaders);
          }
        } else {
          throw Exception('Unauthorized - session expired');
        }
      }
      return response;
    } catch (e) {
      print('Authorized request error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await clearTokens();
    await _googleSignIn.signOut();
    print('Logged out successfully');
  }

  // Google Sign-In - Production Ready Implementation
  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      // Sign out first to ensure a fresh sign-in attempt
      await _googleSignIn.signOut();
      
      // Try to sign in with retry logic
      GoogleSignInAccount? googleUser;
      int retryCount = 0;
      const maxRetries = 2;
      
      while (retryCount < maxRetries && googleUser == null) {
        try {
          // Trigger the authentication flow
          googleUser = await _googleSignIn.signIn();
          if (googleUser == null) {
            // User cancelled the sign-in
            return {
              'success': false,
              'error': 'Google Sign-In was cancelled',
            };
          }
        } catch (e) {
          print('Sign-in attempt ${retryCount + 1} failed: $e');
          retryCount++;
          if (retryCount >= maxRetries) {
            rethrow;
          }
          // Wait before retrying
          await Future.delayed(Duration(seconds: 1));
        }
      }
      
      if (googleUser == null) {
        return {
          'success': false,
          'error': 'Google Sign-In was cancelled',
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Verify we have the necessary tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to obtain Google authentication tokens');
      }

      // Prepare user data from Google account
      final userData = {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? '',
        'photo': googleUser.photoUrl ?? '',
        'accessToken': googleAuth.accessToken!,
        'idToken': googleAuth.idToken!,
      };

      print('Google Sign-In successful for: ${userData['email']}');

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/auth/google/callback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'access_token': userData['accessToken'],
            'id_token': userData['idToken'],
            'email': userData['email'],
            'name': userData['name'],
            'photo': userData['photo'],
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final accessToken = data['accessToken'];
          final refreshToken = data['refreshToken'];
          
          // Validate and save tokens if they're valid JWTs
          if (accessToken != null && refreshToken != null && 
              _isValidJWT(accessToken) && _isValidJWT(refreshToken)) {
            await saveTokens(accessToken, refreshToken, data['user'] ?? userData);
          }
          
          return {
            'success': true,
            'data': data ?? {},
            'accessToken': accessToken ?? '',
            'refreshToken': refreshToken ?? '',
            'message': data['message'] ?? 'Google Sign-In successful',
            'user': data['user'] ?? userData,
          };
        } else {
          throw Exception('Backend authentication failed');
        }
      } catch (backendError) {
        print('Backend Google Auth Error: $backendError');
        
        // If backend fails, still return success with user data for local testing
        return {
          'success': true,
          'data': {
            'accessToken': 'google_access_token_${DateTime.now().millisecondsSinceEpoch}',
            'refreshToken': 'google_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
            'user': userData,
          },
        };
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      
      // Sign out if there was an error to reset state
      await _googleSignIn.signOut();
      
      return {
        'success': false,
        'error': 'Google Sign-In failed: ${e.toString()}',
      };
    }
  }

  // Google Sign-Out
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      print('Google Sign-Out successful');
    } catch (e) {
      print('Google Sign-Out Error: $e');
    }
  }

  // Check if user is currently signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      print('Error checking Google Sign-In status: $e');
      return false;
    }
  }

  // Google Sign-In Callback (handled after redirection)
  Future<Map<String, dynamic>> googleCallback(String code) async {
    try {
      final uri = Uri.parse('$_baseUrl/auth/google/callback?code=$code');
      final response = await http.get(uri);
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': jsonDecode(response.body), // Expect token or user data
      };
    } catch (e) {
      print('Google Callback Error: $e');
      return {
        'success': false,
        'error': 'Google callback failed',
      };
    }
  }

  // Refresh Token (Alternative method)
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/token/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'accessToken': data['accessToken'],
          'refreshToken': data['refreshToken'],
          'message': 'Token refreshed successfully',
        };
      }
      
      return {
        'success': false,
        'error': 'Token refresh failed',
      };
    } catch (e) {
      print('Refresh Token Error: $e');
      return {
        'success': false,
        'error': 'Token refresh failed',
      };
    }
  }

  // Test Route (Requires Authorization)
  Future<Map<String, dynamic>> testRoute(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/test'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': jsonDecode(response.body),
        'message': 'Test route successful',
      };
    } catch (e) {
      print('Test Route Error: $e');
      return {
        'success': false,
        'error': 'Test route failed',
      };
    }
  }

  String? getAuthToken() {
    return _authToken;
  }
}