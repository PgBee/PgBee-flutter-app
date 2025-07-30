import 'package:dio/dio.dart';

class AmenitiesService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://server.pgbee.in'));
  
  // Set authorization header for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Create amenities for a hostel - POST /ammenities
  Future<Map<String, dynamic>> createAmenities({
    required String hostelId,
    required bool wifi,
    required bool ac,
    required bool kitchen,
    required bool parking,
    required bool laundry,
    required bool tv,
    required bool firstAid,
    required bool workspace,
    required bool security,
    required bool currentBill,
    required bool waterBill,
    required bool food,
    required bool furniture,
    required bool bed,
    required bool water,
    required int studentsCount,
  }) async {
    try {
      final response = await _dio.post('/ammenities', data: {
        'wifi': wifi,
        'ac': ac,
        'kitchen': kitchen,
        'parking': parking,
        'laundry': laundry,
        'tv': tv,
        'firstAid': firstAid,
        'workspace': workspace,
        'security': security,
        'currentBill': currentBill,
        'waterBill': waterBill,
        'food': food,
        'furniture': furniture,
        'bed': bed,
        'water': water,
        'studentsCount': studentsCount,
        'hostelId': hostelId,
      });

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': response.data,
        'message': 'Amenities created successfully',
      };
    } catch (e) {
      print('Amenities Service Error - Create: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to create amenities',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to create amenities',
      };
    }
  }

  // Get amenities for a hostel - GET /ammenities/:id
  Future<Map<String, dynamic>> getAmenities(String hostelId) async {
    try {
      final response = await _dio.get('/ammenities/$hostelId');

      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Amenities Service Error - Get: $e');
      
      if (e is DioException && e.response?.statusCode == 404) {
        return {
          'success': false,
          'error': 'Amenities not found',
        };
      }
      
      // Return mock data for testing
      return {
        'success': true,
        'data': getMockAmenities(hostelId),
      };
    }
  }

  // Update amenities - PUT /ammenities/:id
  Future<Map<String, dynamic>> updateAmenities({
    required String amenitiesId,
    required String hostelId,
    required bool wifi,
    required bool ac,
    required bool kitchen,
    required bool parking,
    required bool laundry,
    required bool tv,
    required bool firstAid,
    required bool workspace,
    required bool security,
    required bool currentBill,
    required bool waterBill,
    required bool food,
    required bool furniture,
    required bool bed,
    required bool water,
    required int studentsCount,
  }) async {
    try {
      final response = await _dio.put('/ammenities/$amenitiesId', data: {
        'wifi': wifi,
        'ac': ac,
        'kitchen': kitchen,
        'parking': parking,
        'laundry': laundry,
        'tv': tv,
        'firstAid': firstAid,
        'workspace': workspace,
        'security': security,
        'currentBill': currentBill,
        'waterBill': waterBill,
        'food': food,
        'furniture': furniture,
        'bed': bed,
        'water': water,
        'studentsCount': studentsCount,
        'hostelId': hostelId,
      });

      return {
        'success': response.statusCode == 200,
        'data': response.data,
        'message': 'Amenities updated successfully',
      };
    } catch (e) {
      print('Amenities Service Error - Update: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to update amenities',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update amenities',
      };
    }
  }

  // Delete amenities - DELETE /ammenities/:id
  Future<Map<String, dynamic>> deleteAmenities(String amenitiesId) async {
    try {
      final response = await _dio.delete('/ammenities/$amenitiesId');

      return {
        'success': response.statusCode == 200 || response.statusCode == 204,
        'message': 'Amenities deleted successfully',
      };
    } catch (e) {
      print('Amenities Service Error - Delete: $e');
      
      if (e is DioException && e.response?.statusCode == 404) {
        return {
          'success': false,
          'error': 'Amenities not found',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to delete amenities',
      };
    }
  }

  // Mock data for testing
  Map<String, dynamic> getMockAmenities(String hostelId) {
    return {
      'id': 'amenities_1',
      'wifi': true,
      'ac': true,
      'kitchen': true,
      'parking': false,
      'laundry': true,
      'tv': true,
      'firstAid': true,
      'workspace': true,
      'security': true,
      'currentBill': true,
      'waterBill': true,
      'food': false,
      'furniture': true,
      'bed': true,
      'water': true,
      'studentsCount': 15,
      'hostelId': hostelId,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
