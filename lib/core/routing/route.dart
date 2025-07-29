import 'package:flutter/widgets.dart';
import 'package:pgbee/views/screens/auth_screen.dart';
import 'package:pgbee/views/screens/landing_page.dart';
//import 'package:pgbee/views/screens/landing_page.dart';
import 'package:pgbee/views/screens/profile.dart';
//import 'package:pgbee/views/screens/landing_page.dart';
import 'package:pgbee/views/screens/root_layout.dart';

class AppRoute {
  static Map<String,WidgetBuilder> appRoute = {
    "/auth": (_) => AuthScreen(),
    "/profileSettings": (_) => SecuritySettingsPage(),
    "/home": (_) => RootLayout(),
    "/": (_) => NetworkingArenaPage(), // Default route
  };
}