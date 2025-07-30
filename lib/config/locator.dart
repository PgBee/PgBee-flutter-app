import 'package:pgbee/controllers/auth_controller.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:pgbee/providers/enquiry_provider.dart';
import 'package:pgbee/providers/hostel_provider.dart';
import 'package:pgbee/services/auth_service.dart';
import 'package:pgbee/services/service_manager.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  // Service Manager (Singleton)
  locator.registerLazySingleton(() => ServiceManager());

  // Individual Services (for backward compatibility if needed)
  locator.registerLazySingleton(() => AuthService());

  // Controllers
  locator.registerLazySingleton(() => AuthController());

  // Providers
  locator.registerLazySingleton(() => AuthProvider());
  locator.registerLazySingleton(() => EnquiryProvider());
  locator.registerLazySingleton(() => HostelProvider());
}
