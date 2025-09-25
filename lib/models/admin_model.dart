class AdminModel {
  final String id;
  final String email;
  final String? phoneNumber; // Optional phone number
  final String password;
  final String fullName;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AdminModel({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.password,
    required this.fullName,
    this.role = 'admin',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert AdminModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
      'fullName': fullName,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create AdminModel from Map (Firestore document)
  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id'] ?? map['documentId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? map['phone'], // Handle both field names
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? map['name'] ?? '', // Handle both field names
      role: map['role'] ?? 'admin',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(), // Default to now if missing
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Create a copy of AdminModel with updated fields
  AdminModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? password,
    String? fullName,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AdminModel(id: $id, email: $email, phoneNumber: $phoneNumber, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminModel &&
        other.id == id &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.fullName == fullName &&
        other.role == role &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        fullName.hashCode ^
        role.hashCode ^
        isActive.hashCode;
  }
}
