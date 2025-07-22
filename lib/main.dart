import 'package:flutter/material.dart';
//import 'package:pgbee/core/routing/route.dart';
import 'package:pgbee/core/theme/app_theme.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:pgbee/views/screens/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:pgbee/config/locator.dart';

void main() {
  setupLocator();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider())
      ],
      child: PgBee(),
    )
  );
}

class PgBee extends StatelessWidget {
  const PgBee({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //routes: AppRoute.appRoute,
      debugShowCheckedModeBanner: false,
      title: 'PgBee',
      theme: AppTheme.appTheme,
      home: AuthScreen(),
    );
  }
}

