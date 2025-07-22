import 'package:flutter/material.dart';
import 'package:pgbee/core/theme/app_theme.dart';
import 'package:pgbee/views/screens/login_screen.dart';

void main() {
  runApp(PgBee());
}

class PgBee extends StatelessWidget {
  const PgBee({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PgBee',
      theme: AppTheme.appTheme,
      home: LoginScreen(),
    );
  }
}

