import 'package:flutter/material.dart';

// Tournament model representing a tournament event
class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String organizerId;
  final String organizerName;
  final String? imageUrl;
  final int maxParticipants;
  final int currentParticipants;
  final double entryFee;
  final TournamentStatus status;
  final List<String> categories;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.organizerId,
    required this.organizerName,
    this.imageUrl,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.entryFee,
    required this.status,
    required this.categories,
  });

  // Returns the availability percentage of the tournament
  double get availabilityPercentage {
    if (maxParticipants == 0) return 0;
    return currentParticipants / maxParticipants;
  }

  // Returns the color based on tournament status
  Color get statusColor {
    switch (status) {
      case TournamentStatus.upcoming:
        return Colors.blue;
      case TournamentStatus.ongoing:
        return Colors.green;
      case TournamentStatus.completed:
        return Colors.grey;
      case TournamentStatus.cancelled:
        return Colors.red;
    }
  }

  // Sample tournaments for demonstration
  static List<Tournament> getSampleTournaments() {
    return [
      Tournament(
        id: '1',
        name: 'Summer Chess Championship',
        description:
            'A prestigious chess tournament open for all skill levels.',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 12)),
        location: 'Central Community Center',
        organizerId: '1',
        organizerName: 'Chess Masters Association',
        imageUrl:
            'https://images.unsplash.com/photo-1528819622765-d6bcf132f793?q=80&w=300',
        maxParticipants: 64,
        currentParticipants: 42,
        entryFee: 2500.0,
        status: TournamentStatus.upcoming,
        categories: ['Chess', 'Indoor', 'Strategy'],
      ),
      Tournament(
        id: '2',
        name: 'Basketball Tournament 2025',
        description: 'Annual basketball tournament for teams of 5 players.',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        location: 'Sports Arena',
        organizerId: '1',
        organizerName: 'City Sports Department',
        imageUrl:
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=300',
        maxParticipants: 16,
        currentParticipants: 16,
        entryFee: 10000.0,
        status: TournamentStatus.upcoming,
        categories: ['Basketball', 'Team Sport', 'Outdoor'],
      ),
      Tournament(
        id: '3',
        name: 'eSports League - League of Legends',
        description: 'Competitive eSports tournament for LoL teams.',
        startDate: DateTime.now().add(const Duration(days: -5)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        location: 'Virtual / Gaming Center',
        organizerId: '1',
        organizerName: 'eSports Management Group',
        imageUrl:
            'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=300',
        maxParticipants: 32,
        currentParticipants: 28,
        entryFee: 5000.0,
        status: TournamentStatus.ongoing,
        categories: ['eSports', 'Gaming', 'Team Competition'],
      ),
      Tournament(
        id: '4',
        name: 'Tennis Open 2025',
        description: 'Singles and doubles tennis tournament.',
        startDate: DateTime.now().add(const Duration(days: -30)),
        endDate: DateTime.now().add(const Duration(days: -25)),
        location: 'Tennis Club',
        organizerId: '1',
        organizerName: 'Tennis Association',
        imageUrl:
            'https://images.unsplash.com/photo-1622279457486-28f24525f5d3?q=80&w=300',
        maxParticipants: 128,
        currentParticipants: 128,
        entryFee: 7500.0,
        status: TournamentStatus.completed,
        categories: ['Tennis', 'Outdoor', 'Singles', 'Doubles'],
      ),
      Tournament(
        id: '5',
        name: 'Cricket Premier League',
        description: 'T20 cricket tournament for local teams.',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 25)),
        location: 'Sports Complex',
        organizerId: '1',
        organizerName: 'Cricket Association',
        imageUrl:
            'https://images.unsplash.com/photo-1531415074968-036ba1b575da?q=80&w=300',
        maxParticipants: 8,
        currentParticipants: 6,
        entryFee: 15000.0,
        status: TournamentStatus.upcoming,
        categories: ['Cricket', 'Team Sport', 'Outdoor'],
      ),
      Tournament(
        id: '6',
        name: 'Badminton Singles Championship',
        description: 'Individual badminton tournament.',
        startDate: DateTime.now().add(const Duration(days: -10)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        location: 'Indoor Sports Hall',
        organizerId: '1',
        organizerName: 'Badminton Club',
        imageUrl:
            'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?q=80&w=300',
        maxParticipants: 64,
        currentParticipants: 58,
        entryFee: 3000.0,
        status: TournamentStatus.ongoing,
        categories: ['Badminton', 'Individual', 'Indoor'],
      ),
      Tournament(
        id: '7',
        name: 'Football League 2024',
        description: 'Inter-college football tournament.',
        startDate: DateTime.now().add(const Duration(days: -60)),
        endDate: DateTime.now().add(const Duration(days: -45)),
        location: 'Football Ground',
        organizerId: '1',
        organizerName: 'Football Federation',
        imageUrl:
            'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?q=80&w=300',
        maxParticipants: 16,
        currentParticipants: 16,
        entryFee: 8000.0,
        status: TournamentStatus.completed,
        categories: ['Football', 'Team Sport', 'Outdoor'],
      ),
      Tournament(
        id: '8',
        name: 'Swimming Championship',
        description: 'Annual swimming competition.',
        startDate: DateTime.now().add(const Duration(days: -40)),
        endDate: DateTime.now().add(const Duration(days: -38)),
        location: 'Aquatic Center',
        organizerId: '1',
        organizerName: 'Swimming Association',
        imageUrl:
            'https://images.unsplash.com/photo-1544551763-46a013bb70d5?q=80&w=300',
        maxParticipants: 50,
        currentParticipants: 50,
        entryFee: 2000.0,
        status: TournamentStatus.completed,
        categories: ['Swimming', 'Individual', 'Aquatic'],
      ),
    ];
  }
}

// Enum representing the status of a tournament
enum TournamentStatus { upcoming, ongoing, completed, cancelled }
