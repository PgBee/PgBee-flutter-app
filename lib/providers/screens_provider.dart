import 'package:flutter/material.dart';

class ScreensProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String _profileScreen = 'security'; // Default to SecuritySettingsPage

  int get currentIndex => _currentIndex;
  String get profileScreen => _profileScreen;

  void changePage(int index) {
    _currentIndex = index;
    // Reset to SecuritySettingsPage when switching to Profile tab
    if (index == 3) {
      _profileScreen = 'security';
    }
    notifyListeners();
  }

  void changeProfileScreen(String screen) {
    _profileScreen = screen;
    notifyListeners();
  }
}