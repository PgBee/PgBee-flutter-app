import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing 404 handling for hostel endpoint...');
  
  // Test the /hostel/user endpoint directly
  try {
    final url = Uri.parse('https://server.pgbee.in/hostel/user');
    
    // Create a client with cookies
    final client = http.Client();
    
    print('Making request to: $url');
    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('Response status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 404) {
      try {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Not found';
        print('Parsed 404 message: $message');
        
        if (message.toLowerCase().contains('no hostels found')) {
          print('✅ 404 response contains "no hostels found" - should show empty state UI');
        } else {
          print('❌ 404 response does not contain "no hostels found"');
        }
      } catch (e) {
        print('❌ Could not parse 404 response body: $e');
      }
    } else if (response.statusCode == 401) {
      print('🔒 Got 401 Unauthorized - authentication required');
    } else {
      print('📝 Got response code ${response.statusCode}');
    }
    
    client.close();
  } catch (e) {
    print('❌ Error making request: $e');
  }
  
  print('\nTest completed!');
}
