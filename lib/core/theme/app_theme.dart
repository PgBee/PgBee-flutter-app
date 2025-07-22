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

  // Text Styles
  static TextStyle h1Style = TextStyle(fontSize: 32,fontWeight: FontWeight.normal);
  static TextStyle h2Style = TextStyle(fontSize: 28,fontWeight: FontWeight.normal);
  static TextStyle h3Style = TextStyle(fontSize: 24,fontWeight: FontWeight.w400);
  static TextStyle h4Style = TextStyle(fontSize: 20,fontWeight: FontWeight.w400);
  static TextStyle h5Style = TextStyle(fontSize: 18,fontWeight: FontWeight.w400);
  static TextStyle h6Style = TextStyle(fontSize: 16,fontWeight: FontWeight.w400);


  static EdgeInsets screenPadding = EdgeInsets.symmetric(vertical: 16);
}