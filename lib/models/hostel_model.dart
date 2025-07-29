class HostelModel {
  final String id;
  final String name;
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
  final List<String> files; // Photo URLs
  final List<AmenityModel> amenities;
  final int admittedStudents;
  final DateTime createdAt;
  final DateTime updatedAt;

  HostelModel({
    required this.id,
    required this.name,
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
    required this.files,
    required this.amenities,
    required this.admittedStudents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HostelModel.fromJson(Map<String, dynamic> json) {
    return HostelModel(
      id: json['id'] ?? '',
      name: json['hostelName'] ?? json['name'] ?? '',
      ownerName: json['name'] ?? json['ownerName'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      rent: (json['rent'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
      bedrooms: json['bedrooms'] ?? 1,
      bathrooms: json['bathrooms'] ?? 1,
      curfew: json['curfew'] ?? false,
      files: json['files'] != null 
          ? (json['files'] as String).split(',').map((f) => f.trim()).toList()
          : <String>[],
      amenities: json['amenities'] != null 
          ? (json['amenities'] as List).map((a) => AmenityModel.fromJson(a)).toList()
          : <AmenityModel>[],
      admittedStudents: json['admittedStudents'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelName': name,
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
      'files': files.join(', '),
      'amenities': amenities.map((a) => a.toJson()).toList(),
      'admittedStudents': admittedStudents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  HostelModel copyWith({
    String? id,
    String? name,
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
    List<String>? files,
    List<AmenityModel>? amenities,
    int? admittedStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HostelModel(
      id: id ?? this.id,
      name: name ?? this.name,
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
