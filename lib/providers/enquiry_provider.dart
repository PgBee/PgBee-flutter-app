import 'package:flutter/material.dart';
import '../models/enquiry_model.dart';
import '../services/service_manager.dart';
import '../services/local_storage_service.dart';

class EnquiryProvider extends ChangeNotifier {
  final ServiceManager _serviceManager = ServiceManager();
  
  List<EnquiryModel> _enquiries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EnquiryModel> get enquiries => _enquiries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get filtered enquiries
  List<EnquiryModel> get pendingEnquiries => 
      _enquiries.where((e) => e.status == 'pending').toList();
  
  List<EnquiryModel> get acceptedEnquiries => 
      _enquiries.where((e) => e.status == 'accepted').toList();
  
  List<EnquiryModel> get deniedEnquiries => 
      _enquiries.where((e) => e.status == 'denied').toList();

  // Load enquiries for owner
  Future<void> loadEnquiries(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First, load from local storage to show immediate data
      final localEnquiries = await LocalStorageService.getEnquiries();
      if (localEnquiries.isNotEmpty) {
        _enquiries = localEnquiries;
        notifyListeners();
      }

      // Then try to load from backend
      final result = await _serviceManager.enquiryService.getOwnerEnquiries();
      
      if (result['success']) {
        final backendEnquiries = List<EnquiryModel>.from(result['data']);
        
        // Merge with local storage - local changes take priority
        final mergedEnquiries = await _mergeEnquiriesWithLocal(backendEnquiries);
        _enquiries = mergedEnquiries;
        _errorMessage = null;
        
        // Save merged data to local storage
        for (final enquiry in _enquiries) {
          await LocalStorageService.saveEnquiry(enquiry);
        }
      } else {
        // Backend failed, use local data if available
        if (_enquiries.isEmpty) {
          _errorMessage = result['error'] ?? 'Failed to load enquiries';
        } else {
          // We have local data, so just show a soft error
          _errorMessage = null;
        }
      }
    } catch (e) {
      // If we have local data, use it; otherwise show error
      if (_enquiries.isEmpty) {
        _errorMessage = 'Error loading enquiries: ${e.toString()}';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Merge backend enquiries with local changes
  Future<List<EnquiryModel>> _mergeEnquiriesWithLocal(List<EnquiryModel> backendEnquiries) async {
    final localEnquiries = await LocalStorageService.getEnquiries();
    final mergedEnquiries = <EnquiryModel>[];
    
    // Create a map of local enquiries for quick lookup
    final localEnquiriesMap = {for (var e in localEnquiries) e.id: e};
    
    // Merge backend enquiries with local changes
    for (final backendEnquiry in backendEnquiries) {
      final localEnquiry = localEnquiriesMap[backendEnquiry.id];
      
      if (localEnquiry != null) {
        // If local version has a newer respondedAt or different status, use local
        if (localEnquiry.respondedAt != null && 
            (backendEnquiry.respondedAt == null || 
             localEnquiry.respondedAt!.isAfter(backendEnquiry.respondedAt!))) {
          mergedEnquiries.add(localEnquiry);
        } else if (localEnquiry.status != backendEnquiry.status) {
          // Local status change takes priority
          mergedEnquiries.add(localEnquiry);
        } else {
          mergedEnquiries.add(backendEnquiry);
        }
      } else {
        mergedEnquiries.add(backendEnquiry);
      }
    }
    
    // Add any local-only enquiries (new ones not yet synced)
    for (final localEnquiry in localEnquiries) {
      if (!mergedEnquiries.any((e) => e.id == localEnquiry.id)) {
        mergedEnquiries.add(localEnquiry);
      }
    }
    
    return mergedEnquiries;
  }

  // Accept an enquiry
  Future<bool> acceptEnquiry(String enquiryId) async {
    try {
      // Update local state immediately for responsive UI
      final index = _enquiries.indexWhere((e) => e.id == enquiryId);
      if (index != -1) {
        final updatedEnquiry = _enquiries[index].copyWith(
          status: 'accepted',
          respondedAt: DateTime.now(),
        );
        _enquiries[index] = updatedEnquiry;
        
        // Save to local storage immediately
        await LocalStorageService.updateEnquiry(updatedEnquiry);
        notifyListeners();
      }

      // Try to sync with backend
      final result = await _serviceManager.enquiryService.acceptEnquiry(enquiryId);
      
      if (result['success']) {
        // Backend sync successful, update timestamp if needed
        if (index != -1) {
          final finalEnquiry = _enquiries[index].copyWith(
            respondedAt: DateTime.now(),
          );
          _enquiries[index] = finalEnquiry;
          await LocalStorageService.updateEnquiry(finalEnquiry);
          notifyListeners();
        }
        return true;
      } else {
        // Backend failed but local update succeeded
        _errorMessage = result['error'] ?? 'Failed to sync with server, but saved locally';
        notifyListeners();
        return true; // Still return true since local update worked
      }
    } catch (e) {
      _errorMessage = 'Error accepting enquiry: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Deny an enquiry
  Future<bool> denyEnquiry(String enquiryId) async {
    try {
      // Update local state immediately for responsive UI
      final index = _enquiries.indexWhere((e) => e.id == enquiryId);
      if (index != -1) {
        final updatedEnquiry = _enquiries[index].copyWith(
          status: 'denied',
          respondedAt: DateTime.now(),
        );
        _enquiries[index] = updatedEnquiry;
        
        // Save to local storage immediately
        await LocalStorageService.updateEnquiry(updatedEnquiry);
        notifyListeners();
      }

      // Try to sync with backend
      final result = await _serviceManager.enquiryService.denyEnquiry(enquiryId);
      
      if (result['success']) {
        // Backend sync successful, update timestamp if needed
        if (index != -1) {
          final finalEnquiry = _enquiries[index].copyWith(
            respondedAt: DateTime.now(),
          );
          _enquiries[index] = finalEnquiry;
          await LocalStorageService.updateEnquiry(finalEnquiry);
          notifyListeners();
        }
        return true;
      } else {
        // Backend failed but local update succeeded
        _errorMessage = result['error'] ?? 'Failed to sync with server, but saved locally';
        notifyListeners();
        return true; // Still return true since local update worked
      }
    } catch (e) {
      _errorMessage = 'Error denying enquiry: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Create a new enquiry (for students)
  Future<bool> createEnquiry(EnquiryModel enquiry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _serviceManager.enquiryService.createEnquiry(
        studentName: enquiry.studentName,
        studentEmail: enquiry.studentEmail,
        studentPhone: enquiry.studentPhone,
        hostelId: enquiry.hostelId,
        message: enquiry.message,
      );
      
      if (result['success']) {
        _enquiries.add(enquiry);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to create enquiry';
      }
    } catch (e) {
      _errorMessage = 'Error creating enquiry: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Delete an enquiry
  Future<bool> deleteEnquiry(String enquiryId) async {
    try {
      final result = await _serviceManager.enquiryService.deleteEnquiry(enquiryId);
      
      if (result['success']) {
        _enquiries.removeWhere((e) => e.id == enquiryId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to delete enquiry';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error deleting enquiry: ${e.toString()}';
      notifyListeners();
    }

    return false;
  }

  // Get enquiry by ID
  EnquiryModel? getEnquiryById(String enquiryId) {
    try {
      return _enquiries.firstWhere((e) => e.id == enquiryId);
    } catch (e) {
      return null;
    }
  }

  // Load enquiries from local storage only
  Future<void> loadFromLocalStorage() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _enquiries = await LocalStorageService.getEnquiries();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading local enquiries: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Refresh enquiries
  Future<void> refresh(String ownerId) async {
    await loadEnquiries(ownerId);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _enquiries = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
