import 'package:flutter/material.dart';
import '../models/enquiry_model.dart';
import '../services/enquiry_service.dart';

class EnquiryProvider extends ChangeNotifier {
  final EnquiryService _enquiryService = EnquiryService();
  
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
      final result = await _enquiryService.getOwnerEnquiries(ownerId);
      
      if (result['success']) {
        _enquiries = List<EnquiryModel>.from(result['data']);
        _errorMessage = null;
      } else {
        _errorMessage = result['error'] ?? 'Failed to load enquiries';
      }
    } catch (e) {
      _errorMessage = 'Error loading enquiries: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Accept an enquiry
  Future<bool> acceptEnquiry(String enquiryId) async {
    try {
      final result = await _enquiryService.respondToEnquiry(enquiryId, 'accepted');
      
      if (result['success']) {
        // Update local state
        final index = _enquiries.indexWhere((e) => e.id == enquiryId);
        if (index != -1) {
          _enquiries[index] = _enquiries[index].copyWith(
            status: 'accepted',
            respondedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to accept enquiry';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error accepting enquiry: ${e.toString()}';
      notifyListeners();
    }

    return false;
  }

  // Deny an enquiry
  Future<bool> denyEnquiry(String enquiryId) async {
    try {
      final result = await _enquiryService.respondToEnquiry(enquiryId, 'denied');
      
      if (result['success']) {
        // Update local state
        final index = _enquiries.indexWhere((e) => e.id == enquiryId);
        if (index != -1) {
          _enquiries[index] = _enquiries[index].copyWith(
            status: 'denied',
            respondedAt: DateTime.now(),
          );
          notifyListeners();
        }
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to deny enquiry';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error denying enquiry: ${e.toString()}';
      notifyListeners();
    }

    return false;
  }

  // Create a new enquiry (for students)
  Future<bool> createEnquiry(EnquiryModel enquiry) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _enquiryService.createEnquiry(enquiry);
      
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
      final result = await _enquiryService.deleteEnquiry(enquiryId);
      
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
