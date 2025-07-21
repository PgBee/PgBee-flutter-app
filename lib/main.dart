import 'package:flutter/material.dart';
import 'package:pgbee/login_screen.dart';

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
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFAFAFAFA)),
      ),
      home: LoginScreen(),
    );
  }
}

