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

  bool get isLoggedIn => _serviceManager.isAuthenticated;
  String? errorMessage;
  Map<String, dynamic>? get currentUser => _serviceManager.currentUser;

  // Initialize session on app startup
  Future<bool> initializeSession() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      final sessionRestored = await _serviceManager.initializeSession();
      _isLoading = false;
      notifyListeners();
      return sessionRestored;
    } catch (e) {
      print('Session initialization error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _serviceManager.login(email, password);
      
      if (result['success'] == true) {
        errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = result['error'] ?? "Invalid email or password. Please check your credentials.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Login failed. Please try again.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(AuthModel user) async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (!_agreeToTerms) {
        errorMessage = "Please agree to the terms and conditions";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final result = await _serviceManager.register(user);
      
      if (result['success'] == true) {
        errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = result['error'] ?? "Registration failed. Email might already be registered.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Registration failed. Please try again.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    _isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _serviceManager.loginWithGoogle();
      
      if (result['success'] == true) {
        errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = result['error'] ?? "Failed to authenticate with Google";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Google Sign-In error: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _serviceManager.logout();
      errorMessage = null;
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
    return _serviceManager.getUserRole();
  }

  // Check if user is owner
  bool isOwner() {
    return _serviceManager.isOwner();
  }

  // Check if user is student
  bool isStudent() {
    return _serviceManager.isStudent();
  }

  // Get user name
  String? getUserName() {
    return _serviceManager.getUserName();
  }

  // Get user email
  String? getUserEmail() {
    return _serviceManager.getUserEmail();
  }
}
