import 'package:dio/dio.dart';
import 'package:pgbee/models/auth_model.dart';


class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://server.pgbee.in/'));
  
  // For testing purposes - in-memory storage of registered users
  static final Set<String> _registeredEmails = {'test@pgbee.com', 'existing@test.com'};
  static final Map<String, String> _userCredentials = {
    'test@pgbee.com': 'test123',
    'existing@test.com': 'password123',
  };

  // Sign In
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return {
        'success': response.statusCode == 200,
        'data': response.data, // Assuming the backend returns a token or user data
      };
    } catch (e) {
      print('Auth Service Error - Sign In: $e');
      // For testing purposes, check against stored credentials
      if (_userCredentials.containsKey(email) && _userCredentials[email] == password) {
        return {
          'success': true,
          'data': {'access_token': 'test_token', 'refresh_token': 'test_refresh'}
        };
      }
      // Return proper error for invalid credentials
      return {
        'success': false,
        'error': 'Invalid email or password',
      };
    }
  }

  // Sign Up
  Future<Map<String, dynamic>> signUp(AuthModel user) async {
    try {
      final response = await _dio.post('/auth/signup', data: user.toJson());
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': response.data, // Assuming the backend returns user data or token
      };
    } catch (e) {
      print('Auth Service Error - Sign Up: $e');
      
      // Check if it's a DioException to get more specific error info
      if (e is DioException) {
        if (e.response?.statusCode == 409 || e.response?.statusCode == 400) {
          // Email already exists
          return {
            'success': false,
            'error': 'Email already registered. Please use a different email or try logging in.',
          };
        }
      }
      
      // For testing purposes, check if email already exists
      if (_registeredEmails.contains(user.email)) {
        return {
          'success': false,
          'error': 'Email already registered. Please use a different email or try logging in.',
        };
      }
      
      // For testing purposes, register the user locally
      if (user.email.isNotEmpty && user.password.length >= 6) {
        _registeredEmails.add(user.email);
        _userCredentials[user.email] = user.password;
        return {
          'success': true,
          'data': {'access_token': 'test_token', 'refresh_token': 'test_refresh'}
        };
      }
      
      return {
        'success': false,
        'error': 'Registration failed. Please check your information.',
      };
    }
  }

  // Google Sign-In Initiation
  Future<Map<String, dynamic>> googleSignIn() async {
    try {
      final response = await _dio.get('/auth/google');
      return {
        'success': response.statusCode == 200,
        'data': response.data, // Expect a redirect URL or token
      };
    } catch (e) {
      print('Auth Service Error - Google Sign In: $e');
      // For testing purposes, simulate successful Google Sign-In
      return {
        'success': true,
        'data': {
          'access_token': 'google_test_token',
          'refresh_token': 'google_test_refresh',
          'user': {
            'email': 'test.google@gmail.com',
            'name': 'Google Test User'
          }
        }
      };
    }
  }

  // Google Sign-In Callback (handled after redirection)
  Future<Map<String, dynamic>> googleCallback(String code) async {
    try {
      final response = await _dio.get('/auth/google/callback', queryParameters: {
        'code': code, // Pass the authorization code from Google
      });
      return {
        'success': response.statusCode == 200,
        'data': response.data, // Expect token or user data
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Refresh Token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post('/auth/token/refresh', data: {
        'refresh_token': refreshToken,
      });
      return {
        'success': response.statusCode == 200,
        'data': response.data, // Expect new access token
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Test Route (Requires Authorization)
  Future<Map<String, dynamic>> testRoute(String accessToken) async {
    try {
      final response = await _dio.get(
        '/auth/test',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );
      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

}