import 'package:flutter/material.dart';

enum RequestStatus { pending, approved, rejected }

class TournamentRequest {
  final String id;
  final String tournamentName;
  final String organizerName;
  final String organizerUserId;
  final String sportType;
  final String location;
  final DateTime dateTime;
  final double? entryFee;
  final String shortDescription;
  final String fullDescription;
  final RequestStatus status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? adminRemarks;
  final String? imageUrl;
  final int maxParticipants;
  final String contactInfo;

  TournamentRequest({
    required this.id,
    required this.tournamentName,
    required this.organizerName,
    required this.organizerUserId,
    required this.sportType,
    required this.location,
    required this.dateTime,
    this.entryFee,
    required this.shortDescription,
    required this.fullDescription,
    this.status = RequestStatus.pending,
    required this.submittedAt,
    this.reviewedAt,
    this.adminRemarks,
    this.imageUrl,
    required this.maxParticipants,
    required this.contactInfo,
  });

  // Get status color
  Color get statusColor {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
    }
  }

  // Get status icon
  IconData get statusIcon {
    switch (status) {
      case RequestStatus.pending:
        return Icons.access_time;
      case RequestStatus.approved:
        return Icons.check_circle;
      case RequestStatus.rejected:
        return Icons.cancel;
    }
  }

  // Get status label
  String get statusLabel {
    switch (status) {
      case RequestStatus.pending:
        return 'PENDING';
      case RequestStatus.approved:
        return 'APPROVED';
      case RequestStatus.rejected:
        return 'REJECTED';
    }
  }

  // Copy with method for status updates
  TournamentRequest copyWith({
    RequestStatus? status,
    DateTime? reviewedAt,
    String? adminRemarks,
  }) {
    return TournamentRequest(
      id: id,
      tournamentName: tournamentName,
      organizerName: organizerName,
      organizerUserId: organizerUserId,
      sportType: sportType,
      location: location,
      dateTime: dateTime,
      entryFee: entryFee,
      shortDescription: shortDescription,
      fullDescription: fullDescription,
      status: status ?? this.status,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      adminRemarks: adminRemarks ?? this.adminRemarks,
      imageUrl: imageUrl,
      maxParticipants: maxParticipants,
      contactInfo: contactInfo,
    );
  }

  // Sample tournament requests for demonstration
  static List<TournamentRequest> getSampleRequests() {
    return [
      TournamentRequest(
        id: 'req_001',
        tournamentName: 'Summer Football League 2025',
        organizerName: 'Alex Johnson',
        organizerUserId: 'user_001',
        sportType: 'Football',
        location: 'City Sports Complex',
        dateTime: DateTime.now().add(const Duration(days: 15)),
        entryFee: 500.0,
        shortDescription: 'A competitive football league for all skill levels.',
        fullDescription:
            'Join our exciting Summer Football League 2025! This tournament welcomes players of all skill levels and promises thrilling matches, professional referees, and exciting prizes. Registration includes team jersey and refreshments.',
        status: RequestStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        maxParticipants: 16,
        contactInfo: 'alex.johnson@email.com',
        imageUrl: 'https://example.com/football-tournament.jpg',
      ),
      TournamentRequest(
        id: 'req_002',
        tournamentName: 'Chess Championship',
        organizerName: 'Sarah Williams',
        organizerUserId: 'user_002',
        sportType: 'Chess',
        location: 'Community Center Hall',
        dateTime: DateTime.now().add(const Duration(days: 20)),
        entryFee: 200.0,
        shortDescription:
            'Strategic chess tournament for mind sport enthusiasts.',
        fullDescription:
            'Test your strategic skills in our Chess Championship! Open to all ages and skill levels. Tournament format includes multiple rounds with professional arbiters. Winners receive trophies and cash prizes.',
        status: RequestStatus.pending,
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        maxParticipants: 32,
        contactInfo: 'sarah.w@email.com',
      ),
      TournamentRequest(
        id: 'req_003',
        tournamentName: 'Basketball Showdown',
        organizerName: 'Mike Davis',
        organizerUserId: 'user_003',
        sportType: 'Basketball',
        location: 'Indoor Sports Arena',
        dateTime: DateTime.now().add(const Duration(days: 10)),
        entryFee: 300.0,
        shortDescription: 'High-energy basketball tournament.',
        fullDescription:
            'Experience the thrill of competitive basketball in our showdown tournament. Professional court, experienced referees, and live streaming for all matches.',
        status: RequestStatus.approved,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
        reviewedAt: DateTime.now().subtract(const Duration(hours: 12)),
        adminRemarks: 'Excellent organization plan. All requirements met.',
        maxParticipants: 12,
        contactInfo: 'mike.davis@email.com',
      ),
      TournamentRequest(
        id: 'req_004',
        tournamentName: 'Table Tennis Challenge',
        organizerName: 'Emma Thompson',
        organizerUserId: 'user_004',
        sportType: 'Table Tennis',
        location: 'Recreation Center',
        dateTime: DateTime.now().add(const Duration(days: 8)),
        entryFee: 150.0,
        shortDescription: 'Fast-paced table tennis competition.',
        fullDescription:
            'Join our Table Tennis Challenge for quick reflexes and precision play. Single and double categories available.',
        status: RequestStatus.rejected,
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
        reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
        adminRemarks: 'Venue booking conflicts with existing events.',
        maxParticipants: 24,
        contactInfo: 'emma.t@email.com',
      ),
    ];
  }
}
