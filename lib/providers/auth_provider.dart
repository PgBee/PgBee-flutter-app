import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {

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
}