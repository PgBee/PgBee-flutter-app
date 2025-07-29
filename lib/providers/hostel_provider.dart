import 'package:flutter/material.dart';
import '../models/hostel_model.dart';
import '../services/hostel_service.dart';

class HostelProvider extends ChangeNotifier {
  final HostelService _hostelService = HostelService();
  
  HostelModel? _hostel;
  bool _isLoading = false;
  String? _errorMessage;

  HostelModel? get hostel => _hostel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load hostel details for the owner
  Future<void> loadHostelDetails(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _hostelService.getOwnerHostel(ownerId);
      
      if (result['success']) {
        _hostel = HostelModel.fromJson(result['data']);
        _errorMessage = null;
      } else {
        _errorMessage = result['error'] ?? 'Failed to load hostel details';
      }
    } catch (e) {
      _errorMessage = 'Error loading hostel details: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update hostel details
  Future<bool> updateHostel(HostelModel updatedHostel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _hostelService.updateHostel(updatedHostel.id, updatedHostel);
      
      if (result['success']) {
        _hostel = updatedHostel;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to update hostel';
      }
    } catch (e) {
      _errorMessage = 'Error updating hostel: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update amenities
  Future<bool> updateAmenities(List<AmenityModel> amenities) async {
    if (_hostel == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _hostelService.updateAmenities(_hostel!.id, amenities);
      
      if (result['success']) {
        _hostel = _hostel!.copyWith(amenities: amenities);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to update amenities';
      }
    } catch (e) {
      _errorMessage = 'Error updating amenities: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Upload hostel images
  Future<bool> uploadImages(List<String> imagePaths) async {
    if (_hostel == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _hostelService.uploadImages(_hostel!.id, imagePaths);
      
      if (result['success']) {
        final newFiles = List<String>.from(result['data']['files']);
        _hostel = _hostel!.copyWith(files: [..._hostel!.files, ...newFiles]);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to upload images';
      }
    } catch (e) {
      _errorMessage = 'Error uploading images: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update admitted students count
  Future<bool> updateAdmittedStudents(int newCount) async {
    if (_hostel == null) return false;

    try {
      final result = await _hostelService.updateAdmittedStudents(_hostel!.id, newCount);
      
      if (result['success']) {
        _hostel = _hostel!.copyWith(admittedStudents: newCount);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['error'] ?? 'Failed to update student count';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error updating student count: ${e.toString()}';
      notifyListeners();
    }

    return false;
  }

  // Increment admitted students (for enquiry acceptance)
  Future<bool> incrementAdmittedStudents() async {
    if (_hostel == null) return false;
    
    final newCount = _hostel!.admittedStudents + 1;
    return await updateAdmittedStudents(newCount);
  }

  // Decrement admitted students
  Future<bool> decrementAdmittedStudents() async {
    if (_hostel == null) return false;
    
    final newCount = _hostel!.admittedStudents > 0 ? _hostel!.admittedStudents - 1 : 0;
    return await updateAdmittedStudents(newCount);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _hostel = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
