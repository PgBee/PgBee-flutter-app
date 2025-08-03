// Debug script to test authentication and role assignment
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('=== DEBUG: Testing PgBee Authentication Flow ===\n');
  
  const baseUrl = 'https://server.pgbee.in';
  
  // Test 1: Register a new user with owner role
  print('1. Testing user registration with owner role...');
  
  final signupPayload = {
    'email': 'test_owner_${DateTime.now().millisecondsSinceEpoch}@test.com',
    'password': 'TestPassword123!',
    'role': 'owner',
    'name': 'Test Owner User',
    'phoneNo': '1234567890',
  };
  
  try {
    final signupResponse = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(signupPayload),
    );
    
    print('Signup Status: ${signupResponse.statusCode}');
    print('Signup Response: ${signupResponse.body}\n');
    
    if (signupResponse.statusCode == 200 || signupResponse.statusCode == 201) {
      final signupData = jsonDecode(signupResponse.body);
      final accessToken = signupData['accessToken'] ?? signupData['data']?['accessToken'];
      final userData = signupData['user'] ?? signupData['data']?['user'];
      
      print('Access Token: ${accessToken != null ? "Present (${accessToken.toString().length} chars)" : "Missing"}');
      print('User Data: $userData');
      
      if (userData != null) {
        print('User Role: ${userData['role']}');
        print('User Email: ${userData['email']}\n');
      }
      
      // Test 2: Try to access the owner hostel endpoint
      if (accessToken != null && accessToken.isNotEmpty) {
        print('2. Testing /hostel/user endpoint with JWT token...');
        
        final hostelResponse = await http.get(
          Uri.parse('$baseUrl/hostel/user'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
        
        print('Hostel Endpoint Status: ${hostelResponse.statusCode}');
        print('Hostel Endpoint Response: ${hostelResponse.body}\n');
        
        // Test 3: Parse JWT to see what's inside
        print('3. Analyzing JWT token...');
        try {
          final parts = accessToken.split('.');
          if (parts.length >= 2) {
            final payload = parts[1];
            // Add padding if needed for base64 decoding
            final paddedPayload = payload + '=' * (4 - payload.length % 4).toInt();
            final decoded = utf8.decode(base64Url.decode(paddedPayload));
            final jwtData = jsonDecode(decoded);
            print('JWT Payload: $jwtData');
            print('JWT Role: ${jwtData['role']}');
            print('JWT User ID: ${jwtData['id'] ?? jwtData['userId'] ?? jwtData['sub']}');
          }
        } catch (e) {
          print('Could not parse JWT: $e');
        }
      }
    } else {
      print('Registration failed. Trying to login with existing credentials...\n');
      
      // Test fallback: Try logging in with known credentials
      print('4. Testing login with existing credentials...');
      
      final loginPayload = {
        'email': 'kasinath.m00@gmail.com', // Replace with actual test email
        'password': 'kasinath', // Replace with actual test password
      };
      
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginPayload),
      );
      
      print('Login Status: ${loginResponse.statusCode}');
      print('Login Response: ${loginResponse.body}\n');
      
      if (loginResponse.statusCode == 200) {
        final loginData = jsonDecode(loginResponse.body);
        final accessToken = loginData['accessToken'] ?? loginData['data']?['accessToken'];
        final userData = loginData['user'] ?? loginData['data']?['user'];
        
        print('User Data after login: $userData');
        if (userData != null) {
          print('User Role: ${userData['role']}');
        }
        
        if (accessToken != null) {
          print('5. Testing /hostel/user with login token...');
          
          final hostelResponse = await http.get(
            Uri.parse('$baseUrl/hostel/user'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          );
          
          print('Hostel Endpoint Status: ${hostelResponse.statusCode}');
          print('Hostel Endpoint Response: ${hostelResponse.body}');
        }
      }
    }
  } catch (e) {
    print('Error during testing: $e');
  }
}
