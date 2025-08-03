// Test script to find working hostel endpoints
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('=== Testing Available Hostel Endpoints ===\n');
  
  const baseUrl = 'https://server.pgbee.in';
  
  // First login to get a token
  final loginResponse = await http.post(
    Uri.parse('$baseUrl/auth/signin'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'kasinathkv8@gmail.com',
      'password': 'kasinath',
    }),
  );
  
  if (loginResponse.statusCode != 200) {
    print('Login failed: ${loginResponse.body}');
    return;
  }
  
  final loginData = jsonDecode(loginResponse.body);
  final accessToken = loginData['data']?['accessToken'];
  
  if (accessToken == null) {
    print('No access token received');
    return;
  }
  
  print('Login successful, testing endpoints...\n');
  
  // Test various endpoint variations
  final endpointsToTest = [
    '/hostel/user',
    '/hostel/owner',
    '/hostel',
    '/hostel/user',
    '/hostel/owner', 
    '/hostel',
    '/hostel/user',
    '/hostel/owner',
    '/hostel',
    '/hostel/user',
    '/hostel/owner',
    '/hostels/user',
    '/hostels',
  ];
  
  for (final endpoint in endpointsToTest) {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      
      print('$endpoint: ${response.statusCode}');
      if (response.statusCode != 404) {
        print('  Response: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
      }
      print('');
    } catch (e) {
      print('$endpoint: ERROR - $e\n');
    }
  }
}
