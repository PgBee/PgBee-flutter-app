import 'package:flutter/material.dart';
import 'package:pgbee/core/routing/route.dart';
import 'package:pgbee/core/theme/app_theme.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:pgbee/providers/screens_provider.dart';
import 'package:pgbee/providers/hostel_provider.dart';
import 'package:pgbee/providers/enquiry_provider.dart';
import 'package:pgbee/core/widgets/app_initializer.dart';
import 'package:pgbee/services/local_storage_service.dart';
import 'package:pgbee/config/locator.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize service locator first
  setupLocator();
  
  // Initialize local storage (Hive) for fallback functionality
  await LocalStorageService.init();
  // Don't initialize mock data here - let it be initialized only when needed
  // to preserve user's saved data
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScreensProvider()),
        ChangeNotifierProvider(create: (_) => HostelProvider()),
        ChangeNotifierProvider(create: (_) => EnquiryProvider()),
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
      routes: AppRoute.appRoute,
      debugShowCheckedModeBanner: false,
      title: 'PgBee',
      theme: AppTheme.appTheme,
      // Use AppInitializer to handle session restoration and initial navigation
      home: const AppInitializer(),
    );
  }
}
