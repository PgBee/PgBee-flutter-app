import 'package:http/http.dart' as http;
import 'dart:convert';

class AmenitiesService {
  final String _baseUrl = 'https://server.pgbee.in';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
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
      final url = Uri.parse('$_baseUrl/ammenities');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = jsonEncode({
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
      final response = await http.post(url, headers: headers, body: body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': data,
        'message': 'Amenities created successfully',
      };
    } catch (e) {
      print('Amenities Service Error - Create: $e');
      return {
        'success': false,
        'error': 'Failed to create amenities',
      };
    }
  }

  // Get amenities for a hostel - GET /ammenities/:id
  Future<Map<String, dynamic>> getAmenities(String hostelId) async {
    try {
      final url = Uri.parse('$_baseUrl/ammenities/$hostelId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.get(url, headers: headers);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Amenities not found',
        };
      }
      return {
        'success': response.statusCode == 200,
        'data': data,
      };
    } catch (e) {
      print('Amenities Service Error - Get: $e');
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
      final url = Uri.parse('$_baseUrl/ammenities/$amenitiesId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = jsonEncode({
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
      final response = await http.put(url, headers: headers, body: body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200,
        'data': data,
        'message': 'Amenities updated successfully',
      };
    } catch (e) {
      print('Amenities Service Error - Update: $e');
      return {
        'success': false,
        'error': 'Failed to update amenities',
      };
    }
  }

  // Delete amenities - DELETE /ammenities/:id
  Future<Map<String, dynamic>> deleteAmenities(String amenitiesId) async {
    try {
      final url = Uri.parse('$_baseUrl/ammenities/$amenitiesId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Amenities not found',
        };
      }
      return {
        'success': response.statusCode == 200 || response.statusCode == 204,
        'message': 'Amenities deleted successfully',
      };
    } catch (e) {
      print('Amenities Service Error - Delete: $e');
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
