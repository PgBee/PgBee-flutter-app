import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth_service.dart';
import 'hostel_service.dart';
import 'amenities_service.dart';
import 'owner_service.dart';
import 'enquiry_service.dart';
import 'review_service.dart';

class ServiceManager {
  static final ServiceManager _instance = ServiceManager._internal();
  factory ServiceManager() => _instance;
  ServiceManager._internal();

  // Services
  final AuthService authService = AuthService();
  final HostelService hostelService = HostelService();
  final AmenitiesService amenitiesService = AmenitiesService();
  final OwnerService ownerService = OwnerService();
  final EnquiryService enquiryService = EnquiryService();
  final ReviewService reviewService = ReviewService();

  // Current authentication token
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _currentUser;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _accessToken != null;

  // SharedPreferences keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Initialize and check for saved session
  Future<bool> initializeSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final savedAccessToken = prefs.getString(_accessTokenKey);
      final savedRefreshToken = prefs.getString(_refreshTokenKey);
      final savedUserData = prefs.getString(_userDataKey);
      
      if (savedAccessToken != null && savedRefreshToken != null) {
        print('Found saved tokens, attempting to restore session...');
        
        // Check if tokens are obviously expired before attempting restore
        if (_isTokenExpired(savedAccessToken)) {
          print('Saved access token is expired, clearing session');
          await clearSavedSession();
          return false;
        }
        
        // Restore user data if available
        Map<String, dynamic>? userData;
        if (savedUserData != null) {
          try {
            userData = jsonDecode(savedUserData);
          } catch (e) {
            print('Error parsing saved user data: $e');
          }
        }
        
        setAuthTokens(
          accessToken: savedAccessToken,
          refreshToken: savedRefreshToken,
          user: userData,
        );
        
        // Try to refresh token to ensure it's still valid
        print('Checking token validity and refreshing if needed...');
        final refreshResult = await refreshTokenIfNeeded();
        if (!refreshResult) {
          print('Token refresh failed during session initialization');
          // If refresh failed, the clearSavedSession was already called in refreshTokenIfNeeded
          return false;
        }
        
        print('Session restored successfully');
        return true;
      } else {
        print('No saved tokens found');
      }
    } catch (e) {
      print('Error initializing session: $e');
    }
    
    print('Session initialization failed - user needs to log in');
    return false;
  }

  // Save session to SharedPreferences
  Future<void> saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (_accessToken != null) {
        await prefs.setString(_accessTokenKey, _accessToken!);
      }
      
      if (_refreshToken != null) {
        await prefs.setString(_refreshTokenKey, _refreshToken!);
      }
      
      if (_currentUser != null) {
        // Properly encode user data as JSON
        await prefs.setString(_userDataKey, jsonEncode(_currentUser!));
      }
      
      print('Session saved successfully');
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  // Clear saved session
  Future<void> clearSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userDataKey);
      print('Saved session cleared');
    } catch (e) {
      print('Error clearing saved session: $e');
    }
  }

  // Set authentication tokens and propagate to all services
  void setAuthTokens({
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _currentUser = user;

    // Set token in all services
    hostelService.setAuthToken(accessToken);
    amenitiesService.setAuthToken(accessToken);
    ownerService.setAuthToken(accessToken);
    enquiryService.setAuthToken(accessToken);
    reviewService.setAuthToken(accessToken);
    
    // Automatically save session to SharedPreferences
    saveSession();
  }

  // Clear authentication tokens
  void clearAuth() {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    // Clear tokens from all services by setting empty headers
    // Services should handle empty token gracefully
    
    // Clear saved session from SharedPreferences
    clearSavedSession();
  }

  // Check if JWT token is expired
  bool _isTokenExpired(String token) {
    try {
      // JWT has 3 parts separated by dots
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Invalid JWT format - expected 3 parts, got ${parts.length}');
        return true;
      }
      
      // Decode the payload (second part)
      String payload = parts[1];
      
      // Add padding if needed for base64 decoding
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);
      
      print('Token payload (partial): ${payloadMap.keys.toList()}');
      
      // Check expiration time (exp claim is in seconds since epoch)
      final exp = payloadMap['exp'];
      if (exp == null) {
        print('No expiration time found in token');
        return true;
      }
      
      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      print('Token expires at: $expirationTime, current time: $now');
      
      // Add a 5-minute buffer to refresh before actual expiration
      final buffer = Duration(minutes: 5);
      
      bool isExpired = now.isAfter(expirationTime.subtract(buffer));
      print('Token expired (with 5min buffer): $isExpired');
      
      return isExpired;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // Consider token expired if we can't parse it
    }
  }

  // Refresh token if needed
  Future<bool> refreshTokenIfNeeded() async {
    if (_refreshToken == null) {
      print('No refresh token available');
      return false;
    }

    // Check if access token is expired before making refresh call
    if (_accessToken != null && !_isTokenExpired(_accessToken!)) {
      print('Access token is still valid, no refresh needed');
      return true; // Token is still valid, no need to refresh
    }

    print('Attempting to refresh token...');
    try {
      final result = await authService.refreshToken(_refreshToken!);
      print('Token refresh response: $result');
      
      if (result['success'] == true) {
        setAuthTokens(
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken'],
          user: _currentUser,
        );
        print('Token refresh successful');
        return true;
      } else {
        print('Token refresh failed: ${result['message'] ?? result['error'] ?? 'Unknown error'}');
        // Clear tokens and saved session when refresh fails
        await clearSavedSession();
        return false;
      }
    } catch (e) {
      print('Token refresh failed with exception: $e');
      // Check if it's a 401/403 error indicating invalid tokens
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('401') || 
          errorMessage.contains('403') || 
          errorMessage.contains('unauthorized') ||
          errorMessage.contains('forbidden') ||
          errorMessage.contains('invalid') ||
          errorMessage.contains('expired')) {
        print('Authentication error detected, clearing saved session');
        // Clear saved session for authentication errors
        await clearSavedSession();
      } else {
        print('Network or temporary error, keeping saved session');
        // For network errors, just clear in-memory tokens
        _accessToken = null;
        _refreshToken = null;
        _currentUser = null;
      }
      return false;
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await authService.signIn(email, password);
      
      if (result['success'] == true) {
        setAuthTokens(
          accessToken: result['accessToken'] ?? result['data']?['accessToken'],
          refreshToken: result['refreshToken'] ?? result['data']?['refreshToken'],
          user: result['user'] ?? result['data']?['user'],
        );
      }
      
      return result;
    } catch (e) {
      print('Login error: $e');
      return {
        'success': false,
        'error': 'Login failed',
      };
    }
  }

  // Login with Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final result = await authService.googleSignIn();
      
      if (result['success'] == true) {
        setAuthTokens(
          accessToken: result['accessToken'] ?? result['data']?['accessToken'],
          refreshToken: result['refreshToken'] ?? result['data']?['refreshToken'],
          user: result['user'] ?? result['data']?['user'],
        );
      }
      
      return result;
    } catch (e) {
      print('Google login error: $e');
      return {
        'success': false,
        'error': 'Google login failed',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register(dynamic userModel) async {
    try {
      final result = await authService.signUp(userModel);
      
      if (result['success'] == true) {
        setAuthTokens(
          accessToken: result['accessToken'] ?? result['data']?['accessToken'],
          refreshToken: result['refreshToken'] ?? result['data']?['refreshToken'],
          user: result['user'] ?? result['data']?['user'],
        );
      }
      
      return result;
    } catch (e) {
      print('Registration error: $e');
      return {
        'success': false,
        'error': 'Registration failed',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await authService.signOutGoogle();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      clearAuth();
    }
  }

  // Check if user is owner
  bool isOwner() {
    return _currentUser?['role'] == 'owner';
  }

  // Check if user is student
  bool isStudent() {
    return _currentUser?['role'] == 'student';
  }

  // Get user role
  String? getUserRole() {
    return _currentUser?['role'];
  }

  // Force logout when tokens are confirmed invalid
  Future<void> forceLogout() async {
    print('Forcing logout due to invalid tokens');
    clearAuth();
  }

  // Handle API errors and logout if tokens are invalid
  void handleApiError(dynamic error) {
    if (error.toString().contains('401') || 
        error.toString().contains('Unauthorized') ||
        error.toString().contains('Invalid token')) {
      print('API error indicates invalid tokens, forcing logout');
      forceLogout();
    }
  }

  // Get user ID
  String? getUserId() {
    return _currentUser?['id'];
  }

  // Get user name
  String? getUserName() {
    return _currentUser?['name'];
  }

  // Get user email
  String? getUserEmail() {
    return _currentUser?['email'];
  }
}
