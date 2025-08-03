import 'package:flutter/material.dart';
import 'package:pgbee/models/auth_model.dart';
import 'package:pgbee/services/service_manager.dart';

class AuthProvider extends ChangeNotifier {
  final ServiceManager _serviceManager = ServiceManager();

  bool _isSignUp = false;
  bool get isSignUp => _isSignUp;

  void changeAuth() {
    _isSignUp = !_isSignUp;
    notifyListeners();
  }

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void changeVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool _agreeToTerms = false;
  bool get agreeToTerms => _agreeToTerms;

  void changeAgreeTerms() {
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthenticated = false;
  bool get isLoggedIn => _isAuthenticated;
  
  String? errorMessage;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  bool _sessionInitialized = false;
  bool get sessionInitialized => _sessionInitialized;

  // Initialize session on app startup
  Future<bool> initializeSession() async {
    if (_sessionInitialized) {
      print('Session already initialized');
      return _isAuthenticated;
    }

    print('AuthProvider: Initializing session...');
    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      // Initialize ServiceManager session first
      final hasValidSession = await _serviceManager.initializeSession();
      
      if (hasValidSession) {
        print('AuthProvider: Valid session found from ServiceManager');
        // Get user data from ServiceManager
        _currentUser = _serviceManager.currentUser;
        _isAuthenticated = true;
        print('AuthProvider: Session restored successfully for user: ${_currentUser?['email'] ?? 'unknown'}');
      } else {
        print('AuthProvider: No valid session found');
        _isAuthenticated = false;
        _currentUser = null;
      }
      
      _sessionInitialized = true;
      _isLoading = false;
      notifyListeners();
      
      return _isAuthenticated;
    } catch (e) {
      print('AuthProvider.initializeSession error: $e');
      _isAuthenticated = false;
      _currentUser = null;
      errorMessage = 'Session initialization failed';
      _sessionInitialized = true;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fixed signIn method
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _serviceManager.authService.signIn(email, password);
    if (result['success'] == true) {
      // Propagate token to all services immediately
      final accessToken = result['accessToken'] ?? result['data']?['accessToken'];
      final refreshToken = result['refreshToken'] ?? result['data']?['refreshToken'];
      final user = result['user'] ?? result['data']?['user'];
      
      // Validate tokens before proceeding
      if (accessToken != null && accessToken.isNotEmpty) {
        // Handle single-token backends (use accessToken as refresh token if refresh is missing)
        final finalRefreshToken = (refreshToken != null && refreshToken.isNotEmpty) ? refreshToken : accessToken;
        
        await _serviceManager.setAuthTokens(
          accessToken: accessToken,
          refreshToken: finalRefreshToken,
          user: user,
        );
        errorMessage = null;
        _isAuthenticated = true;
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
      } else {
        // Invalid tokens received
        print('AuthProvider: Invalid or empty tokens received from server');
        errorMessage = 'Invalid authentication response from server';
        _isAuthenticated = false;
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
      return true;
    } else {
      errorMessage = result['error'] ?? 'Login failed';
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fixed signUp method
  Future<bool> signUp(AuthModel user) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    final result = await _serviceManager.authService.signUp(user);
    if (result['success'] == true) {
      // Propagate token to all services immediately
      final accessToken = result['accessToken'] ?? result['data']?['accessToken'] ?? '';
      final refreshToken = result['refreshToken'] ?? result['data']?['refreshToken'];
      final userData = result['user'] ?? result['data']?['user'];
      await _serviceManager.setAuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: userData,
      );
      errorMessage = null;
      _isAuthenticated = true;
      _currentUser = userData;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      errorMessage = result['error'] ?? 'Registration failed';
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _serviceManager.authService.logout();
      
      // Clear authentication state
      _isAuthenticated = false;
      _currentUser = null;
      errorMessage = null;
      _sessionInitialized = false; // Reset session initialization
      
      print('User signed out successfully');
    } catch (e) {
      errorMessage = "Sign out failed";
      print('Sign out error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get user role
  String? getUserRole() {
    return _currentUser?['role']?.toString();
  }

  // Check if user is owner
  bool isOwner() {
    final role = getUserRole();
    return role?.toLowerCase() == 'owner';
  }

  // Check if user is student
  bool isStudent() {
    final role = getUserRole();
    return role?.toLowerCase() == 'student';
  }

  // Get user name
  String? getUserName() {
    return _currentUser?['name']?.toString() ?? _currentUser?['displayName']?.toString();
  }

  // Get user email
  String? getUserEmail() {
    return _currentUser?['email']?.toString();
  }

  // Get user phone
  String? getUserPhone() {
    return _currentUser?['phoneNo']?.toString() ?? _currentUser?['phone']?.toString();
  }

  // Check if session needs refresh
  Future<bool> refreshSessionIfNeeded() async {
    if (!_isAuthenticated) return false;
    
    try {
      final isExpired = await _serviceManager.authService.isAccessTokenExpired();
      if (isExpired) {
        print('Access token expired, attempting refresh...');
        final refreshSuccess = await _serviceManager.authService.refreshAccessToken();
        if (!refreshSuccess) {
          print('Token refresh failed, signing out...');
          await signOut();
          return false;
        }
        print('Token refreshed successfully');
      }
      return true;
    } catch (e) {
      print('Error checking/refreshing session: $e');
      await signOut();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Reset authentication state (for testing/debugging)
  void resetAuthState() {
    _isAuthenticated = false;
    _currentUser = null;
    _sessionInitialized = false;
    errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}