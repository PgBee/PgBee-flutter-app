import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';

class AppTheme {
  static ThemeData appTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: LightColor.background,
    canvasColor: LightColor.background,
    cardColor: LightColor.background,
    hintColor: LightColor.grey,
    shadowColor: LightColor.shadowColor
  );

  static List<BoxShadow> shadowBox =  [
    BoxShadow(
      color: LightColor.shadowColor,
      blurRadius: 17,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static EdgeInsets screenPadding = EdgeInsets.symmetric(vertical: 16);
}