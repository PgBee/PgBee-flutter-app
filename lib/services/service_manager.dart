import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
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
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  // SharedPreferences keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Helper method to propagate tokens to all services
  void _propagateTokensToServices() {
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      print('ServiceManager: Propagating token to all services - token length: ${_accessToken!.length}');
      authService.setAuthToken(_accessToken!);
      hostelService.setAuthToken(_accessToken!);
      amenitiesService.setAuthToken(_accessToken!);
      ownerService.setAuthToken(_accessToken!);
      enquiryService.setAuthToken(_accessToken!);
      reviewService.setAuthToken(_accessToken!);
      print('ServiceManager: Tokens propagated to all services');
    } else {
      print('ServiceManager: No token to propagate - token is null or empty');
    }
  }

  // Initialize and check for saved session
  Future<bool> initializeSession() async {
    try {
      print('ServiceManager.initializeSession: Starting initialization...');
      
      // Try to restore from SharedPreferences directly first
      final prefs = await SharedPreferences.getInstance();
      final storedAccessToken = prefs.getString(_accessTokenKey);
      final storedRefreshToken = prefs.getString(_refreshTokenKey);
      final storedUserData = prefs.getString(_userDataKey);
      
      if (storedAccessToken != null && storedRefreshToken != null && 
          storedAccessToken.isNotEmpty && storedRefreshToken.isNotEmpty) {
        print('ServiceManager: Found stored tokens in SharedPreferences');
        print('ServiceManager: Access token length: ${storedAccessToken.length}');
        print('ServiceManager: Refresh token length: ${storedRefreshToken.length}');
        print('ServiceManager: Access token preview: ${storedAccessToken.length > 10 ? storedAccessToken.substring(0, 10) + "..." : storedAccessToken}');
        
        // Parse user data
        Map<String, dynamic>? userData;
        if (storedUserData != null) {
          try {
            userData = Map<String, dynamic>.from(jsonDecode(storedUserData));
          } catch (e) {
            print('ServiceManager: Error parsing stored user data: $e');
          }
        }
        
        // Check if the stored access token is expired before using it
        if (storedAccessToken != 'cookie-session-active') {
          try {
            final isExpired = JwtDecoder.isExpired(storedAccessToken);
            if (isExpired) {
              print('ServiceManager: Stored access token is expired, clearing session');
              await clearSavedSession();
              return false;
            }
            print('ServiceManager: Stored access token is valid and not expired');
          } catch (e) {
            print('ServiceManager: Error checking stored token expiration: $e');
            print('ServiceManager: Clearing potentially invalid tokens');
            await clearSavedSession();
            return false;
          }
        }
        
        // Set tokens directly
        _accessToken = storedAccessToken;
        _refreshToken = storedRefreshToken;
        _currentUser = userData;
        
        // Load stored cookies for session persistence
        await AuthService.loadCookiesFromStorage();
        
        // Propagate tokens to all services immediately
        _propagateTokensToServices();
        
        // Also ensure HostelService has the token
        await hostelService.restoreAuthToken();
        
        print('ServiceManager: Session restored from SharedPreferences and tokens propagated');
        return true;
      }
      
      // Fallback: check if auth service has valid session
      final hasValidSession = await authService.hasValidSession();
      
      if (hasValidSession) {
        print('Valid session found from AuthService, restoring tokens...');
        
        // Get tokens from auth service
        final accessToken = await authService.getAccessToken();
        final refreshToken = await authService.getRefreshToken();
        final userData = await authService.getUserData();
        
        if (accessToken != null && refreshToken != null) {
          // Set tokens in service manager
          _accessToken = accessToken;
          _refreshToken = refreshToken;
          _currentUser = userData;
          
          // Propagate tokens to all services IMMEDIATELY
          _propagateTokensToServices();
          
          // Save to SharedPreferences
          await _saveTokensToSharedPreferences(accessToken, refreshToken, userData);
          
          // Also restore tokens in hostel service to ensure it has them
          await hostelService.restoreAuthToken();
          
          print('ServiceManager: Session restored from AuthService and tokens propagated');
          return true;
        }
      }
      
      print('ServiceManager: No valid session found');
      return false;
    } catch (e) {
      print('ServiceManager.initializeSession error: $e');
      await clearSavedSession();
      return false;
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
  Future<void> setAuthTokens({
    required String accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) async {
    print('ServiceManager.setAuthTokens: Setting tokens...');
    
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _currentUser = user;

    // Propagate tokens to all services IMMEDIATELY before saving
    _propagateTokensToServices();
    print('ServiceManager: Tokens propagated to services immediately');

    // Save tokens via AuthService for persistence
    if (refreshToken != null) {
      authService.saveTokens(accessToken, refreshToken, user);
    }

    // Force save to SharedPreferences
    await _saveTokensToSharedPreferences(accessToken, refreshToken, user);

    print('ServiceManager: Tokens set, propagated, and saved to all services');
  }
  
  // Helper method to save tokens directly to SharedPreferences
  Future<void> _saveTokensToSharedPreferences(String accessToken, String? refreshToken, Map<String, dynamic>? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
      if (user != null) {
        await prefs.setString(_userDataKey, jsonEncode(user));
      }
      print('ServiceManager: Tokens saved directly to SharedPreferences');
    } catch (e) {
      print('ServiceManager: Error saving tokens to SharedPreferences: $e');
    }
  }

  // Ensure tokens are available and propagated to all services
  Future<bool> ensureTokensReady() async {
    print('ServiceManager.ensureTokensReady: Checking token availability...');
    
    // If we have tokens in memory, propagate them
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      print('ServiceManager: Tokens available in memory, propagating...');
      _propagateTokensToServices();
      return true;
    }
    
    // If no tokens in memory, try to restore from session
    print('ServiceManager: No tokens in memory, attempting session restore...');
    final sessionRestored = await initializeSession();
    
    if (!sessionRestored) {
      print('ServiceManager: Session restoration failed - authentication required');
      return false;
    }
    
    return true;
  }

  // Clear authentication tokens
  void clearAuth() {
    print('ServiceManager.clearAuth: Clearing tokens...');
    
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;

    // Clear saved session from AuthService
    authService.clearTokens();
    print('ServiceManager: Authentication cleared');
  }

  // Check if JWT token is expired
  bool _isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
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
      
      if (result['success'] == true) {
        await setAuthTokens(
          accessToken: result['accessToken'],
          refreshToken: result['refreshToken'],
          user: _currentUser,
        );
        print('Token refresh successful');
        return true;
      } else {
        print('Token refresh failed: ${result['message'] ?? result['error'] ?? 'Unknown error'}');
        await clearSavedSession();
        return false;
      }
    } catch (e) {
      print('Token refresh failed with exception: $e');
      await clearSavedSession();
      return false;
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final result = await authService.signIn(email, password);
      if (result['success'] == true) {
        final accessToken = result['accessToken'] ?? result['data']?['accessToken'];
        final refreshToken = result['refreshToken'] ?? result['data']?['refreshToken'];
        final user = result['user'] ?? result['data']?['user'];
        
        if (accessToken != null) {
          await setAuthTokens(
            accessToken: accessToken,
            refreshToken: refreshToken,
            user: user,
          );
          print('ServiceManager: Login successful, tokens propagated to all services');
        }
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
  Future<void> handleApiError(dynamic error) async {
    if (error.toString().contains('401') || 
        error.toString().contains('Unauthorized') ||
        error.toString().contains('Invalid token')) {
      print('API error indicates invalid tokens, attempting refresh first');
      
      // Try to refresh token before forcing logout
      bool refreshed = false;
      try {
        refreshed = await authService.refreshAccessToken();
        print('ServiceManager.handleApiError: Token refresh result: $refreshed');
      } catch (e) {
        print('ServiceManager.handleApiError: Token refresh failed: $e');
      }
      
      if (!refreshed) {
        print('Token refresh failed, forcing logout');
        await forceLogout();
      } else {
        print('Token refreshed successfully, error may be retried');
      }
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
