class HostelModel {
  final String id;
  final String hostelName;  // Changed to match backend
  final String ownerName;
  final String phone;
  final String address;
  final String location;
  final String description;
  final double rent;
  final double distance;
  final int bedrooms;
  final int bathrooms;
  final bool curfew;
  final String gender;     // Added to match backend
  final String files;     // Changed to match backend (comma-separated string)
  final List<AmenityModel> amenities;
  final int admittedStudents;
  final DateTime createdAt;
  final DateTime updatedAt;

  HostelModel({
    required this.id,
    required this.hostelName,
    required this.ownerName,
    required this.phone,
    required this.address,
    required this.location,
    required this.description,
    required this.rent,
    required this.distance,
    required this.bedrooms,
    required this.bathrooms,
    required this.curfew,
    required this.gender,
    required this.files,
    required this.amenities,
    required this.admittedStudents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HostelModel.fromJson(Map<String, dynamic> json) {
    print('HostelModel.fromJson: Input JSON keys: ${json.keys.toList()}');
    print('HostelModel.fromJson: hostelName = ${json['hostelName']}');
    print('HostelModel.fromJson: phone = ${json['phone']}');
    print('HostelModel.fromJson: address = ${json['address']}');
    print('HostelModel.fromJson: Stack trace: ${StackTrace.current}');
    
    // Extract owner name from User object or fallback to other fields
    String ownerName = '';
    if (json['User'] != null && json['User']['name'] != null) {
      ownerName = json['User']['name'];
    } else if (json['Owner'] != null && json['Owner']['name'] != null) {
      ownerName = json['Owner']['name'];
    } else {
      ownerName = json['name'] ?? json['ownerName'] ?? 'Owner';
    }

    // Convert Ammenity object to AmenityModel list
    List<AmenityModel> amenities = <AmenityModel>[];
    if (json['Ammenity'] != null) {
      final amenityData = json['Ammenity'] as Map<String, dynamic>;
      // Convert boolean flags to AmenityModel objects
      amenityData.forEach((key, value) {
        if (key != 'id' && value is bool) {
          amenities.add(AmenityModel(
            id: key,
            name: key.toLowerCase() == 'mess' ? 'Food' : 
                  key.toLowerCase() == 'ac' ? 'Air Conditioning' :
                  key.toLowerCase() == 'wifi' ? 'WiFi' :
                  key.toLowerCase() == 'firstaid' ? 'First Aid' :
                  key.toLowerCase() == 'currentbill' ? 'Current Bill' :
                  key.toLowerCase() == 'waterbill' ? 'Water Bill' :
                  key[0].toUpperCase() + key.substring(1),
            description: '${key[0].toUpperCase() + key.substring(1)} facility',
            isAvailable: value,
          ));
        }
      });
    } else if (json['amenities'] != null) {
      // Fallback to existing amenities structure
      amenities = (json['amenities'] as List).map((a) => AmenityModel.fromJson(a)).toList();
    }

    final hostelModel = HostelModel(
      id: json['id'] ?? '',
      hostelName: json['hostelName'] ?? '',
      ownerName: ownerName,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? 'A comfortable place to stay',
      rent: (json['rent'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      curfew: json['curfew'] ?? false,
      gender: json['gender'] ?? 'mixed',
      files: json['files'] ?? '',
      amenities: amenities,
      admittedStudents: json['admittedStudents'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
    
    print('HostelModel.fromJson: Created model with hostelName: ${hostelModel.hostelName}');
    print('HostelModel.fromJson: Created model with phone: ${hostelModel.phone}');
    print('HostelModel.fromJson: Created model with address: ${hostelModel.address}');
    
    return hostelModel;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelName': hostelName,
      'name': ownerName,
      'phone': phone,
      'address': address,
      'location': location,
      'description': description,
      'rent': rent,
      'distance': distance,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'curfew': curfew,
      'gender': gender,
      'files': files,
      'amenities': amenities.map((a) => a.toJson()).toList(),
      'admittedStudents': admittedStudents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  HostelModel copyWith({
    String? id,
    String? hostelName,
    String? ownerName,
    String? phone,
    String? address,
    String? location,
    String? description,
    double? rent,
    double? distance,
    int? bedrooms,
    int? bathrooms,
    bool? curfew,
    String? gender,
    String? files,
    List<AmenityModel>? amenities,
    int? admittedStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HostelModel(
      id: id ?? this.id,
      hostelName: hostelName ?? this.hostelName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      location: location ?? this.location,
      description: description ?? this.description,
      rent: rent ?? this.rent,
      distance: distance ?? this.distance,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      curfew: curfew ?? this.curfew,
      gender: gender ?? this.gender,
      files: files ?? this.files,
      amenities: amenities ?? this.amenities,
      admittedStudents: admittedStudents ?? this.admittedStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AmenityModel {
  final String id;
  final String name;
  final String description;
  final bool isAvailable;

  AmenityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isAvailable,
  });

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isAvailable': isAvailable,
    };
  }

  AmenityModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isAvailable,
  }) {
    return AmenityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
