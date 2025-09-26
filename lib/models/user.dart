import 'package:flutter/material.dart';

// User model representing both admin and regular users
class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final bool isAdmin;
  final String? phone;
  final String? address;
  final String? bio;
  final List<String>? preferredCategories;
  final Map<String, dynamic>? socialProfiles;
  final Map<String, dynamic>? stats;
  final String role;
  final DateTime registrationDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.isAdmin,
    this.phone,
    this.address,
    this.bio,
    this.preferredCategories,
    this.socialProfiles,
    this.stats,
    this.role = 'user',
    DateTime? registrationDate,
  }) : this.registrationDate = registrationDate ?? DateTime.now();

  // Create a copy of this user with updated fields
  User copyWith({
    String? name,
    String? email,
    String? photoUrl,
    bool? isAdmin,
    String? phone,
    String? address,
    String? bio,
    List<String>? preferredCategories,
    Map<String, dynamic>? socialProfiles,
    Map<String, dynamic>? stats,
    String? role,
    DateTime? registrationDate,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      socialProfiles: socialProfiles ?? this.socialProfiles,
      stats: stats ?? this.stats,
      role: role ?? this.role,
      registrationDate: registrationDate ?? this.registrationDate,
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
      role: 'admin',
      registrationDate: DateTime.now().subtract(const Duration(days: 365)),
      stats: {'tournaments': 50, 'wins': 0, 'bookings': 0, 'rating': 0},
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
      bio: 'Passionate chess player with 5+ years of tournament experience.',
      preferredCategories: ['Chess', 'Board Games', 'Strategy'],
      socialProfiles: {
        'instagram': 'johndoe',
        'facebook': 'johndoe.chess',
        'twitter': 'johndoe_chess',
      },
      stats: {'tournaments': 12, 'wins': 5, 'bookings': 28, 'rating': 1850},
      role: 'user',
      registrationDate: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  // Get color based on user role
  Color getRoleColor() {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'organizer':
        return Colors.blue;
      case 'premium':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  // Get user role display name
  String getRoleDisplayName() {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'organizer':
        return 'Tournament Organizer';
      case 'premium':
        return 'Premium User';
      default:
        return 'Standard User';
    }
  }

  // Sample users for demonstration
  static List<User> getSampleUsers() {
    return [
      sampleAdmin(),
      sampleUser(),
      User(
        id: '3',
        name: 'Jane Smith',
        email: 'jane@example.com',
        photoUrl:
            'https://ui-avatars.com/api/?name=Jane+Smith&background=94c142&color=fff',
        isAdmin: false,
        phone: '+1 555 123 4567',
        address: '789 Player Street, City',
        bio: 'Competitive gamer with focus on eSports tournaments.',
        role: 'premium',
        registrationDate: DateTime.now().subtract(const Duration(days: 120)),
      ),
      User(
        id: '4',
        name: 'Robert Johnson',
        email: 'robert@example.com',
        photoUrl:
            'https://ui-avatars.com/api/?name=Robert+Johnson&background=94c142&color=fff',
        isAdmin: false,
        phone: '+1 444 987 6543',
        address: '101 Gamer Avenue, Town',
        bio: 'Basketball enthusiast and tournament participant.',
        role: 'user',
        registrationDate: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }
}
