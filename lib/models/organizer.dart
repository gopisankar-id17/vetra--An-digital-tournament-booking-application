class Organizer {
  final String id;
  final String organizationName;
  final String email;
  final String phone;
  final String address;
  final DateTime registrationDate;
  final bool isVerified;
  final List<String> tournamentIds;
  final Map<String, dynamic>? additionalInfo;

  Organizer({
    required this.id,
    required this.organizationName,
    required this.email,
    required this.phone,
    required this.address,
    DateTime? registrationDate,
    this.isVerified = false,
    this.tournamentIds = const [],
    this.additionalInfo,
  }) : registrationDate = registrationDate ?? DateTime.now();

  // Create an Organizer from a map (for Firestore)
  factory Organizer.fromMap(Map<String, dynamic> map) {
    return Organizer(
      id: map['id'] ?? '',
      organizationName: map['organizationName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      registrationDate: map['registrationDate']?.toDate() ?? DateTime.now(),
      isVerified: map['isVerified'] ?? false,
      tournamentIds: List<String>.from(map['tournamentIds'] ?? []),
      additionalInfo: map['additionalInfo'],
    );
  }

  // Convert Organizer to a map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationName': organizationName,
      'email': email,
      'phone': phone,
      'address': address,
      'registrationDate': registrationDate,
      'isVerified': isVerified,
      'tournamentIds': tournamentIds,
      'additionalInfo': additionalInfo,
    };
  }

  // Create a copy with updated fields
  Organizer copyWith({
    String? id,
    String? organizationName,
    String? email,
    String? phone,
    String? address,
    DateTime? registrationDate,
    bool? isVerified,
    List<String>? tournamentIds,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Organizer(
      id: id ?? this.id,
      organizationName: organizationName ?? this.organizationName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      registrationDate: registrationDate ?? this.registrationDate,
      isVerified: isVerified ?? this.isVerified,
      tournamentIds: tournamentIds ?? this.tournamentIds,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'Organizer(id: $id, organizationName: $organizationName, email: $email, phone: $phone, address: $address, registrationDate: $registrationDate, isVerified: $isVerified, tournamentIds: $tournamentIds)';
  }
}
