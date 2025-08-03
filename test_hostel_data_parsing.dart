import 'dart:convert';
import 'lib/models/hostel_model.dart';

void main() async {
  print('Testing hostel data parsing with actual API response structure...');
  
  // Simulate the API response structure from the backend
  final mockApiResponse = {
    "statusCode": 200,
    "status": "success",
    "message": "Hostels fetched successfully",
    "data": {
      "hostels": [
        {
          "id": "5fe81fb4d8e4f93c6c123456",
          "hostelName": "JJ",
          "phone": "9876543210",
          "address": "Test Address, Test City",
          "location": "Test Location",
          "bedrooms": 10,
          "bathrooms": 5,
          "curfew": false,
          "gender": "mixed",
          "files": "",
          "admittedStudents": 0,
          "createdAt": "2024-12-30T10:00:00.000Z",
          "updatedAt": "2024-12-30T10:00:00.000Z",
          "User": {
            "name": "Test Owner"
          },
          "Ammenity": {
            "id": "67733465a7b83c12345",
            "wifi": true,
            "ac": false,
            "mess": true,
            "firstaid": false,
            "currentbill": true,
            "waterbill": false
          }
        }
      ]
    }
  };
  
  try {
    print('Raw API response structure:');
    print(json.encode(mockApiResponse));
    print('\n---\n');
    
    // Test the data parsing logic (similar to what's in HostelProvider)
    final Map<String, dynamic> responseData = mockApiResponse['data'] as Map<String, dynamic>;
    
    if (responseData.containsKey('hostels')) {
      final List<dynamic> hostelsData = responseData['hostels'] as List<dynamic>;
      print('Found hostels array with ${hostelsData.length} hostel(s)');
      
      if (hostelsData.isNotEmpty) {
        final hostelJson = hostelsData.first as Map<String, dynamic>;
        print('First hostel JSON:');
        print(json.encode(hostelJson));
        print('\n---\n');
        
        // Test HostelModel.fromJson parsing
        final hostel = HostelModel.fromJson(hostelJson);
        
        print('Parsed HostelModel:');
        print('ID: ${hostel.id}');
        print('Name: ${hostel.hostelName}');
        print('Owner: ${hostel.ownerName}');
        print('Phone: ${hostel.phone}');
        print('Address: ${hostel.address}');
        print('Location: ${hostel.location}');
        print('Bedrooms: ${hostel.bedrooms}');
        print('Bathrooms: ${hostel.bathrooms}');
        print('Curfew: ${hostel.curfew}');
        print('Gender: ${hostel.gender}');
        print('Amenities count: ${hostel.amenities.length}');
        
        if (hostel.amenities.isNotEmpty) {
          print('Amenities:');
          for (final amenity in hostel.amenities) {
            print('  - ${amenity.name}: ${amenity.isAvailable}');
          }
        }
        
        print('\n✅ Hostel data parsing successful!');
      } else {
        print('❌ Hostels array is empty');
      }
    } else {
      print('❌ No hostels key found in response data');
    }
    
  } catch (e) {
    print('❌ Error parsing hostel data: $e');
  }
}
