import 'package:pgbee/models/auth_model.dart';
import 'package:pgbee/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Future<bool> login(String email, String password) async {
    final result = await _authService.signIn(email, password);
    if (result['success']) {
      // Store tokens (access and refresh) in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result['data']['access_token']);
      await prefs.setString('refresh_token', result['data']['refresh_token']);
      return true;
    }
    return false;
  }

  Future<bool> register(AuthModel user) async {
    final result = await _authService.signUp(user);
    if (result['success']) {
      // Optionally store tokens if signup returns them
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', result['data']['access_token']);
      await prefs.setString('refresh_token', result['data']['refresh_token']);
      return true;
    }
    return false;
  }

  Future<bool> googleSignIn() async {
    final result = await _authService.googleSignIn();
    if (result['success']) {
      // Handle redirect URL or token
      return true;
    }
    return false;
  }

  Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) return false;

    final result = await _authService.refreshToken(refreshToken);
    if (result['success']) {
      await prefs.setString('access_token', result['data']['access_token']);
      return true;
    }
    return false;
  }

  Future<bool> testRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null) return false;

    final result = await _authService.testRoute(accessToken);
    return result['success'];
  }
}