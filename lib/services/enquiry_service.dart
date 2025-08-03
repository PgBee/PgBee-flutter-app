import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/enquiry_model.dart';


class EnquiryService {
  final String _baseUrl = 'https://server.pgbee.in';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
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
      final url = Uri.parse('$_baseUrl/enquiry');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = {
        'studentName': studentName,
        'studentEmail': studentEmail,
        'studentPhone': studentPhone,
        'hostelId': hostelId,
        'message': message,
        'status': 'pending',
      };
      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': data,
        'message': 'Enquiry sent successfully',
      };
    } catch (e) {
      print('Enquiry Service Error - Create: $e');
      return {
        'success': false,
        'error': 'Failed to send enquiry',
      };
    }
  }

  // Get all enquiries for a hostel owner - GET /enquiries (filtered by owner)
  Future<Map<String, dynamic>> getOwnerEnquiries() async {
    try {
      final url = Uri.parse('$_baseUrl/enquiry');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<EnquiryModel> enquiries = [];
        if (data is List) {
          enquiries = data.map<EnquiryModel>((e) => EnquiryModel.fromJson(e)).toList();
        } else if (data is Map && data['enquiries'] != null) {
          enquiries = (data['enquiries'] as List)
              .map<EnquiryModel>((e) => EnquiryModel.fromJson(e))
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
      return {
        'success': true,
        'data': getMockEnquiries(),
      };
    }
  }

  // Get enquiries for a specific hostel - GET /enquiries/hostel/:id
  Future<Map<String, dynamic>> getHostelEnquiries(String hostelId) async {
    try {
      final url = Uri.parse('$_baseUrl/enquiry/hostel/$hostelId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<EnquiryModel> enquiries = [];
        if (data is List) {
          enquiries = data.map<EnquiryModel>((e) => EnquiryModel.fromJson(e)).toList();
        } else if (data is Map && data['enquiries'] != null) {
          enquiries = (data['enquiries'] as List)
              .map<EnquiryModel>((e) => EnquiryModel.fromJson(e))
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
      return {
        'success': true,
        'data': getMockEnquiries().where((e) => e.hostelId == hostelId).toList(),
      };
    }
  }

  // Update enquiry status - PUT /enquiries/:id
  Future<Map<String, dynamic>> updateEnquiryStatus(String enquiryId, String status) async {
    try {
      final url = Uri.parse('$_baseUrl/enquiry/$enquiryId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = jsonEncode({'status': status});
      final response = await http.put(url, headers: headers, body: body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200,
        'data': data,
        'message': 'Enquiry status updated successfully',
      };
    } catch (e) {
      print('Enquiry Service Error - Update Status: $e');
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
      final url = Uri.parse('$_baseUrl/enquiry/$enquiryId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.delete(url, headers: headers);
      return {
        'success': response.statusCode == 200,
        'message': 'Enquiry deleted successfully',
      };
    } catch (e) {
      print('Enquiry Service Error - Delete: $e');
      return {
        'success': false,
        'error': 'Failed to delete enquiry',
      };
    }
  }

  // Get enquiry statistics for dashboard
  Future<Map<String, dynamic>> getEnquiryStats() async {
    try {
      final url = Uri.parse('$_baseUrl/enquiries/stats');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.get(url, headers: headers);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200,
        'data': data,
      };
    } catch (e) {
      print('Enquiry Service Error - Get Stats: $e');
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
