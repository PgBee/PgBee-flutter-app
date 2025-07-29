import 'package:pgbee/models/auth_model.dart';
import 'package:pgbee/services/auth_service.dart';

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Future<bool> login(String email, String password) async {
    final result = await _authService.signIn(email, password);
    return result['success'] ?? false;
  }

  Future<bool> register(AuthModel user) async {
    final result = await _authService.signUp(user);
    return result['success'] ?? false;
  }

  Future<bool> googleSignIn() async {
    final result = await _authService.googleSignIn();
    return result['success'] ?? false;
  }

  Future<Map<String, dynamic>> googleCallback(String code) async {
    return await _authService.googleCallback(code);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await _authService.refreshToken(refreshToken);
  }

  Future<Map<String, dynamic>> testRoute(String accessToken) async {
    return await _authService.testRoute(accessToken);
  }

  // Method to get error messages from the service
  Future<String?> getLastError() async {
    // This could be implemented to track the last error from the service
    return null;
  }
}