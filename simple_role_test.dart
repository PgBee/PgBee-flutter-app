// Simple role test script
import 'dart:convert';
import 'package:http/http.dart' as http;

String decodeJWT(String token) {
  try {
    final parts = token.split('.');
    if (parts.length >= 2) {
      final payload = parts[1];
      String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      final decoded = utf8.decode(base64.decode(normalized));
      return decoded;
    }
  } catch (e) {
    print('JWT decode error: $e');
  }
  return '{}';
}

Future<void> main() async {
  print('=== Simple Role Test ===\n');
  
  const baseUrl = 'http://192.168.1.73:8080';
  
  // Test with existing user
  print('Testing with existing user credentials...');
  
  final loginPayload = {

    'email': 'kasinathkv7@gmail.com',
    'password': '123456',


  };
  
  final loginResponse = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(loginPayload),
  );
  
  print('Login Status: ${loginResponse.statusCode}');
  print('Login Response: ${loginResponse.body}\n');
  
  if (loginResponse.statusCode == 200) {
    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['data']?['accessToken'] ?? loginData['accessToken'];
    
    if (token != null) {
      // Check JWT contents
      print('JWT Analysis:');
      final jwtPayload = decodeJWT(token);
      final jwtData = jsonDecode(jwtPayload);
      print('JWT Payload: $jwtData');
      print('JWT Role: ${jwtData['role'] ?? "NOT FOUND"}');
      print('JWT User ID: ${jwtData['userId'] ?? jwtData['id'] ?? jwtData['sub'] ?? "NOT FOUND"}\n');
      
      // Test /hostel/user endpoint
      print('Testing /hostel/user endpoint...');
      final hostelResponse = await http.get(
        Uri.parse('$baseUrl/hostel/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Hostel Status: ${hostelResponse.statusCode}');
      print('Hostel Response: ${hostelResponse.body}\n');
      
      // Test if it's a role issue - try other endpoints
      print('Testing other hostel endpoints...');
      
      // Test GET /hostel (should list all hostels)
      final allHostelsResponse = await http.get(
        Uri.parse('$baseUrl/hostel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('All Hostels Status: ${allHostelsResponse.statusCode}');
      print('All Hostels Response: ${allHostelsResponse.body}');
      
      // Create a test hostel to see if the issue is missing data
      print('\nTrying to create a test hostel...');
      final createHostelPayload = {
        'hostelName': 'Test Hostel',
        'curfew': true,
        'distance': 0,
        'location': 'ndcjdn',
        'address': '123 Test Street',
        'phone': '9876543210',
        'description': 'Test hostel description',
        'rent': 10000,
        'bedrooms': 1,
        'bathrooms': 2,
        'gender': 'male'
      };
      
      final createResponse = await http.post(
        Uri.parse('$baseUrl/hostel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(createHostelPayload),
      );
      
      print('Create Hostel Status: ${createResponse.statusCode}');
      print('Create Hostel Response: ${createResponse.body}');
    }
  }
}
