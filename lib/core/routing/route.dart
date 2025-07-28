import 'package:flutter/widgets.dart';
import 'package:pgbee/views/screens/auth_screen.dart';
import 'package:pgbee/views/screens/root_layout.dart';

class AppRoute {
  static Map<String,WidgetBuilder> appRoute = {
    "/auth": (_) => AuthScreen(),
    "/": (_) => RootLayout()
  };
}