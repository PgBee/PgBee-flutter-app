import 'package:dio/dio.dart';

class OwnerService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://server.pgbee.in'));
  
  // Set authorization header for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Register as owner - POST /owner/owners
  Future<Map<String, dynamic>> registerOwner({
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _dio.post('/owner/owners', data: {
        'name': name,
        'phone': phone,
      });

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': response.data,
        'message': 'Owner registered successfully',
      };
    } catch (e) {
      print('Owner Service Error - Register: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to register as owner',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to register as owner',
      };
    }
  }

  // Get all owners - GET /owner/owners
  Future<Map<String, dynamic>> getAllOwners() async {
    try {
      final response = await _dio.get('/owner/owners');

      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Owner Service Error - Get All: $e');
      return {
        'success': false,
        'error': 'Failed to fetch owners',
      };
    }
  }

  // Get owner by ID - GET /owner/owners/:id
  Future<Map<String, dynamic>> getOwnerById(String id) async {
    try {
      final response = await _dio.get('/owner/owners/$id');

      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Owner Service Error - Get By ID: $e');
      
      if (e is DioException && e.response?.statusCode == 404) {
        return {
          'success': false,
          'error': 'Owner not found',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to fetch owner details',
      };
    }
  }

  // Update owner profile - PUT /owner/owners/:id
  Future<Map<String, dynamic>> updateOwner({
    required String id,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _dio.put('/owner/owners/$id', data: {
        'name': name,
        'phone': phone,
      });

      return {
        'success': response.statusCode == 200,
        'data': response.data,
        'message': 'Owner profile updated successfully',
      };
    } catch (e) {
      print('Owner Service Error - Update: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to update owner profile',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update owner profile',
      };
    }
  }

  // Delete owner - DELETE /owner/owners/:id
  Future<Map<String, dynamic>> deleteOwner(String id) async {
    try {
      final response = await _dio.delete('/owner/owners/$id');

      return {
        'success': response.statusCode == 200 || response.statusCode == 204,
        'message': 'Owner deleted successfully',
      };
    } catch (e) {
      print('Owner Service Error - Delete: $e');
      
      if (e is DioException && e.response?.statusCode == 404) {
        return {
          'success': false,
          'error': 'Owner not found',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to delete owner',
      };
    }
  }

  // Mock data for testing when backend is unavailable
  static final Map<String, dynamic> mockOwnerData = {
    'id': 'owner_1',
    'name': 'John Doe',
    'phone': '9876543210',
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  // Get mock owner data for testing
  Map<String, dynamic> getMockOwnerData() {
    return {
      'success': true,
      'data': mockOwnerData,
    };
  }
}
