import 'package:flutter/material.dart';
import 'package:pgbee/core/constants/colors.dart';

class AppTheme {
  static ThemeData appTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: LightColor.background,
    canvasColor: LightColor.background,
    cardColor: LightColor.background,
    hintColor: LightColor.hintText,
    shadowColor: LightColor.black
  );
}