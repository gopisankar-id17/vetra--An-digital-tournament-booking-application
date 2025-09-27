import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import 'tournament_details_page.dart';

class TournamentDetailsDemo extends StatelessWidget {
  const TournamentDetailsDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock tournament data for demonstration
    final mockTournament = Tournament(
      id: 'demo-tournament-1',
      name: 'Spring Football Championship 2025',
      description:
          'Annual spring football championship featuring teams from across the region. This tournament showcases the best talent and provides an exciting competition for players and fans alike.',
      startDate: DateTime(2025, 4, 15),
      endDate: DateTime(2025, 4, 20),
      registrationDeadline: DateTime(2025, 4, 1),
      location: 'Central Sports Stadium, Downtown',
      organizer: 'Regional Sports Association',
      organizerName: 'John Anderson',
      imageUrl: 'https://example.com/tournament-image.jpg',
      maxParticipants: 32,
      currentParticipants: 18,
      entryFee: 500.0,
      status: TournamentStatus.upcoming,
      categories: ['Football', '11v11', 'Adult'],
      format: TournamentFormat.singleElimination,
      mode: TournamentMode.offline,
      rules:
          'Standard FIFA rules apply. Each match will be 90 minutes with 15-minute halftime.',
      prizes: '1st Place: ₹50,000, 2nd Place: ₹25,000, 3rd Place: ₹10,000',
      contactInfo: 'tournament@sports.com, +91 98765 43210',
      ticketTypes: {'General': 100.0, 'VIP': 250.0},
      participantsCount: 18,
      prizePool: 85000.0,
      organizerPhotoUrl: 'https://example.com/organizer.jpg',
      organizerPastTournaments: 15,
      startTime: '10:00 AM',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournament Demo'),
        backgroundColor: const Color(0xFF6f42c1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tournament Details Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              'Click the button below to view the comprehensive Tournament Details page with all management features:',
              style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mockTournament.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mockTournament.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${mockTournament.currentParticipants}/${mockTournament.maxParticipants} Participants',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'UPCOMING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TournamentDetailsPage(tournament: mockTournament),
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Tournament Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6f42c1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '✅ Features Included:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 10),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Overview Tab: Tournament info, status, action buttons'),
                Text(
                  '• Participants Tab: Approve/reject participants, search & filter',
                ),
                Text('• Fixtures Tab: Bracket view, match management'),
                Text('• Scores Tab: Match results, score editing'),
                Text('• Notifications Tab: Send announcements, history'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
