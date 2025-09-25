// User model representing both admin and regular users
class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isAdmin;
  final String? phone;
  final String? address;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.isAdmin,
    this.phone,
    this.address,
  });

  // Create a copy of this user with updated fields
  User copyWith({
    String? name,
    String? email,
    String? photoUrl,
    bool? isAdmin,
    String? phone,
    String? address,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  // For demonstration purposes - sample admin user
  static User sampleAdmin() {
    return User(
      id: '1',
      name: 'Admin User',
      email: 'admin@vetra.com',
      photoUrl:
          'https://ui-avatars.com/api/?name=Admin+User&background=6f42c1&color=fff',
      isAdmin: true,
      phone: '+1 234 567 8900',
      address: '123 Admin Street, City',
    );
  }

  // For demonstration purposes - sample regular user
  static User sampleUser() {
    return User(
      id: '2',
      name: 'John Doe',
      email: 'john@example.com',
      photoUrl:
          'https://ui-avatars.com/api/?name=John+Doe&background=94c142&color=fff',
      isAdmin: false,
      phone: '+1 987 654 3210',
      address: '456 User Avenue, Town',
    );
  }
}
