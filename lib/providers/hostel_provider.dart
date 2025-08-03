import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hostel_model.dart';
import '../services/service_manager.dart';
import '../services/local_storage_service.dart';
import '../config/locator.dart';

class HostelProvider extends ChangeNotifier {
  late final ServiceManager _serviceManager;
  
  HostelProvider() {
    _serviceManager = locator<ServiceManager>();
  }
  
  HostelModel? _hostel;
  List<HostelModel> _hostels = [];
  bool _isLoading = false;
  String? _errorMessage;

  HostelModel? get hostel => _hostel;
  List<HostelModel> get hostels => _hostels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load hostel details for the owner
  Future<void> loadHostelDetails(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ensure tokens are ready before making API calls
      print('HostelProvider: Ensuring tokens are ready before API call...');
      final tokensReady = await _serviceManager.ensureTokensReady();
      if (!tokensReady) {
        print('HostelProvider: Tokens not available, cannot proceed with API call');
        _errorMessage = 'Authentication tokens not available. Please log in again.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      print('HostelProvider: Tokens ready, proceeding with API call...');
      
      final result = await _serviceManager.hostelService.getOwnerHostels();
      
      print('HostelProvider: Raw result from service: $result');
      print('HostelProvider: Result keys: ${result.keys.toList()}');
      
      if (result['success']) {
        final hostelsData = result['data'];
        final message = result['message'];
        
        print('HostelProvider: hostelsData type: ${hostelsData.runtimeType}');
        print('HostelProvider: hostelsData: $hostelsData');
        
        // Handle "No hostels found" as successful empty result
        if (message != null && message.toLowerCase().contains('no hostels found')) {
          print('HostelProvider: No hostels found for user - showing empty state');
          _hostels = [];
          _hostel = null;
          _errorMessage = null; // This is not an error, just empty data
        } else if (hostelsData is Map && hostelsData.containsKey('hostels')) {
          // Backend returns {data: {hostels: [...]}}
          final hostelsList = hostelsData['hostels'] as List<dynamic>;
          print('HostelProvider: Raw hostels list length: ${hostelsList.length}');
          if (hostelsList.isNotEmpty) {
            print('HostelProvider: First hostel raw data: ${hostelsList.first}');
            print('HostelProvider: About to call HostelModel.fromJson with individual hostel data');
            _hostels = hostelsList.map((data) => HostelModel.fromJson(Map<String, dynamic>.from(data))).toList();
            _hostel = _hostels.first; // Use first hostel as primary
            print('HostelProvider: Parsed hostel name: ${_hostel!.hostelName}');
            print('HostelProvider: Parsed hostel phone: ${_hostel!.phone}');
            print('HostelProvider: Parsed hostel address: ${_hostel!.address}');
            print('HostelProvider: Loaded ${_hostels.length} hostels from backend');
          } else {
            _hostels = [];
            _hostel = null;
          }
        } else if (hostelsData is List && hostelsData.isNotEmpty) {
          // Direct array of hostels
          _hostels = hostelsData.map((data) => HostelModel.fromJson(Map<String, dynamic>.from(data))).toList();
          _hostel = _hostels.first; // Use first hostel as primary
        } else if (hostelsData is Map && !hostelsData.containsKey('hostels')) {
          // Single hostel object (not a wrapper object with 'hostels' key)
          _hostel = HostelModel.fromJson(Map<String, dynamic>.from(hostelsData));
          _hostels = [_hostel!];
        } else {
          // Empty data or unrecognized format
          print('HostelProvider: Unrecognized hostelsData format: $hostelsData');
          _hostels = [];
          _hostel = null;
        }
        
        // For new users or if backend doesn't have admitted students count,
        // load from local storage or default to 0
        if (_hostel != null && _hostel!.admittedStudents == 0) {
          final persistedCount = await _loadAdmittedStudentsCount();
          if (persistedCount > 0) {
            _hostel = _hostel!.copyWith(admittedStudents: persistedCount);
          }
        }
        
        // Save to local storage for fallback (only if we have actual data)
        if (_hostel != null) {
          await LocalStorageService.saveHostel(_hostel!);
        }
        
        _errorMessage = null;
      } else {
        _errorMessage = result['error'] ?? 'Failed to load hostel details';
        
        // Check if it's a connection error
        if (result['isConnectionError'] == true) {
          print('HostelProvider: Connection error detected - loading from local storage');
          await _loadFromLocalStorage();
        }
        // Check if reauthentication is required
        else if (result['requiresReauth'] == true) {
          print('HostelProvider: Reauthentication required - attempting token refresh first');
          
          // Try to refresh token before giving up
          bool refreshed = false;
          try {
            refreshed = await _serviceManager.authService.refreshAccessToken();
            print('HostelProvider: Token refresh result: $refreshed');
          } catch (e) {
            print('HostelProvider: Token refresh failed: $e');
          }
          
          if (refreshed) {
            print('HostelProvider: Token refreshed successfully, retrying API call');
            // Token refreshed successfully, retry the API call
            await loadHostelDetails(ownerId);
            return; // Exit after retry
          } else {
            print('HostelProvider: Token refresh failed - clearing tokens and redirecting to login');
            // Clear authentication state only if refresh fails
            _serviceManager.clearAuth();
            _errorMessage = 'Session expired. Please log in again.';
            // Set special error state to trigger login redirect
            _isLoading = false;
            notifyListeners();
            return; // Exit early to prevent local storage fallback
          }
        } else {
          // Fallback to local storage if backend fails for other reasons
          await _loadFromLocalStorage();
        }
      }
    } catch (e) {
      print('HostelProvider Error - Load Details: $e');
      
      // Check if it's a connection error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('No address associated with hostname')) {
        _errorMessage = 'Connection error. Loading saved data...';
        print('HostelProvider: Connection error detected - loading from local storage');
      } else {
        _errorMessage = 'Backend unavailable, loading from local storage';
        // Handle authentication errors for non-connection issues
        await _serviceManager.handleApiError(e);
      }
      
      // Fallback to local storage when backend is unavailable
      await _loadFromLocalStorage();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fallback method to load data from local storage
  Future<void> _loadFromLocalStorage() async {
    try {
      print('Loading hostel data from local storage...');
      final localHostels = await LocalStorageService.getHostels();
      
      if (localHostels.isNotEmpty) {
        _hostels = localHostels;
        _hostel = localHostels.first;
        
        // Load persisted admitted students count
        final persistedCount = await _loadAdmittedStudentsCount();
        if (persistedCount > 0) {
          _hostel = _hostel!.copyWith(admittedStudents: persistedCount);
        }
        
        print('Successfully loaded hostel data from local storage');
        _errorMessage = 'Using offline data - some features may be limited';
      } else {
        // No local data either, use mock data
        _loadMockData();
        _errorMessage = 'Using sample data - please check your connection';
      }
    } catch (e) {
      print('Error loading from local storage: $e');
      // Last resort: use mock data
      _loadMockData();
      _errorMessage = 'Using sample data due to storage error';
    }
  }

  // Retry mechanism for failed API calls
  Future<void> retryLoadHostelDetails(String ownerId) async {
    print('HostelProvider: Retrying API call...');
    _errorMessage = null; // Clear previous error
    await loadHostelDetails(ownerId);
  }

  // Update hostel information
  Future<bool> updateHostel(HostelModel updatedHostel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _serviceManager.hostelService.updateHostel(updatedHostel);
      
      if (result['success']) {
        _hostel = updatedHostel;
        // Update in the hostels list as well
        final index = _hostels.indexWhere((h) => h.id == updatedHostel.id);
        if (index != -1) {
          _hostels[index] = updatedHostel;
        }
        
        // Save updated hostel to local storage
        await LocalStorageService.saveHostel(updatedHostel);
        
        _errorMessage = null;
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Backend failed, try to save locally for offline editing
        _hostel = updatedHostel;
        final index = _hostels.indexWhere((h) => h.id == updatedHostel.id);
        if (index != -1) {
          _hostels[index] = updatedHostel;
        }
        
        // Save to local storage as fallback
        await LocalStorageService.saveHostel(updatedHostel);
        
        _errorMessage = 'Updated locally - will sync when connection is restored';
        _isLoading = false;
        notifyListeners();
        return true; // Return true since we saved locally
      }
    } catch (e) {
      print('HostelProvider Error - Update Hostel: $e');
      _errorMessage = 'Failed to update hostel details';
      _isLoading = false;
      notifyListeners();
      
      // Handle authentication errors
      await _serviceManager.handleApiError(e);
      return false;
    }
  }

