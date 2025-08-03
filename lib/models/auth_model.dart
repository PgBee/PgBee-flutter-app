class AuthModel {
  final String email;
  final String password;
  final String? firstName; // Optional for signup
  final String? lastName;  // Optional for signup
  final String? role;
  final String? phoneNo;    // Optional, if backend requires it

  AuthModel({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.role,
    this.phoneNo,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (role != null) 'role': role,
    if (phoneNo != null) 'phoneNo': phoneNo,
  };
}