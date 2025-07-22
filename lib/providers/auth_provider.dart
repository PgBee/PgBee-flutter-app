import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {

  // SignUp or SignIn
  bool _isSignUp = false;
  bool get isSignUp => _isSignUp;

  void changeAuth(){
    _isSignUp = !_isSignUp;
    notifyListeners();
  }

}