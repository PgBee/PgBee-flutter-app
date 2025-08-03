// Debug script to check current authentication state
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  print('=== Debug Auth State ===\n');
  
  // Check stored tokens
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');
  final refreshToken = prefs.getString('refresh_token');
  final authCookies = prefs.getString('auth_cookies');
  
  print('Stored Authentication Data:');
  print('Access Token: ${accessToken ?? "NOT FOUND"}');
  if (accessToken != null) {
    print('Access Token Length: ${accessToken.length}');
  }
  print('Refresh Token: ${refreshToken ?? "NOT FOUND"}');
  print('Auth Cookies: ${authCookies ?? "NOT FOUND"}\n');
  
  // Test login to get fresh token (like simple_role_test.dart)
  print('Testing fresh login...');
  const baseUrl = 'https://server.pgbee.in';
  
  final loginPayload = {
    'email': 'kasinathkv7@gmail.com',
    'password': '123456',
  };
  
  final loginResponse = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(loginPayload),
  );
  
  print('Fresh Login Status: ${loginResponse.statusCode}');
  
  if (loginResponse.statusCode == 200) {
    final loginData = jsonDecode(loginResponse.body);
    final freshToken = loginData['data']?['accessToken'] ?? loginData['accessToken'];
    
    print('Fresh Token: ${freshToken ?? "NOT FOUND"}');
    if (freshToken != null) {
      print('Fresh Token Length: ${freshToken.length}');
      
      // Test if fresh token works for hostel endpoint
      print('\nTesting fresh token with hostel endpoint...');
      final hostelResponse = await http.get(
        Uri.parse('$baseUrl/hostel/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $freshToken',
        },
      );
      
      print('Hostel Endpoint Status: ${hostelResponse.statusCode}');
      print('Hostel Endpoint Response: ${hostelResponse.body}');
      
      // Compare stored token vs fresh token
      if (accessToken != null && accessToken != freshToken) {
        print('\n⚠️  ISSUE FOUND: Stored token differs from fresh token!');
        print('Stored:  $accessToken');
        print('Fresh:   $freshToken');
      } else if (accessToken == freshToken) {
        print('\n✅ Stored token matches fresh token');
      } else {
        print('\n⚠️  No stored token found');
      }
    }
  }
}
