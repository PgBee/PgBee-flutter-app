import 'package:flutter/material.dart';
import 'package:pgbee/services/service_manager.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/hostel_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/hostel_model.dart';
import '../../services/local_storage_service.dart';
//import '../../core/utils/string_extensions.dart';

class PgDetailsScreen extends StatefulWidget {
  @override
  _PgDetailsScreenState createState() => _PgDetailsScreenState();
}

class _PgDetailsScreenState extends State<PgDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Controllers for form fields
  final _hostelNameController = TextEditingController();  // Changed from name to hostelName
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _distanceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _genderController = TextEditingController();  // Added for gender field
  
  bool _curfew = false;
  List<AmenityModel> _amenities = [];
  String _gender = 'male';  // Default value
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingImages = false;
  List<String> _localImages = [];
  String? _saveMessage;
  bool _fieldsPopulated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Ensure token is set in HostelService before any API call
      final serviceManager = ServiceManager();
      final accessToken = serviceManager.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        serviceManager.setAuthTokens(accessToken: accessToken);
      }
      _loadHostelData();
    });
  }

  void _loadHostelData() async {
    final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    final ownerId = currentUser?['id'] ?? 'owner_1';
    
    // Don't reset populated flag if already populated to preserve form data
    if (!_fieldsPopulated) {
      _fieldsPopulated = false;
    }
    
    try {
      // Force refresh from backend to get latest data
      print('PgDetailsScreen: Refreshing hostel data from backend...');
      await hostelProvider.refresh(ownerId);
      
      // If refresh was successful and we have data, use it
      if (hostelProvider.hostel != null && hostelProvider.errorMessage == null) {
        print('Refresh successful, using backend data: ${hostelProvider.hostel!.hostelName}');
        _populateFormFields(hostelProvider.hostel!);
        return;
      }
      
      // If backend refresh failed or returned no hostels, fall back to local data
      if (hostelProvider.errorMessage == null || hostelProvider.errorMessage!.contains('no hostels found')) {
        // No hostels found is not an error - check for local data
        print('No hostels found on backend, checking local storage...');
      } else {
        // Actual error occurred, fall back to local data
        print('Backend error: ${hostelProvider.errorMessage}, falling back to local storage...');
      }
      
      // Always prioritize local data first to preserve user changes
      HostelModel? localHostel;
      
      // First try to get all hostels and find the one for this owner
      final localHostels = await LocalStorageService.getHostels();
      if (localHostels.isNotEmpty) {
        localHostel = localHostels.first; // Use first hostel found
        print('Found local hostel data: ${localHostel.hostelName}');
      }
      
      // If no hostels found, try using different keys
      if (localHostel == null) {
        localHostel = await LocalStorageService.getHostel(ownerId);
      }
      
      if (localHostel == null) {
        localHostel = await LocalStorageService.getHostel('hostel_1');
      }
      
      if (localHostel == null) {
        localHostel = await LocalStorageService.getHostel('hostel_local_1');
      }
      
      if (localHostel != null) {
        // Use local data (this preserves all saved changes)
        print('Loading hostel data from local storage: ${localHostel.hostelName}');
        _populateFormFields(localHostel);
        
        // Load local images if any
        final localImages = await LocalStorageService.getLocalImages(localHostel.id);
        if (localImages.isNotEmpty) {
          setState(() {
            _localImages = localImages;
          });
        }
        
        // Update provider with local data only if it's empty
        if (hostelProvider.hostel == null || hostelProvider.hostel!.hostelName == 'PG Bee Hostel') {
          // Update provider state to match local storage
          hostelProvider.setHostelFromLocal(localHostel);
        }
      } else {
        // No local data, try backend only if we don't have local data
        print('No local data found, trying backend...');
        
        // Don't reload if we already have provider data (prevent resetting)
        if (hostelProvider.hostel == null) {
          await hostelProvider.loadHostelDetails(ownerId);
          
          if (hostelProvider.errorMessage != null) {
            print('Backend failed, initializing with mock data');
            await LocalStorageService.initMockData();
            final mockHostels = await LocalStorageService.getHostels();
            if (mockHostels.isNotEmpty) {
              _populateFormFields(mockHostels.first);
            }
          } else {
            // Save backend data to local storage for future use
            if (hostelProvider.hostel != null) {
              await LocalStorageService.saveHostel(hostelProvider.hostel!);
              _populateFormFields(hostelProvider.hostel!);
            }
          }
        } else {
          // Use existing provider data
          _populateFormFields(hostelProvider.hostel!);
        }
      }
    } catch (e) {
      print('Error loading hostel data: $e');
      // Try local storage as final fallback
      final localHostels = await LocalStorageService.getHostels();
      if (localHostels.isNotEmpty) {
        _populateFormFields(localHostels.first);
      } else {
        // Initialize mock data if nothing exists
        await LocalStorageService.initMockData();
        final mockHostels = await LocalStorageService.getHostels();
        if (mockHostels.isNotEmpty) {
          _populateFormFields(mockHostels.first);
        }
      }
      await LocalStorageService.setFallbackMode(true);
    }
  }

  void _populateFormFields(HostelModel hostel) {
    _hostelNameController.text = hostel.hostelName;
    _phoneController.text = hostel.phone;
    _addressController.text = hostel.address;
    _locationController.text = hostel.location;
    _descriptionController.text = hostel.description;
    _rentController.text = hostel.rent.toString();
    _distanceController.text = hostel.distance.toString();
    _bedroomsController.text = hostel.bedrooms.toString();
    _bathroomsController.text = hostel.bathrooms.toString();
    _curfew = hostel.curfew;
    _gender = hostel.gender;
    _amenities = List.from(hostel.amenities);
    _fieldsPopulated = true;
    setState(() {});
  }

  Future<void> _toggleEdit() async {
    if (_isEditing) {
      await _saveChanges();
    } else {
      setState(() {
        _isEditing = true;
        _saveMessage = null;
        // Don't reset _fieldsPopulated here - keep current form values
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveMessage = null;
    });

    try {
      final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
      final currentHostel = hostelProvider.hostel;
      
      if (currentHostel == null) {
        throw Exception('No hostel data to update');
      }

      final updatedHostel = currentHostel.copyWith(
        hostelName: _hostelNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        rent: double.tryParse(_rentController.text) ?? currentHostel.rent,
        distance: double.tryParse(_distanceController.text) ?? currentHostel.distance,
        bedrooms: int.tryParse(_bedroomsController.text) ?? currentHostel.bedrooms,
        bathrooms: int.tryParse(_bathroomsController.text) ?? currentHostel.bathrooms,
        curfew: _curfew,
        gender: _gender,
        amenities: _amenities,
      );

      bool backendSuccess = false;
      try {
        // Try backend update first
        final success = await hostelProvider.updateHostel(updatedHostel);
        if (success) {
          await hostelProvider.updateAmenities(_amenities);
          backendSuccess = true;
        }
      } catch (e) {
        print('Backend update failed: $e');
      }

      // Always save to local storage for persistence (this is crucial for data persistence)
      await LocalStorageService.saveHostel(updatedHostel);
      print('Hostel saved to local storage with key: ${updatedHostel.id}');
      print('Saved hostel name: ${updatedHostel.hostelName}');
      
      // Save local images if any
      if (_localImages.isNotEmpty) {
        await LocalStorageService.saveLocalImages(updatedHostel.id, _localImages);
        print('Saved ${_localImages.length} local images');
      }
      
      if (!backendSuccess) {
        await LocalStorageService.setFallbackMode(true);
      }
      
      // Update the form fields with the saved data to ensure consistency
      _populateFormFields(updatedHostel);
      print('Form fields updated with saved data');
      
      setState(() {
        _isEditing = false;
        _saveMessage = backendSuccess 
            ? 'Hostel details updated successfully!'
            : 'Hostel details saved locally (backend unavailable)';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(backendSuccess 
              ? 'Hostel details updated successfully!'
              : 'Hostel details saved locally (will sync when backend is available)'),
          backgroundColor: backendSuccess ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      setState(() {
        _saveMessage = 'Failed to update: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        setState(() {
          _localImages.addAll(images.map((image) => image.path));
        });
        
        await _uploadImages(images.map((image) => image.path).toList());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick images: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImages(List<String> imagePaths) async {
    setState(() {
      _isUploadingImages = true;
    });

    try {
      final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
      bool backendSuccess = false;
      
      try {
        backendSuccess = await hostelProvider.uploadImages(imagePaths);
      } catch (e) {
        print('Backend upload failed: $e');
      }
      
      if (backendSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('${imagePaths.length} image(s) uploaded successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _localImages.clear();
        });
        
        // Refresh hostel data to get updated image URLs
        _loadHostelData();
      } else {
        // Backend failed, keep images locally
        if (hostelProvider.hostel != null) {
          await LocalStorageService.saveLocalImages(hostelProvider.hostel!.id, _localImages);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Text('Images saved locally (will upload when backend is available)'),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Failed to upload images: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImages = false;
      });
    }
  }

  Future<void> _removeImage(int index) async {
    try {
      final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
      final currentHostel = hostelProvider.hostel;
      
      if (currentHostel != null && index < currentHostel.files.length) {
        final filesList = currentHostel.files.split(',')
            .where((file) => file.isNotEmpty)
            .toList();
        filesList.removeAt(index);
        
        final updatedHostel = currentHostel.copyWith(
          files: filesList.join(',')
        );
        final success = await hostelProvider.updateHostel(updatedHostel);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Image removed successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Failed to remove image');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Failed to remove image: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleAmenity(int index) {
    if (_isEditing) {
      setState(() {
        _amenities[index] = _amenities[index].copyWith(
          isAvailable: !_amenities[index].isAvailable
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HostelProvider>(
        builder: (context, hostelProvider, child) {
          if (hostelProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading hostel details...'),
                ],
              ),
            );
          }

          if (hostelProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Error: ${hostelProvider.errorMessage}',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHostelData,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (hostelProvider.hostel == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hostel data available'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHostelData,
                    child: Text('Load Data'),
                  ),
                ],
              ),
            );
          }

          // Populate fields when data is loaded (only once)
          if (!_isEditing && !_fieldsPopulated && hostelProvider.hostel != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFormFields(hostelProvider.hostel!);
            });
          }

          return Column(
            children: [
              // Header with edit/save button
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PG Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        if (_isUploadingImages)
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        IconButton(
                          icon: Icon(_isSaving 
                            ? Icons.hourglass_empty 
                            : (_isEditing ? Icons.save : Icons.edit)
                          ),
                          onPressed: (_isSaving || _isUploadingImages) ? null : _toggleEdit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicDetailsSection(),
                        SizedBox(height: 16),
                        _buildLocationSection(),
                        SizedBox(height: 16),
                        _buildPricingSection(),
                        SizedBox(height: 16),
                        _buildRoomDetailsSection(),
                        SizedBox(height: 16),
                        _buildAmenitiesSection(),
                        SizedBox(height: 16),
                        _buildPhotosSection(),
                        if (_saveMessage != null) ...[
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _saveMessage!.contains('success') 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _saveMessage!.contains('success') 
                                  ? Colors.green
                                  : Colors.red,
                              ),
                            ),
                            child: Text(
                              _saveMessage!,
                              style: TextStyle(
                                color: _saveMessage!.contains('success') 
                                  ? Colors.green
                                  : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBasicDetailsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _hostelNameController,
              label: 'Hostel Name',
              icon: Icons.home,
              enabled: _isEditing,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter hostel name';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Contact Number',
              icon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter contact number';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              enabled: _isEditing,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Full Address',
              icon: Icons.location_on,
              enabled: _isEditing,
              maxLines: 2,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _locationController,
              label: 'Location (e.g., Near University)',
              icon: Icons.place,
              enabled: _isEditing,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _distanceController,
              label: 'Distance from main location (km)',
              icon: Icons.directions,
              enabled: _isEditing,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing & Policies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _rentController,
              label: 'Monthly Rent (₹)',
              icon: Icons.currency_rupee,
              enabled: _isEditing,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter rent amount';
                }
                final rent = double.tryParse(value!);
                if (rent == null || rent <= 0) {
                  return 'Please enter a valid rent amount';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Gender Selection
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600]),
                SizedBox(width: 12),
                Text(
                  'Gender:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                DropdownButton<String>(
                  value: <String>['male', 'female', 'any'].contains(_gender) ? _gender : 'male',
                  onChanged: _isEditing ? (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _gender = newValue;
                      });
                    }
                  } : null,
                  items: <String>['male', 'female', 'any']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value[0].toUpperCase() + value.substring(1)),
                      );
                    }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Curfew Policy
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.grey[600]),
                SizedBox(width: 12),
                Text(
                  'Curfew Policy:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                Switch(
                  value: _curfew,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _curfew = value;
                    });
                  } : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomDetailsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _bedroomsController,
                    label: 'Bedrooms',
                    icon: Icons.bed,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Required';
                      }
                      final bedrooms = int.tryParse(value!);
                      if (bedrooms == null || bedrooms <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _bathroomsController,
                    label: 'Bathrooms',
                    icon: Icons.bathtub,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Required';
                      }
                      final bathrooms = int.tryParse(value!);
                      if (bathrooms == null || bathrooms <= 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (_isEditing)
                  Text(
                    'Tap to toggle',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _amenities.asMap().entries.map((entry) {
                final index = entry.key;
                final amenity = entry.value;
                return GestureDetector(
                  onTap: () => _toggleAmenity(index),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: amenity.isAvailable 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: amenity.isAvailable 
                          ? Colors.green
                          : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          amenity.isAvailable 
                            ? Icons.check_circle
                            : Icons.cancel,
                          size: 16,
                          color: amenity.isAvailable 
                            ? Colors.green
                            : Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          amenity.name,
                          style: TextStyle(
                            color: amenity.isAvailable 
                              ? Colors.green
                              : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    final hostelProvider = Provider.of<HostelProvider>(context);
    final hostel = hostelProvider.hostel;
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (_isEditing)
                  ElevatedButton.icon(
                    onPressed: _isUploadingImages ? null : _pickImages,
                    icon: _isUploadingImages 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.add_a_photo),
                    label: Text(_isUploadingImages ? 'Uploading...' : 'Add Photos'),
                  ),
              ],
            ),
            SizedBox(height: 16),
            if ((hostel?.files.isNotEmpty == true) || _localImages.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Display existing photos from backend
                    if (hostel?.files.isNotEmpty == true)
                      ...hostel!.files.split(',')
                          .where((file) => file.isNotEmpty)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final imageUrl = entry.value;
                        return Container(
                          width: 120,
                          height: 120,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error, color: Colors.grey),
                                          Text('Failed to load', 
                                            style: TextStyle(fontSize: 10, color: Colors.grey)),
                                        ],
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    
                    // Display local images (not yet uploaded)
                    ..._localImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final imagePath = entry.value;
                      return Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[300]!, width: 2),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(imagePath),
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error, color: Colors.grey),
                                        Text('Local image', 
                                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Local image indicator
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Local',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _localImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    // Display local images being uploaded
                    ..._localImages.map((imagePath) => Container(
                      width: 120,
                      height: 120,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black26,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Uploading...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No photos uploaded yet',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (_isEditing) ...[
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _pickImages,
                        child: Text('Add Photos'),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[50],
      ),
    );
  }

  @override
  void dispose() {
    _hostelNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _distanceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _genderController.dispose();
    super.dispose();
  }
}