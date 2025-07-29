import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors.dart';
import '../../providers/hostel_provider.dart';
import '../../models/hostel_model.dart';

class PgDetailsScreen extends StatefulWidget {
  const PgDetailsScreen({super.key});

  @override
  _PgDetailsScreenState createState() => _PgDetailsScreenState();
}

class _PgDetailsScreenState extends State<PgDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentController = TextEditingController();
  final _distanceController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  
  bool _curfew = false;
  List<AmenityModel> _amenities = [];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHostelData();
    });
  }

  void _loadHostelData() {
    final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
    hostelProvider.loadHostelDetails('owner_1'); // Replace with actual owner ID
  }

  void _populateFields(HostelModel hostel) {
    _nameController.text = hostel.name;
    _phoneController.text = hostel.phone;
    _addressController.text = hostel.address;
    _locationController.text = hostel.location;
    _descriptionController.text = hostel.description;
    _rentController.text = hostel.rent.toString();
    _distanceController.text = hostel.distance.toString();
    _bedroomsController.text = hostel.bedrooms.toString();
    _bathroomsController.text = hostel.bathrooms.toString();
    _curfew = hostel.curfew;
    _amenities = List.from(hostel.amenities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PG Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
        ],
      ),
      body: Consumer<HostelProvider>(
        builder: (context, hostelProvider, child) {
          if (hostelProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (hostelProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${hostelProvider.errorMessage}',
                    style: TextStyle(color: Colors.red),
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
            return Center(child: Text('No hostel data available'));
          }

          // Populate fields when data is loaded
          if (!_isEditing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _populateFields(hostelProvider.hostel!);
            });
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicDetailsSection(),
                  SizedBox(height: 24),
                  _buildPhotosSection(),
                  SizedBox(height: 24),
                  _buildAmenitiesSection(),
                  SizedBox(height: 24),
                  _buildLocationSection(),
                  SizedBox(height: 24),
                  _buildAdditionalInfoSection(),
                ],
              ),
            ),
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
                color: LightColor.black,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Hostel Name',
              icon: Icons.home,
              enabled: _isEditing,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _phoneController,
              label: 'Contact Number',
              icon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              enabled: _isEditing,
              maxLines: 3,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _rentController,
                    label: 'Monthly Rent (₹)',
                    icon: Icons.currency_rupee,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _distanceController,
                    label: 'Distance (km)',
                    icon: Icons.location_on,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
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
                    color: LightColor.black,
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    icon: Icon(Icons.add_a_photo),
                    onPressed: _addPhotos,
                  ),
              ],
            ),
            SizedBox(height: 16),
            Consumer<HostelProvider>(
              builder: (context, provider, child) {
                final photos = provider.hostel?.files ?? [];
                if (photos.isEmpty) {
                  return Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: LightColor.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'No photos added yet',
                        style: TextStyle(color: LightColor.grey),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: LightColor.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photos[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: LightColor.grey.withOpacity(0.3),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: LightColor.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
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
            Text(
              'Amenities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: LightColor.black,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _amenities.map((amenity) {
                return FilterChip(
                  label: Text(amenity.name),
                  selected: amenity.isAvailable,
                  onSelected: _isEditing ? (selected) {
                    setState(() {
                      final index = _amenities.indexOf(amenity);
                      _amenities[index] = amenity.copyWith(isAvailable: selected);
                    });
                  } : null,
                  selectedColor: LightColor.black.withOpacity(0.2),
                  checkmarkColor: LightColor.black,
                );
              }).toList(),
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
                color: LightColor.black,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Full Address',
              icon: Icons.location_city,
              enabled: _isEditing,
              maxLines: 2,
            ),
            SizedBox(height: 12),
            _buildTextField(
              controller: _locationController,
              label: 'Nearby Landmark',
              icon: Icons.place,
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: LightColor.black,
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
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Curfew Policy:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: LightColor.black,
                  ),
                ),
                SizedBox(width: 8),
                Switch(
                  value: _curfew,
                  onChanged: _isEditing ? (value) {
                    setState(() {
                      _curfew = value;
                    });
                  } : null,
                  activeColor: LightColor.black,
                ),
              ],
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
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightColor.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightColor.black),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightColor.grey.withOpacity(0.5)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
    final currentHostel = hostelProvider.hostel!;

    final updatedHostel = currentHostel.copyWith(
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      location: _locationController.text,
      description: _descriptionController.text,
      rent: double.tryParse(_rentController.text) ?? currentHostel.rent,
      distance: double.tryParse(_distanceController.text) ?? currentHostel.distance,
      bedrooms: int.tryParse(_bedroomsController.text) ?? currentHostel.bedrooms,
      bathrooms: int.tryParse(_bathroomsController.text) ?? currentHostel.bathrooms,
      curfew: _curfew,
      amenities: _amenities,
    );

    final success = await hostelProvider.updateHostel(updatedHostel);
    
    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hostel details updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(hostelProvider.errorMessage ?? 'Failed to update details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addPhotos() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      final hostelProvider = Provider.of<HostelProvider>(context, listen: false);
      final imagePaths = images.map((image) => image.path).toList();
      
      final success = await hostelProvider.uploadImages(imagePaths);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photos uploaded successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _rentController.dispose();
    _distanceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }
}
