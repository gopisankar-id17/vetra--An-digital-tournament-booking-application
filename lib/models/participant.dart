import 'package:flutter/material.dart';

enum ParticipantStatus { pending, approved, rejected, withdrawn }

class Participant {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime registrationDate;
  final ParticipantStatus status;
  final String? rejectionReason;
  final Map<String, dynamic>? additionalInfo;

  Participant({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.registrationDate,
    required this.status,
    this.rejectionReason,
    this.additionalInfo,
  });

  // Factory constructor for creating from JSON/Map
  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      registrationDate: DateTime.parse(map['registrationDate']),
      status: ParticipantStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ParticipantStatus.pending,
      ),
      rejectionReason: map['rejectionReason'],
      additionalInfo: map['additionalInfo'],
    );
  }

  // Convert to JSON/Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'registrationDate': registrationDate.toIso8601String(),
      'status': status.name,
      'rejectionReason': rejectionReason,
      'additionalInfo': additionalInfo,
    };
  }

  // Copy with method for updates
  Participant copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? registrationDate,
    ParticipantStatus? status,
    String? rejectionReason,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Participant(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // Status color getter
  Color get statusColor {
    switch (status) {
      case ParticipantStatus.approved:
        return const Color(0xFF28A745); // Green
      case ParticipantStatus.pending:
        return const Color(0xFFFFC107); // Yellow
      case ParticipantStatus.rejected:
        return const Color(0xFFDC3545); // Red
      case ParticipantStatus.withdrawn:
        return const Color(0xFF6C757D); // Gray
    }
  }

  // Status display name
  String get statusDisplayName {
    switch (status) {
      case ParticipantStatus.approved:
        return 'Approved';
      case ParticipantStatus.pending:
        return 'Pending';
      case ParticipantStatus.rejected:
        return 'Rejected';
      case ParticipantStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}
