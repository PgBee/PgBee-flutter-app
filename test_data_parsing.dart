import 'dart:convert';
import 'lib/models/hostel_model.dart';

void main() {
  // This is the exact backend response from the user's logs
  final responseBody = '''{"ok":true,"message":"Hostels fetched successfully","data":{"hostels":[{"id":"5fe81fb4-f117-4ce2-b725-ee72e0fee3a7","hostelName":"JJ","phone":"9526569001","distance":null,"curfew":false,"address":"Durga lane 1 ,house no 34 Sasthankonam,near KTU ,Sreekaryam P O. Pin 695017","gender":"men","location":"https://maps.app.goo.gl/ffjb74j7srMAc56C9","available":true,"bathrooms":1,"bedrooms":1,"createdAt":"2025-08-01T18:07:40.985Z","updatedAt":"2025-08-01T18:07:40.985Z","userId":"035dfc01-1612-4217-a616-40dfc9c8a91e","User":{"id":"035dfc01-1612-4217-a616-40dfc9c8a91e","name":"Geetha S","email":"geetajayan560@gmail.com","phoneNo":"9526569001","Owner":{"id":"55d8e354-c5f4-498a-9004-4543463f7eb2","name":"Geetha S","phone":"9526569001"}},"Reviews":[],"Ammenity":{"id":"b091d809-0aef-4542-acbf-da2947a626b8","wifi":true,"ac":false,"kitchen":false,"mess":false,"parking":false,"laundry":false,"tv":false,"firstAid":false,"workspace":false,"security":false,"currentBill":false,"waterBill":true}}]}}''';
  
  print('Testing hostel data parsing...');
  
  try {
    final response = jsonDecode(responseBody);
    print('Response parsed successfully');
    
    final hostelsData = response['data'];
    if (hostelsData is Map && hostelsData.containsKey('hostels')) {
      final hostelsList = hostelsData['hostels'] as List<dynamic>;
      print('Found ${hostelsList.length} hostels');
      
      if (hostelsList.isNotEmpty) {
        final firstHostelData = hostelsList.first;
        print('First hostel raw data: $firstHostelData');
        
        final hostel = HostelModel.fromJson(Map<String, dynamic>.from(firstHostelData));
        print('\nParsed hostel details:');
        print('- Name: ${hostel.hostelName}');
        print('- Phone: ${hostel.phone}');
        print('- Address: ${hostel.address}');
        print('- Location: ${hostel.location}');
        print('- Gender: ${hostel.gender}');
        print('- Bedrooms: ${hostel.bedrooms}');
        print('- Bathrooms: ${hostel.bathrooms}');
        print('- Curfew: ${hostel.curfew}');
        print('- Owner: ${hostel.ownerName}');
        
        // Test if the data would show in form fields
        print('\nForm field test:');
        print('- hostelNameController would show: "${hostel.hostelName}"');
        print('- phoneController would show: "${hostel.phone}"');
        print('- addressController would show: "${hostel.address}"');
        
        if (hostel.hostelName.isEmpty || hostel.phone.isEmpty || hostel.address.isEmpty) {
          print('\n❌ ERROR: Some fields are empty after parsing!');
        } else {
          print('\n✅ SUCCESS: All main fields have data!');
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