  // Update amenities
  Future<bool> updateAmenities(List<AmenityModel> amenities) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_hostel != null) {
        final result = await _serviceManager.hostelService.updateAmenities(_hostel!.id, amenities);
        
        if (result['success']) {
          _hostel = _hostel!.copyWith(amenities: amenities);
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = result['error'] ?? 'Failed to update amenities';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      _errorMessage = 'No hostel available to update amenities';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('HostelProvider Error - Update Amenities: $e');
      _errorMessage = 'Failed to update amenities';
      _isLoading = false;
      notifyListeners();
      
      // Handle authentication errors
      await _serviceManager.handleApiError(e);
      return false;
    }
  }

    // Upload images
  Future<bool> uploadImages(List<String> imagePaths) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_hostel != null) {
        final result = await _serviceManager.hostelService.uploadImages(_hostel!.id, imagePaths);
        
        if (result['success']) {
          // Update hostel with new image URLs from server
          final uploadedFiles = result['data']['files'] as List<dynamic>?;
          if (uploadedFiles != null) {
            // Always treat files as comma-separated string
            final currentFiles = _hostel!.files.split(',').where((f) => f.isNotEmpty).toList();
            final uploadedFilesList = uploadedFiles.cast<String>().toList();
            final newFiles = [...currentFiles, ...uploadedFilesList];
            _hostel = _hostel!.copyWith(files: newFiles.join(','));
          }
          
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = result['error'] ?? 'Failed to upload images';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
      
      _errorMessage = 'No hostel available to upload images';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('HostelProvider Error - Upload Images: $e');
      _errorMessage = 'Failed to upload images';
      _isLoading = false;
      notifyListeners();
      
      // Handle authentication errors
      await _serviceManager.handleApiError(e);
      return false;
    }
  }

  // Update admitted students count (called when enquiry is accepted)
  Future<bool> updateAdmittedStudents(int incrementBy) async {
    if (_hostel == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCount = _hostel!.admittedStudents + incrementBy;

      // Call backend API to update student count
      final result = await _serviceManager.hostelService.updateAdmittedStudents(
        _hostel!.id, 
        newCount
      );
      
      if (result['success']) {
        // Update local state
        _hostel = _hostel!.copyWith(admittedStudents: newCount);
        
        // Persist to SharedPreferences for this user/hostel
        await _saveAdmittedStudentsCount(newCount);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to update student count';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('HostelProvider Error - Update Students: $e');
      _errorMessage = 'Failed to update student count';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Save admitted students count to SharedPreferences
  Future<void> _saveAdmittedStudentsCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'admitted_students_${_hostel?.id ?? 'default'}';
      await prefs.setInt(key, count);
    } catch (e) {
      print('Error saving admitted students count: $e');
    }
  }

  // Load admitted students count from SharedPreferences
  Future<int> _loadAdmittedStudentsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'admitted_students_${_hostel?.id ?? 'default'}';
      return prefs.getInt(key) ?? 0; // Default to 0 for new users
    } catch (e) {
      print('Error loading admitted students count: $e');
      return 0;
    }
  }

  // Load mock data for testing
  void _loadMockData() {
    _hostel = HostelModel(
      id: 'hostel_1',
      hostelName: 'PG Bee Hostel',
      ownerName: 'John Doe',
      phone: '+91 9876543210',
      address: '123 Main Street, City',
      location: 'Near University',
      description: 'A comfortable hostel for students with all modern amenities.',
      rent: 8000.0,
      distance: 2.5,
      bedrooms: 2,
      bathrooms: 2,
      curfew: false,
      gender: 'male',
      files: 'image1.jpg,image2.jpg,image3.jpg',
      amenities: [
        AmenityModel(id: '1', name: 'WiFi', description: 'High-speed internet', isAvailable: true),
        AmenityModel(id: '2', name: 'AC', description: 'Air conditioning', isAvailable: true),
        AmenityModel(id: '3', name: 'Mess', description: 'Food facility', isAvailable: true),
        AmenityModel(id: '4', name: 'Parking', description: 'Vehicle parking', isAvailable: false),
      ],
      admittedStudents: 0, // Start with 0 for new users
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _hostels = [_hostel!];
  }

  // Set hostel data from local storage
  void setHostelFromLocal(HostelModel hostel) {
    _hostel = hostel;
    _hostels = [hostel];
    notifyListeners();
  }

  // Refresh hostel data (forces reload from backend)
  Future<void> refresh(String ownerId) async {
    print('HostelProvider: Refreshing hostel data...');
    await loadHostelDetails(ownerId);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear all data (logout)
  void clearData() {
    _hostel = null;
    _hostels = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
