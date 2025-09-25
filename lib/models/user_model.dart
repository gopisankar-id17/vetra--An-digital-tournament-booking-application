class UserModel {
  final String id;
  final String phoneNumber;
  final String password;
  final String? email; // Optional email
  final String? fullName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.password,
    this.email,
    this.fullName,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'password': password,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create UserModel from Map (Firestore document)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      password: map['password'] ?? '',
      email: map['email'],
      fullName: map['fullName'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? password,
    String? email,
    String? fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, phoneNumber: $phoneNumber, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.fullName == fullName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        fullName.hashCode;
  }
}
