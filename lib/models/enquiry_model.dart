class EnquiryModel {
  final String id;
  final String studentName;
  final String studentEmail;
  final String studentPhone;
  final String hostelId;
  final String hostelName;
  final String message;
  final String status; // 'pending', 'accepted', 'denied'
  final DateTime createdAt;
  final DateTime? respondedAt;

  EnquiryModel({
    required this.id,
    required this.studentName,
    required this.studentEmail,
    required this.studentPhone,
    required this.hostelId,
    required this.hostelName,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      id: json['id'] ?? '',
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
      studentPhone: json['studentPhone'] ?? '',
      hostelId: json['hostelId'] ?? '',
      hostelName: json['hostelName'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentPhone': studentPhone,
      'hostelId': hostelId,
      'hostelName': hostelName,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  EnquiryModel copyWith({
    String? id,
    String? studentName,
    String? studentEmail,
    String? studentPhone,
    String? hostelId,
    String? hostelName,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return EnquiryModel(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      studentPhone: studentPhone ?? this.studentPhone,
      hostelId: hostelId ?? this.hostelId,
      hostelName: hostelName ?? this.hostelName,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
