import 'package:http/http.dart' as http;
import 'dart:convert';

class OwnerService {
  final String _baseUrl = 'https://server.pgbee.in';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  // Register as owner - POST /owner/owners
  Future<Map<String, dynamic>> registerOwner({
    required String name,
    required String phone,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/owner/owners');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = jsonEncode({
        'name': name,
        'phone': phone,
      });
      final response = await http.post(url, headers: headers, body: body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': data,
        'message': 'Owner registered successfully',
      };
    } catch (e) {
      print('Owner Service Error - Register: $e');
      return {
        'success': false,
        'error': 'Failed to register as owner',
      };
    }
  }

  // Get all owners - GET /owner/owners
  Future<Map<String, dynamic>> getAllOwners() async {
    try {
      final url = Uri.parse('$_baseUrl/owner/owners');
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
      final url = Uri.parse('$_baseUrl/owner/owners/$id');
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
          'error': 'Owner not found',
        };
      }
      return {
        'success': response.statusCode == 200,
        'data': data,
      };
    } catch (e) {
      print('Owner Service Error - Get By ID: $e');
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
      final url = Uri.parse('$_baseUrl/owner/owners/$id');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = jsonEncode({
        'name': name,
        'phone': phone,
      });
      final response = await http.put(url, headers: headers, body: body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200,
        'data': data,
        'message': 'Owner profile updated successfully',
      };
    } catch (e) {
      print('Owner Service Error - Update: $e');
      return {
        'success': false,
        'error': 'Failed to update owner profile',
      };
    }
  }

  // Delete owner - DELETE /owner/owners/:id
  Future<Map<String, dynamic>> deleteOwner(String id) async {
    try {
      final url = Uri.parse('$_baseUrl/owner/owners/$id');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Owner not found',
        };
      }
      return {
        'success': response.statusCode == 200 || response.statusCode == 204,
        'message': 'Owner deleted successfully',
      };
    } catch (e) {
      print('Owner Service Error - Delete: $e');
      return {
        'success': false,
        'error': 'Failed to delete owner',
      };
    }
  }

  // Mock data for testing when backend is unavailable
  final Map<String, dynamic> mockOwnerData = {
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
