import 'package:dio/dio.dart';
import '../models/enquiry_model.dart';

class EnquiryService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://server.pgbee.in'));
  
  // Set authorization header for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Create a new enquiry - POST /enquiries
  Future<Map<String, dynamic>> createEnquiry({
    required String studentName,
    required String studentEmail,
    required String studentPhone,
    required String hostelId,
    required String message,
  }) async {
    try {
      final response = await _dio.post('/enquiries', data: {
        'studentName': studentName,
        'studentEmail': studentEmail,
        'studentPhone': studentPhone,
        'hostelId': hostelId,
        'message': message,
        'status': 'pending',
      });

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': response.data,
        'message': 'Enquiry sent successfully',
      };
    } catch (e) {
      print('Enquiry Service Error - Create: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to send enquiry',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to send enquiry',
      };
    }
  }

  // Get all enquiries for a hostel owner - GET /enquiries (filtered by owner)
  Future<Map<String, dynamic>> getOwnerEnquiries() async {
    try {
      final response = await _dio.get('/enquiries');
      
      if (response.statusCode == 200) {
        // Parse the response data
        final data = response.data;
        List<EnquiryModel> enquiries = [];
        
        if (data is List) {
          enquiries = data.map((e) => EnquiryModel.fromJson(e)).toList();
        } else if (data is Map && data['enquiries'] != null) {
          enquiries = (data['enquiries'] as List)
              .map((e) => EnquiryModel.fromJson(e))
              .toList();
        }
        
        return {
          'success': true,
          'data': enquiries,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to fetch enquiries',
      };
    } catch (e) {
      print('Enquiry Service Error - Get Owner Enquiries: $e');
      
      // For testing purposes, return mock enquiries
      return {
        'success': true,
        'data': getMockEnquiries(),
      };
    }
  }

  // Get enquiries for a specific hostel - GET /enquiries/hostel/:id
  Future<Map<String, dynamic>> getHostelEnquiries(String hostelId) async {
    try {
      final response = await _dio.get('/enquiries/hostel/$hostelId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        List<EnquiryModel> enquiries = [];
        
        if (data is List) {
          enquiries = data.map((e) => EnquiryModel.fromJson(e)).toList();
        } else if (data is Map && data['enquiries'] != null) {
          enquiries = (data['enquiries'] as List)
              .map((e) => EnquiryModel.fromJson(e))
              .toList();
        }
        
        return {
          'success': true,
          'data': enquiries,
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to fetch hostel enquiries',
      };
    } catch (e) {
      print('Enquiry Service Error - Get Hostel Enquiries: $e');
      
      // Return mock data filtered by hostel
      return {
        'success': true,
        'data': getMockEnquiries().where((e) => e.hostelId == hostelId).toList(),
      };
    }
  }

  // Update enquiry status - PUT /enquiries/:id
  Future<Map<String, dynamic>> updateEnquiryStatus(String enquiryId, String status) async {
    try {
      final response = await _dio.put('/enquiries/$enquiryId', data: {
        'status': status,
      });

      return {
        'success': response.statusCode == 200,
        'data': response.data,
        'message': 'Enquiry status updated successfully',
      };
    } catch (e) {
      print('Enquiry Service Error - Update Status: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to update enquiry status',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update enquiry status',
      };
    }
  }

  // Accept an enquiry
  Future<Map<String, dynamic>> acceptEnquiry(String enquiryId) async {
    return await updateEnquiryStatus(enquiryId, 'accepted');
  }

  // Deny an enquiry
  Future<Map<String, dynamic>> denyEnquiry(String enquiryId) async {
    return await updateEnquiryStatus(enquiryId, 'denied');
  }

  // Delete an enquiry - DELETE /enquiries/:id
  Future<Map<String, dynamic>> deleteEnquiry(String enquiryId) async {
    try {
      final response = await _dio.delete('/enquiries/$enquiryId');

      return {
        'success': response.statusCode == 200,
        'message': 'Enquiry deleted successfully',
      };
    } catch (e) {
      print('Enquiry Service Error - Delete: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to delete enquiry',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to delete enquiry',
      };
    }
  }

  // Get enquiry statistics for dashboard
  Future<Map<String, dynamic>> getEnquiryStats() async {
    try {
      final response = await _dio.get('/enquiries/stats');
      
      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Enquiry Service Error - Get Stats: $e');
      
      // Return mock stats for testing
      return {
        'success': true,
        'data': {
          'total': 25,
          'pending': 8,
          'accepted': 12,
          'denied': 5,
        },
      };
    }
  }

  // Mock data for testing purposes
  List<EnquiryModel> getMockEnquiries() {
    return [
      EnquiryModel(
        id: 'enq_1',
        studentName: 'Alice Johnson',
        studentEmail: 'alice@email.com',
        studentPhone: '+91 9876543210',
        hostelId: 'hostel_1',
        hostelName: 'PG Bee Hostel',
        message: 'I am interested in booking a room. I am a final year engineering student looking for a peaceful place to study.',
        status: 'pending',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      EnquiryModel(
        id: 'enq_2',
        studentName: 'Bob Smith',
        studentEmail: 'bob@email.com',
        studentPhone: '+91 9876543211',
        hostelId: 'hostel_1',
        hostelName: 'PG Bee Hostel',
        message: 'Looking for accommodation near the university. I am a clean and responsible student.',
        status: 'pending',
        createdAt: DateTime.now().subtract(Duration(hours: 5)),
      ),
      EnquiryModel(
        id: 'enq_3',
        studentName: 'Carol Davis',
        studentEmail: 'carol@email.com',
        studentPhone: '+91 9876543212',
        hostelId: 'hostel_1',
        hostelName: 'PG Bee Hostel',
        message: 'I would like to visit the hostel and see the facilities. When can I schedule a visit?',
        status: 'accepted',
        createdAt: DateTime.now().subtract(Duration(days: 1)),
      ),
      EnquiryModel(
        id: 'enq_4',
        studentName: 'David Wilson',
        studentEmail: 'david@email.com',
        studentPhone: '+91 9876543213',
        hostelId: 'hostel_1',
        hostelName: 'PG Bee Hostel',
        message: 'Is WiFi available 24/7? I need it for my online classes.',
        status: 'accepted',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
      ),
      EnquiryModel(
        id: 'enq_5',
        studentName: 'Eva Brown',
        studentEmail: 'eva@email.com',
        studentPhone: '+91 9876543214',
        hostelId: 'hostel_1',
        hostelName: 'PG Bee Hostel',
        message: 'I need a hostel for just 3 months. Is short-term stay possible?',
        status: 'denied',
        createdAt: DateTime.now().subtract(Duration(days: 3)),
      ),
    ];
  }
}
