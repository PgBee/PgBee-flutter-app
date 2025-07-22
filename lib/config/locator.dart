import 'package:pgbee/controllers/auth_controller.dart';
import 'package:pgbee/providers/auth_provider.dart';
import 'package:pgbee/services/auth_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {

  // Authentication
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => AuthController(locator()));
  locator.registerLazySingleton(() => AuthProvider(locator()));
}
