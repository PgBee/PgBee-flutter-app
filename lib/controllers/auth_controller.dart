import 'package:pgbee/models/auth_model.dart';
import 'package:pgbee/services/auth_service.dart';

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Future<bool> login(String email, String password) => _authService.signIn(email, password);
  Future<bool> register(AuthModel user) => _authService.signUp(user);
}