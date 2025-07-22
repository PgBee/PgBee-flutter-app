import 'package:flutter/material.dart';
import 'package:pgbee/controllers/auth_controller.dart';
import 'package:pgbee/models/auth_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _controller;
  AuthProvider(this._controller);


  // SignUp or SignIn
  bool _isSignUp = false;
  bool get isSignUp => _isSignUp;

  void changeAuth(){
    _isSignUp = !_isSignUp;
    notifyListeners();
  }

  // Password Visible or Not
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  void changeVisibility(){
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // Terms and Condition Terms
  bool _agreeToTerms = false;
  bool get agreeToTerms => _agreeToTerms;

  void changeAgreeTerms(){
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  } 

  // Login and Signup Operation
  bool isLoggedIn = false;
  String? errorMessage;

  Future<bool> signIn(String email, String password) async {
    final result = await _controller.login(email, password);
    isLoggedIn = result;
    errorMessage = result ? null : "Invalid email or password";
    notifyListeners();
    return result;
  }

  Future<bool> signUp(String first, String last, String email, String pass) async {
    final user = AuthModel(firstName: first, lastName: last, email: email, password: pass);
    final result = await _controller.register(user);
    errorMessage = result ? null : "Email already registered";
    notifyListeners();
    return result;
  }
}