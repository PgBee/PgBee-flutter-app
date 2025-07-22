import 'package:dio/dio.dart';
import 'package:pgbee/models/auth_model.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://example.com/api'));

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp(AuthModel user) async {
    try {
      final response = await _dio.post('/register', data: user.toJson());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}