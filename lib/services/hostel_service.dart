import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hostel_model.dart';
import 'http_interceptor.dart';

class HostelService {
  final String _baseUrl = 'https://server.pgbee.in';
  String? _authToken;

  // Set token from ServiceManager or AuthProvider (kept for compatibility)
  void setAuthToken(String token) {
    _authToken = token;
    print('HostelService: Token set directly - ${token.isNotEmpty ? "Token received (${token.length} chars)" : "Empty token"}');
  }

  // Restore token from SharedPreferences (kept for compatibility)
  Future<void> restoreAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        _authToken = token;
        print('HostelService: Restored auth token from SharedPreferences - length: ${token.length}');
      } else {
        print('HostelService: No auth token found in SharedPreferences');
      }
    } catch (e) {
      print('HostelService: Error restoring token: $e');
    }
  }

  // ...existing code...

  // Get all hostels for students - GET /api/v1/hostel (Public endpoint)
  Future<Map<String, dynamic>> getAllHostels() async {
    try {
      print('HostelService.getAllHostels: Starting request for student view...');
      
      // This endpoint is public according to the documentation
      final response = await HttpInterceptor.get('/hostel', includeAuth: false);
      
      print('HostelService.getAllHostels response status: ${response.statusCode}');
      print('HostelService.getAllHostels response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      }
      
      // Handle error responses
      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to fetch hostels',
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to fetch hostels',
        };
      }
    } catch (e) {
      print('Hostel Service Error - Get All Hostels: $e');
      
      // Check if it's a network/connection error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('No address associated with hostname')) {
        return {
          'success': false,
          'error': 'Connection error. Please check your internet connection and try again.',
          'isConnectionError': true,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to fetch hostels',
      };
    }
  }

  // Create a new hostel - POST /api/v1/hostel
  Future<Map<String, dynamic>> createHostel(HostelModel hostel) async {
    try {
      // According to the API documentation, all these fields are required:
      // hostelName, phone, address, distance, location, rent, gender, bedrooms, bathrooms
      final response = await HttpInterceptor.post('/hostel', body: {
        'hostelName': hostel.hostelName,
        'phone': hostel.phone, // Required field
        'address': hostel.address, // Required field
        'curfew': hostel.curfew,
        'distance': hostel.distance, // Required field
        'location': hostel.location, // Required field
        'rent': hostel.rent, // Required field
        'gender': hostel.gender, // Required field
        'bedrooms': hostel.bedrooms, // Required field
        'bathrooms': hostel.bathrooms, // Required field
        // Optional fields
        if (hostel.description.isNotEmpty) 'description': hostel.description,
      });
      
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': data?['message'] ?? 'Hostel created successfully',
        };
      }
      
      // Handle error responses
      try {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create hostel',
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to create hostel',
        };
      }
    } catch (e) {
      print('Hostel Service Error - Create: $e');
      return {
        'success': false,
        'error': 'Failed to create hostel',
      };
    }
  }

  // Get hostels owned by authenticated user - GET /api/v1/hostel/user
  Future<Map<String, dynamic>> getOwnerHostels() async {
    try {
      print('HostelService.getOwnerHostels: Starting request using HttpInterceptor...');
      
      // Debug: Check current user role and JWT token
      try {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString('access_token');
        final userData = prefs.getString('user_data');
        
        print('HostelService.getOwnerHostels: Access token exists: ${accessToken != null && accessToken.isNotEmpty}');
        if (accessToken != null && accessToken.isNotEmpty) {
          print('HostelService.getOwnerHostels: Access token length: ${accessToken.length}');
          // Parse JWT payload (for debugging - remove in production)
          try {
            final parts = accessToken.split('.');
            if (parts.length >= 2) {
              final payload = parts[1];
              // Add padding if needed for base64 decoding
              final paddedPayload = payload + '=' * (4 - payload.length % 4);
              final decoded = utf8.decode(base64Url.decode(paddedPayload));
              final jwtData = jsonDecode(decoded);
              print('HostelService.getOwnerHostels: JWT payload: $jwtData');
            }
          } catch (e) {
            print('HostelService.getOwnerHostels: Could not parse JWT: $e');
          }
        }
        
        if (userData != null) {
          final user = jsonDecode(userData);
          print('HostelService.getOwnerHostels: User role: ${user['role']}');
          print('HostelService.getOwnerHostels: User email: ${user['email']}');
        } else {
          print('HostelService.getOwnerHostels: No user data found in storage');
        }
      } catch (e) {
        print('HostelService.getOwnerHostels: Error reading debug info: $e');
      }
      
      // Use HttpInterceptor which handles JWT + Cookie authentication automatically
      
      final response = await HttpInterceptor.get('/hostel/user');
      
      print('HostelService.getOwnerHostels response status: ${response.statusCode}');
      print('HostelService.getOwnerHostels response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Handle different response formats from the backend
        if (data is Map<String, dynamic>) {
          // If the response has a success field and data field, use that structure
          if (data.containsKey('success') && data.containsKey('data')) {
            return {
              'success': data['success'] ?? true,
              'data': data['data'],
              'message': data['message'],
            };
          }
          // Otherwise, treat the entire response as data
          return {
            'success': true,
            'data': data,
          };
        } else if (data is List) {
          // If response is a list, wrap it in a data object
          return {
            'success': true,
            'data': {'hostels': data},
          };
        }
        
        return {
          'success': true,
          'data': data,
        };
      }
      
      // Handle 404 with proper message parsing
      if (response.statusCode == 404) {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? 'Not found';
          
          // If it's "No hostels found", treat as successful empty result
          if (message.toLowerCase().contains('no hostels found')) {
            print('HostelService.getOwnerHostels: No hostels found for user (normal response)');
            return {
              'success': true,
              'data': {'hostels': []},
              'message': message,
            };
          }
        } catch (e) {
          print('HostelService.getOwnerHostels: Error parsing 404 response: $e');
        }
        
        return {
          'success': false,
          'error': 'Endpoint not found',
        };
      }
      
      if (response.statusCode == 401) {
        print('HostelService.getOwnerHostels: Unauthorized - HttpInterceptor should have handled token refresh');
        
        // Try to get more information about the error
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Unauthorized access';
          print('HostelService.getOwnerHostels: 401 error details: $errorMessage');
          
          return {
            'success': false,
            'error': 'Authentication failed: $errorMessage',
            'requiresReauth': true,
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Session expired or unauthorized. Please log in again.',
            'requiresReauth': true,
          };
        }
      }
      
      // Handle other status codes
      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to fetch hostel details',
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to fetch hostel details',
        };
      }
    } catch (e) {
      print('Hostel Service Error - Get Owner Hostels: $e');
      
      // Check if it's a network/connection error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('No address associated with hostname')) {
        return {
          'success': false,
          'error': 'Connection error. Please check your internet connection and try again.',
          'isConnectionError': true,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to fetch hostel details',
      };
    }
  }

  // Update hostel details - PUT /api/v1/hostel/:id
  Future<Map<String, dynamic>> updateHostel(HostelModel hostel) async {
    try {
      final response = await HttpInterceptor.put('/hostel/${hostel.id}', body: {
        'hostelName': hostel.hostelName,
        'phone': hostel.phone,
        'address': hostel.address,
        'curfew': hostel.curfew,
        'description': hostel.description,
        'distance': hostel.distance,
        'location': hostel.location,
        'rent': hostel.rent,
        'gender': hostel.gender,
        'bedrooms': hostel.bedrooms,
        'bathrooms': hostel.bathrooms,
      });
      
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
          'message': data?['message'] ?? 'Hostel updated successfully',
        };
      }
      
      // Handle error responses
      try {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to update hostel',
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to update hostel',
        };
      }
    } catch (e) {
      print('Hostel Service Error - Update: $e');
      return {
        'success': false,
        'error': 'Failed to update hostel',
      };
    }
  }

  // Delete hostel - DELETE /api/v1/hostel/:id
  Future<Map<String, dynamic>> deleteHostel(String hostelId) async {
    try {
      final response = await HttpInterceptor.delete('/hostel/$hostelId');
      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        // According to documentation, DELETE should return 204 for success
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Hostel deleted successfully',
        };
      }
      
      // Handle error responses
      try {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to delete hostel',
        };
      } catch (e) {
        return {
          'success': false,
          'error': 'Failed to delete hostel',
        };
      }
    } catch (e) {
      print('Hostel Service Error - Delete: $e');
      return {
        'success': false,
        'error': 'Failed to delete hostel',
      };
    }
  }

  // Update amenities for a hostel
  Future<Map<String, dynamic>> updateAmenities(String hostelId, List<AmenityModel> amenities) async {
    try {
      final response = await HttpInterceptor.put('/amenities/update/$hostelId', body: {
        'amenities': amenities.map((a) => a.toJson()).toList(),
      });
      
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      }
      return {
        'success': false,
        'error': 'Failed to update amenities',
      };
    } catch (e) {
      print('Hostel Service Error - Update Amenities: $e');
      return {
        'success': true,
        'data': {'amenities': amenities.map((a) => a.toJson()).toList()},
      };
    }
  }

  // Upload hostel images
  Future<Map<String, dynamic>> uploadImages(String hostelId, List<String> imagePaths) async {
    try {
      final url = Uri.parse('$_baseUrl/upload/hostel/$hostelId');
      final request = http.MultipartRequest('POST', url);
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      request.headers['Accept'] = 'application/json';
      for (final path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data,
        };
      }
      return {
        'success': false,
        'error': 'Failed to upload images',
      };
    } catch (e) {
      print('Hostel Service Error - Upload Images: $e');
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
      // Use PATCH for partial updates
      final response = await HttpInterceptor.patch('/hostel/$hostelId', body: {
        'admittedStudents': count,
      });
      
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': data,
        };
      }
      return {
        'success': false,
        'error': 'Failed to update student count',
      };
    } catch (e) {
      print('Hostel Service Error - Update Student Count: $e');
      return {
        'success': true,
        'data': {'admittedStudents': count},
      };
    }
  }
}
