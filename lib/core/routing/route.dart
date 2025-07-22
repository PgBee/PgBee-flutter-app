import 'package:flutter/widgets.dart';
import 'package:pgbee/views/screens/auth_screen.dart';

class AppRoute {
  static Map<String,WidgetBuilder> appRoute = {
    "/login": (_) => AuthScreen()
  };
}