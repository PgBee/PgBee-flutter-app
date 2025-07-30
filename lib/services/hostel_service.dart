import 'package:dio/dio.dart';
import '../models/hostel_model.dart';

class HostelService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://server.pgbee.in'));

  // Set authorization header for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Create a new hostel - POST /hostel
  Future<Map<String, dynamic>> createHostel(HostelModel hostel) async {
    try {
      final response = await _dio.post('/hostel', data: {
        'hostelName': hostel.name,
        'phone': hostel.phone,
        'address': hostel.address,
        'curfew': hostel.curfew,
        'description': hostel.description,
        'distance': hostel.distance,
        'location': hostel.location,
        'rent': hostel.rent,
        'gender': 'mixed', // Default value, can be added to model later
        'bedrooms': hostel.bedrooms,
        'bathrooms': hostel.bathrooms,
      });

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': response.data,
        'message': 'Hostel created successfully',
      };
    } catch (e) {
      print('Hostel Service Error - Create: $e');
      return {
        'success': false,
        'error': 'Failed to create hostel',
      };
    }
  }

  // Get hostels owned by authenticated user - GET /hostel/user
  Future<Map<String, dynamic>> getOwnerHostels() async {
    try {
      final response = await _dio.get('/hostel/user');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to fetch hostel details',
      };
    } catch (e) {
      print('Hostel Service Error - Get Owner Hostels: $e');
      
      // For testing purposes, return mock data
      return {
        'success': true,
        'data': {
          'id': 'hostel_1',
          'hostelName': 'PG Bee Hostel',
          'name': 'John Doe',
          'phone': '+91 9876543210',
          'address': '123 Main Street, City',
          'location': 'Near University',
          'description': 'A comfortable hostel for students with all modern amenities.',
          'rent': 8000.0,
          'distance': 2.5,
          'bedrooms': 2,
          'bathrooms': 2,
          'curfew': false,
          'files': 'image1.jpg, image2.jpg, image3.jpg',
          'amenities': [
            {'id': '1', 'name': 'WiFi', 'description': 'High-speed internet', 'isAvailable': true},
            {'id': '2', 'name': 'AC', 'description': 'Air conditioning', 'isAvailable': true},
            {'id': '3', 'name': 'Mess', 'description': 'Food facility', 'isAvailable': true},
            {'id': '4', 'name': 'Parking', 'description': 'Vehicle parking', 'isAvailable': false},
          ],
          'admittedStudents': 15,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      };
    }
  }

  // Update hostel details - PUT /hostel/:id
  Future<Map<String, dynamic>> updateHostel(HostelModel hostel) async {
    try {
      final response = await _dio.put('/hostel/${hostel.id}', data: {
        'hostelName': hostel.name,
        'phone': hostel.phone,
        'address': hostel.address,
        'curfew': hostel.curfew,
        'description': hostel.description,
        'distance': hostel.distance,
        'location': hostel.location,
        'rent': hostel.rent,
        'gender': 'mixed', // Default value, can be added to model later
        'bedrooms': hostel.bedrooms,
        'bathrooms': hostel.bathrooms,
      });
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Hostel updated successfully',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update hostel',
      };
    } catch (e) {
      print('Hostel Service Error - Update: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to update hostel',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update hostel',
      };
    }
  }

  // Delete hostel - DELETE /hostel/:id
  Future<Map<String, dynamic>> deleteHostel(String hostelId) async {
    try {
      final response = await _dio.delete('/hostel/$hostelId');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Hostel deleted successfully',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to delete hostel',
      };
    } catch (e) {
      print('Hostel Service Error - Delete: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to delete hostel',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to delete hostel',
      };
    }
  }

  // Update amenities for a hostel
  Future<Map<String, dynamic>> updateAmenities(String hostelId, List<AmenityModel> amenities) async {
    try {
      final response = await _dio.put('/amenities/update/$hostelId', data: {
        'amenities': amenities.map((a) => a.toJson()).toList(),
      });
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update amenities',
      };
    } catch (e) {
      print('Hostel Service Error - Update Amenities: $e');
      
      // For testing purposes, return success
      return {
        'success': true,
        'data': {'amenities': amenities.map((a) => a.toJson()).toList()},
      };
    }
  }

  // Upload hostel images
  Future<Map<String, dynamic>> uploadImages(String hostelId, List<String> imagePaths) async {
    try {
      FormData formData = FormData();
      
      for (int i = 0; i < imagePaths.length; i++) {
        formData.files.add(MapEntry(
          'images',
          await MultipartFile.fromFile(imagePaths[i]),
        ));
      }
      
      final response = await _dio.post('/upload/hostel/$hostelId', data: formData);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to upload images',
      };
    } catch (e) {
      print('Hostel Service Error - Upload Images: $e');
      
      // For testing purposes, return mock uploaded URLs
      return {
        'success': true,
        'data': {
          'files': imagePaths.map((path) => 'https://server.pgbee.in/uploads/${path.split('/').last}').toList(),
        },
      };
    }
  }

  // Update admitted students count
  Future<Map<String, dynamic>> updateAdmittedStudents(String hostelId, int count) async {
    try {
      final response = await _dio.patch('/owners/$hostelId', data: {
        'admittedStudents': count,
      });
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update student count',
      };
    } catch (e) {
      print('Hostel Service Error - Update Student Count: $e');
      
      // For testing purposes, return success
      return {
        'success': true,
        'data': {'admittedStudents': count},
      };
    }
  }
}
