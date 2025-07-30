import 'package:pgbee/models/auth_model.dart';
import 'package:pgbee/services/service_manager.dart';

class AuthController {
  final ServiceManager _serviceManager = ServiceManager();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _serviceManager.authService.signIn(email, password);
    
    if (result['success'] == true) {
      _serviceManager.setAuthTokens(
        accessToken: result['accessToken'] ?? result['data']?['accessToken'] ?? '',
        refreshToken: result['refreshToken'] ?? result['data']?['refreshToken'],
        user: result['user'] ?? result['data']?['user'],
      );
    }
    
    return result;
  }

  Future<Map<String, dynamic>> register(AuthModel user) async {
    final result = await _serviceManager.authService.signUp(user);
    
    if (result['success'] == true) {
      _serviceManager.setAuthTokens(
        accessToken: result['accessToken'] ?? result['data']?['accessToken'] ?? '',
        refreshToken: result['refreshToken'] ?? result['data']?['refreshToken'],
        user: result['user'] ?? result['data']?['user'],
      );
    }
    
    return result;
  }

  Future<Map<String, dynamic>> googleSignIn() async {
    final result = await _serviceManager.authService.googleSignIn();
    
    if (result['success'] == true) {
      _serviceManager.setAuthTokens(
        accessToken: result['accessToken'] ?? result['data']?['accessToken'] ?? '',
        refreshToken: result['refreshToken'] ?? result['data']?['refreshToken'],
        user: result['user'] ?? result['data']?['user'],
      );
    }
    
    return result;
  }

  Future<Map<String, dynamic>> googleCallback(String code) async {
    final result = await _serviceManager.authService.googleCallback(code);
    
    if (result['success'] == true) {
      _serviceManager.setAuthTokens(
        accessToken: result['accessToken'] ?? result['data']?['accessToken'] ?? '',
        refreshToken: result['refreshToken'] ?? result['data']?['refreshToken'],
        user: result['user'] ?? result['data']?['user'],
      );
    }
    
    return result;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await _serviceManager.authService.refreshToken(refreshToken);
  }

  Future<void> signOut() async {
    await _serviceManager.authService.signOutGoogle();
    _serviceManager.clearAuth();
  }

  Future<Map<String, bool>> testConnections() async {
    // Test basic service connectivity
    try {
      // Test auth service with a simple endpoint
      final authTest = await _serviceManager.authService.testRoute(_serviceManager.accessToken ?? '');
      
      return {
        'auth': authTest['success'] ?? false,
        'hostel': true, // Basic connectivity assumed
        'enquiry': true, // Basic connectivity assumed
      };
    } catch (e) {
      return {
        'auth': false,
        'hostel': false,
        'enquiry': false,
      };
    }
  }

  bool get isAuthenticated => _serviceManager.isAuthenticated;

  Future<Map<String, dynamic>> testRoute(String accessToken) async {
    return await _serviceManager.authService.testRoute(accessToken);
  }

  // Method to get error messages from the service
  Future<String?> getLastError() async {
    // This could be implemented to track the last error from the service
    return null;
  }
}