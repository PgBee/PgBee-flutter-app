import 'package:flutter/material.dart';
import 'package:pgbee/controllers/auth_controller.dart';
import 'package:pgbee/models/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _controller;
  AuthProvider(this._controller);

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

  bool isLoggedIn = false;
  String? errorMessage;

  Future<bool> signIn(String email, String password) async {
    try {
      final result = await _controller.login(email, password);
      isLoggedIn = result;
      if (result) {
        errorMessage = null;
      } else {
        errorMessage = "Invalid email or password. Please check your credentials.";
      }
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = "Login failed. Please try again.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String first, String last, String email, String pass) async {
    if (!_agreeToTerms) {
      errorMessage = "Please agree to the terms and conditions";
      notifyListeners();
      return false;
    }
    
    try {
      final user = AuthModel(
        email: email,
        password: pass,
        firstName: first,
        lastName: last,
        role: "user", // Adjust based on backend requirements
      );
      final result = await _controller.register(user);
      if (result) {
        isLoggedIn = true;
        errorMessage = null;
      } else {
        errorMessage = "Registration failed. Email might already be registered.";
      }
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = "Registration failed. Please try again.";
      notifyListeners();
      return false;
    }
  }
  Future<bool> googleSignIn() async {
    try {
      // Call the backend Google Sign-In endpoint
      final result = await _controller.googleSignIn();
      if (result) {
        isLoggedIn = true;
        errorMessage = null;
        notifyListeners();
        return true;
      }
      errorMessage = "Failed to authenticate with Google";
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = "Google Sign-In error: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }
}