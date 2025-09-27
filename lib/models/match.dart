import 'package:flutter/material.dart';

enum MatchStatus { scheduled, ongoing, completed, cancelled, postponed }

enum MatchResult { player1Win, player2Win, draw, noContest }

class Match {
  final String id;
  final String tournamentId;
  final String? player1Id;
  final String? player2Id;
  final String? player1Name;
  final String? player2Name;
  final String? player1ImageUrl;
  final String? player2ImageUrl;
  final int? player1Score;
  final int? player2Score;
  final MatchStatus status;
  final MatchResult? result;
  final DateTime? scheduledTime;
  final DateTime? actualStartTime;
  final DateTime? completionTime;
  final int round;
  final int matchNumber;
  final String? venue;
  final String? notes;
  final String? winnerId;
  final bool isBye; // For cases where a player gets a bye

  Match({
    required this.id,
    required this.tournamentId,
    this.player1Id,
    this.player2Id,
    this.player1Name,
    this.player2Name,
    this.player1ImageUrl,
    this.player2ImageUrl,
    this.player1Score,
    this.player2Score,
    required this.status,
    this.result,
    this.scheduledTime,
    this.actualStartTime,
    this.completionTime,
    required this.round,
    required this.matchNumber,
    this.venue,
    this.notes,
    this.winnerId,
    this.isBye = false,
  });

  // Factory constructor for creating from JSON/Map
  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] ?? '',
      tournamentId: map['tournamentId'] ?? '',
      player1Id: map['player1Id'],
      player2Id: map['player2Id'],
      player1Name: map['player1Name'],
      player2Name: map['player2Name'],
      player1ImageUrl: map['player1ImageUrl'],
      player2ImageUrl: map['player2ImageUrl'],
      player1Score: map['player1Score'],
      player2Score: map['player2Score'],
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.scheduled,
      ),
      result: map['result'] != null
          ? MatchResult.values.firstWhere(
              (e) => e.name == map['result'],
              orElse: () => MatchResult.noContest,
            )
          : null,
      scheduledTime: map['scheduledTime'] != null
          ? DateTime.parse(map['scheduledTime'])
          : null,
      actualStartTime: map['actualStartTime'] != null
          ? DateTime.parse(map['actualStartTime'])
          : null,
      completionTime: map['completionTime'] != null
          ? DateTime.parse(map['completionTime'])
          : null,
      round: map['round'] ?? 1,
      matchNumber: map['matchNumber'] ?? 1,
      venue: map['venue'],
      notes: map['notes'],
      winnerId: map['winnerId'],
      isBye: map['isBye'] ?? false,
    );
  }

  // Convert to JSON/Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'player1ImageUrl': player1ImageUrl,
      'player2ImageUrl': player2ImageUrl,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'status': status.name,
      'result': result?.name,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'actualStartTime': actualStartTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'round': round,
      'matchNumber': matchNumber,
      'venue': venue,
      'notes': notes,
      'winnerId': winnerId,
      'isBye': isBye,
    };
  }

  // Copy with method for updates
  Match copyWith({
    String? id,
    String? tournamentId,
    String? player1Id,
    String? player2Id,
    String? player1Name,
    String? player2Name,
    String? player1ImageUrl,
    String? player2ImageUrl,
    int? player1Score,
    int? player2Score,
    MatchStatus? status,
    MatchResult? result,
    DateTime? scheduledTime,
    DateTime? actualStartTime,
    DateTime? completionTime,
    int? round,
    int? matchNumber,
    String? venue,
    String? notes,
    String? winnerId,
    bool? isBye,
  }) {
    return Match(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      player1Id: player1Id ?? this.player1Id,
      player2Id: player2Id ?? this.player2Id,
      player1Name: player1Name ?? this.player1Name,
      player2Name: player2Name ?? this.player2Name,
      player1ImageUrl: player1ImageUrl ?? this.player1ImageUrl,
      player2ImageUrl: player2ImageUrl ?? this.player2ImageUrl,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      status: status ?? this.status,
      result: result ?? this.result,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      completionTime: completionTime ?? this.completionTime,
      round: round ?? this.round,
      matchNumber: matchNumber ?? this.matchNumber,
      venue: venue ?? this.venue,
      notes: notes ?? this.notes,
      winnerId: winnerId ?? this.winnerId,
      isBye: isBye ?? this.isBye,
    );
  }

  // Status color getter
  Color get statusColor {
    switch (status) {
      case MatchStatus.completed:
        return const Color(0xFF28A745); // Green
      case MatchStatus.ongoing:
        return const Color(0xFF17A2B8); // Blue
      case MatchStatus.scheduled:
        return const Color(0xFFFFC107); // Yellow
      case MatchStatus.cancelled:
        return const Color(0xFFDC3545); // Red
      case MatchStatus.postponed:
        return const Color(0xFF6C757D); // Gray
    }
  }

  // Status display name
  String get statusDisplayName {
    switch (status) {
      case MatchStatus.completed:
        return 'Completed';
      case MatchStatus.ongoing:
        return 'Ongoing';
      case MatchStatus.scheduled:
        return 'Scheduled';
      case MatchStatus.cancelled:
        return 'Cancelled';
      case MatchStatus.postponed:
        return 'Postponed';
    }
  }

  // Get formatted score
  String get formattedScore {
    if (player1Score == null && player2Score == null) {
      return 'vs';
    }
    return '${player1Score ?? 0} - ${player2Score ?? 0}';
  }

  // Check if match has valid players
  bool get hasValidPlayers {
    return (player1Id != null || player1Name != null) &&
        (player2Id != null || player2Name != null) &&
        !isBye;
  }

  // Get round display name
  String get roundDisplayName {
    switch (round) {
      case 1:
        return 'Final';
      case 2:
        return 'Semi-Final';
      case 3:
        return 'Quarter-Final';
      default:
        return 'Round $round';
    }
  }
}
