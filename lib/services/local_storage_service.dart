import 'package:hive_flutter/hive_flutter.dart';
import '../models/hostel_model.dart';
import '../models/enquiry_model.dart';

class LocalStorageService {
  static const String _hostelBoxName = 'hostels';
  static const String _enquiryBoxName = 'enquiries';
  static const String _settingsBoxName = 'settings';
  
  static Box<Map>? _hostelBox;
  static Box<Map>? _enquiryBox;
  static Box<Map>? _settingsBox;

  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    
    try {
      _hostelBox = await Hive.openBox<Map>(_hostelBoxName);
      _enquiryBox = await Hive.openBox<Map>(_enquiryBoxName);
      _settingsBox = await Hive.openBox<Map>(_settingsBoxName);
      print('Hive local storage initialized successfully');
    } catch (e) {
      print('Failed to initialize Hive: $e');
    }
  }

  // Hostel-related methods
  static Future<void> saveHostel(HostelModel hostel) async {
    try {
      // Ensure the data matches the backend structure
      final hostelData = hostel.toJson();
      
      // Ensure files is stored as a comma-separated string
      if (hostelData['files'] is List) {
        hostelData['files'] = (hostelData['files'] as List).join(',');
      }
      
      await _hostelBox?.put(hostel.id, hostelData);
      print('Hostel saved to local storage: ${hostel.id}');
    } catch (e) {
      print('Error saving hostel to local storage: $e');
    }
  }

  static Future<List<HostelModel>> getHostels() async {
    try {
      final box = _hostelBox;
      if (box == null) return [];
      final hostels = <HostelModel>[];
      for (final value in box.values) {
        try {
          // Ensure type casting to Map<String, dynamic> with proper checking
          Map<String, dynamic> map;
          if (value is Map<String, dynamic>) {
            map = value;
          } else if (value is Map) {
            // More robust casting for dynamic maps
            map = Map<String, dynamic>();
            value.forEach((key, val) {
              map[key.toString()] = val;
            });
          } else {
            print('LocalStorage: Skipping invalid hostel data type: ${value.runtimeType}');
            continue;
          }
          hostels.add(HostelModel.fromJson(map));
        } catch (e) {
          print('LocalStorage: Error processing hostel data: $e');
          continue;
        }
      }
      return hostels;
    } catch (e) {
      print('Error loading hostels from local storage: $e');
      return [];
    }
  }

  static Future<HostelModel?> getHostel(String hostelId) async {
    try {
      final data = _hostelBox?.get(hostelId);
      if (data != null) {
        if (data is Map<String, dynamic>) {
          return HostelModel.fromJson(data);
        } else {
          return HostelModel.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (e) {
      print('Error loading hostel from local storage: $e');
    }
    return null;
  }

  static Future<void> deleteHostel(String hostelId) async {
    try {
      await _hostelBox?.delete(hostelId);
      print('Hostel deleted from local storage: $hostelId');
    } catch (e) {
      print('Error deleting hostel from local storage: $e');
    }
  }

  // Enquiry-related methods
  static Future<void> saveEnquiry(EnquiryModel enquiry) async {
    try {
      await _enquiryBox?.put(enquiry.id, enquiry.toJson());
      print('Enquiry saved to local storage: ${enquiry.id}');
    } catch (e) {
      print('Error saving enquiry to local storage: $e');
    }
  }

  static Future<List<EnquiryModel>> getEnquiries() async {
    try {
      final enquiries = <EnquiryModel>[];
      final values = _enquiryBox?.values ?? [];
      
      for (final value in values) {
        if (value is Map<String, dynamic>) {
          enquiries.add(EnquiryModel.fromJson(value));
        } else {
          enquiries.add(EnquiryModel.fromJson(Map<String, dynamic>.from(value)));
        }
      }
      
      return enquiries;
    } catch (e) {
      print('Error loading enquiries from local storage: $e');
      return [];
    }
  }

  static Future<void> updateEnquiry(EnquiryModel enquiry) async {
    try {
      await _enquiryBox?.put(enquiry.id, enquiry.toJson());
      print('Enquiry updated in local storage: ${enquiry.id}');
    } catch (e) {
      print('Error updating enquiry in local storage: $e');
    }
  }

  static Future<void> deleteEnquiry(String enquiryId) async {
    try {
      await _enquiryBox?.delete(enquiryId);
      print('Enquiry deleted from local storage: $enquiryId');
    } catch (e) {
      print('Error deleting enquiry from local storage: $e');
    }
  }

  // Settings and general data
  static Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox?.put(key, {'value': value, 'timestamp': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Error saving setting to local storage: $e');
    }
  }

  static Future<T?> getSetting<T>(String key) async {
    try {
      final data = _settingsBox?.get(key);
      if (data != null && data.containsKey('value')) {
        return data['value'] as T?;
      }
    } catch (e) {
      print('Error loading setting from local storage: $e');
    }
    return null;
  }

  // Admitted students counter methods
  static const String _admittedStudentsKey = 'admitted_students_count';

  static Future<int> getAdmittedStudentsCount() async {
    try {
      final count = await getSetting<int>(_admittedStudentsKey);
      return count ?? 0;
    } catch (e) {
      print('Error getting admitted students count: $e');
      return 0;
    }
  }

  static Future<void> setAdmittedStudentsCount(int count) async {
    try {
      await saveSetting(_admittedStudentsKey, count);
      print('Admitted students count set to: $count');
    } catch (e) {
      print('Error setting admitted students count: $e');
    }
  }

  static Future<void> incrementAdmittedStudents() async {
    try {
      final currentCount = await getAdmittedStudentsCount();
      await setAdmittedStudentsCount(currentCount + 1);
      print('Admitted students count incremented to: ${currentCount + 1}');
    } catch (e) {
      print('Error incrementing admitted students count: $e');
    }
  }

  static Future<void> decrementAdmittedStudents() async {
    try {
      final currentCount = await getAdmittedStudentsCount();
      if (currentCount > 0) {
        await setAdmittedStudentsCount(currentCount - 1);
        print('Admitted students count decremented to: ${currentCount - 1}');
      }
    } catch (e) {
      print('Error decrementing admitted students count: $e');
    }
  }

  // Fallback mode settings
  static const String _fallbackModeKey = 'fallback_mode';

  static Future<bool> isFallbackMode() async {
    try {
      final isEnabled = await getSetting<bool>(_fallbackModeKey);
      return isEnabled ?? false;
    } catch (e) {
      print('Error checking fallback mode: $e');
      return false;
    }
  }

  static Future<void> setFallbackMode(bool enabled) async {
    try {
      await saveSetting(_fallbackModeKey, enabled);
      print('Fallback mode set to: $enabled');
    } catch (e) {
      print('Error setting fallback mode: $e');
    }
  }

  // Save local image paths for a hostel
  static Future<void> saveLocalImages(String hostelId, List<String> imagePaths) async {
    try {
      final key = 'local_images_$hostelId';
      await saveSetting(key, imagePaths);
      print('Local images saved for hostel: $hostelId');
    } catch (e) {
      print('Error saving local images: $e');
    }
  }

  // Get local image paths for a hostel
  static Future<List<String>> getLocalImages(String hostelId) async {
    try {
      final key = 'local_images_$hostelId';
      final images = await getSetting<List>(key);
      if (images != null) {
        return images.cast<String>();
      }
    } catch (e) {
      print('Error loading local images: $e');
    }
    return [];
  }

  // Utility methods
  static Future<void> clearAllData() async {
    try {
      await _hostelBox?.clear();
      await _enquiryBox?.clear();
      await _settingsBox?.clear();
      print('All local storage data cleared');
    } catch (e) {
      print('Error clearing local storage: $e');
    }
  }

  static Future<void> close() async {
    try {
      await _hostelBox?.close();
      await _enquiryBox?.close();
      await _settingsBox?.close();
      print('Local storage boxes closed');
    } catch (e) {
      print('Error closing local storage: $e');
    }
  }

  // Generate mock data for fallback
  static Future<void> initMockData() async {
    try {
      // Check if we already have data
      final existingHostels = await getHostels();
      if (existingHostels.isNotEmpty) {
        print('Local storage already has data, skipping mock data initialization');
        return;
      }

      // Create mock hostel
      final mockHostel = HostelModel(
        id: 'hostel_local_1',
        hostelName: 'Local PG Bee Hostel',
        ownerName: 'John Doe',
        phone: '+91 9876543210',
        address: '123 Main Street, City',
        location: 'Near University',
        description: 'A comfortable local hostel for students with all modern amenities.',
        rent: 8000.0,
        distance: 2.5,
        bedrooms: 2,
        bathrooms: 2,
        curfew: false,
        gender: 'male', // Added gender field
        files: 'local_image1.jpg,local_image2.jpg', // Changed to comma-separated string
        amenities: [
          AmenityModel(id: '1', name: 'WiFi', description: 'High-speed internet', isAvailable: true),
          AmenityModel(id: '2', name: 'AC', description: 'Air conditioning', isAvailable: true),
          AmenityModel(id: '3', name: 'Mess', description: 'Food facility', isAvailable: true),
          AmenityModel(id: '4', name: 'Parking', description: 'Vehicle parking', isAvailable: false),
        ],
        admittedStudents: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await saveHostel(mockHostel);

      // Create mock enquiries
      final mockEnquiries = [
        EnquiryModel(
          id: 'enq_local_1',
          studentName: 'Alice Johnson',
          studentEmail: 'alice@email.com',
          studentPhone: '+91 9876543210',
          hostelId: 'hostel_local_1',
          hostelName: 'Local PG Bee Hostel',
          message: 'I am interested in your hostel. Can I get more details about the facilities?',
          status: 'pending',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
        ),
        EnquiryModel(
          id: 'enq_local_2',
          studentName: 'Bob Smith',
          studentEmail: 'bob@email.com',
          studentPhone: '+91 9876543211',
          hostelId: 'hostel_local_1',
          hostelName: 'Local PG Bee Hostel',
          message: 'Looking for accommodation for next semester. Is there availability?',
          status: 'accepted',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
        ),
      ];

      for (final enquiry in mockEnquiries) {
        await saveEnquiry(enquiry);
      }

      print('Mock data initialized in local storage');
    } catch (e) {
      print('Error initializing mock data: $e');
    }
  }
}
