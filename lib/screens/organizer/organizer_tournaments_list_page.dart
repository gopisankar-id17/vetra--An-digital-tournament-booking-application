import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/organizer_service.dart';
import '../../services/session_service.dart';
import '../../utils/app_theme.dart';
import 'organizer_tournament_details_page.dart';

class OrganizerTournamentsListPage extends StatefulWidget {
  const OrganizerTournamentsListPage({Key? key}) : super(key: key);

  @override
  State<OrganizerTournamentsListPage> createState() =>
      _OrganizerTournamentsListPageState();
}

class _OrganizerTournamentsListPageState
    extends State<OrganizerTournamentsListPage> {
  List<Tournament> _tournaments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    try {
      setState(() => _isLoading = true);

      // Get current organizer session
      final organizerData = await SessionService.getOrganizerSession();

      if (organizerData['id'] == null || organizerData['id']!.isEmpty) {
        _showErrorSnackBar('Please login as organizer first');
        setState(() => _isLoading = false);
        return;
      }

      // Get tournaments for this organizer only
      final tournaments = await OrganizerService.getOrganizerTournaments(
        organizerData['id']!,
      );

      setState(() {
        _tournaments = tournaments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load tournaments: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Debug method to create a test tournament
  Future<void> _createTestTournament() async {
    try {
      final organizerData = await SessionService.getOrganizerSession();
      if (organizerData['id'] == null || organizerData['id']!.isEmpty) {
        _showErrorSnackBar('No organizer session found');
        return;
      }

      final testTournament = Tournament(
        id: '',
        name: 'Debug Test Tournament ${DateTime.now().millisecondsSinceEpoch}',
        description: 'This is a test tournament created for debugging purposes',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 8)),
        registrationDeadline: DateTime.now().add(const Duration(days: 5)),
        location: 'Debug Location',
        organizerId: organizerData['id']!,
        organizerName: organizerData['organization'] ?? 'Test Organizer',
        organizer: organizerData['organization'] ?? 'Test Organizer',
        maxParticipants: 16,
        currentParticipants: 0,
        entryFee: 100.0,
        status: TournamentStatus.upcoming,
        categories: ['Debug'],
        format: TournamentFormat.singleElimination,
        mode: TournamentMode.offline,
        rules: 'Debug rules',
        prizes: 'Debug prizes',
        contactInfo: organizerData['email'] ?? 'test@debug.com',
        ticketTypes: {'General': 100.0},
        participantsCount: 0,
        prizePool: 0.0,
        organizerPhotoUrl: '',
        organizerPastTournaments: 0,
        startTime: '10:00',
      );

      final tournamentId = await OrganizerService.createTournament(
        organizerId: organizerData['id']!,
        tournament: testTournament,
      );

      if (tournamentId != null) {
        _showErrorSnackBar('Test tournament created successfully!');
        await _loadTournaments(); // Refresh the list
      } else {
        _showErrorSnackBar('Failed to create test tournament');
      }
    } catch (e) {
      _showErrorSnackBar('Error creating test tournament: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : _tournaments.isEmpty
          ? _buildEmptyState()
          : _buildTournamentsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tournaments yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first tournament to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          // Debug buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _createTestTournament,
                icon: const Icon(Icons.bug_report),
                label: const Text('Create Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsList() {
    return RefreshIndicator(
      onRefresh: _loadTournaments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tournaments.length,
        itemBuilder: (context, index) {
          final tournament = _tournaments[index];
          return _buildTournamentCard(tournament);
        },
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    // Determine status styling
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    final now = DateTime.now();
    if (tournament.startDate.isAfter(now)) {
      statusColor = Colors.blue;
      statusLabel = 'UPCOMING';
      statusIcon = Icons.schedule;
    } else if (tournament.startDate.isBefore(now) &&
        tournament.endDate.isAfter(now)) {
      statusColor = Colors.green;
      statusLabel = 'ONGOING';
      statusIcon = Icons.play_circle_filled;
    } else {
      statusColor = Colors.grey;
      statusLabel = 'COMPLETED';
      statusIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrganizerTournamentDetailsPage(tournament: tournament),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tournament image
              if (tournament.imageUrl != null &&
                  tournament.imageUrl!.isNotEmpty)
                Container(
                  height: 120,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      tournament.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor.withValues(alpha: 0.3),
                              statusColor.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: statusColor,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Info rows
              _buildInfoRow(Icons.location_on_outlined, tournament.location),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today_outlined,
                '${_formatDate(tournament.startDate)} - ${_formatDate(tournament.endDate)}',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.people_outline,
                '${tournament.currentParticipants}/${tournament.maxParticipants} participants',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.attach_money_outlined,
                '\$${tournament.entryFee.toStringAsFixed(2)}',
              ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Participants progress
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: tournament.maxParticipants > 0
                              ? tournament.currentParticipants /
                                    tournament.maxParticipants
                              : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Action buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Edit tournament
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit functionality coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        color: AppTheme.primaryColor,
                        tooltip: 'Edit Tournament',
                      ),
                      IconButton(
                        onPressed: () {
                          _showDeleteConfirmation(tournament);
                        },
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red,
                        tooltip: 'Delete Tournament',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Text(
          'Are you sure you want to delete "${tournament.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTournament(tournament);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTournament(Tournament tournament) async {
    try {
      await OrganizerService.deleteTournament(tournament.id);
      _showSuccessSnackBar(
        'Tournament "${tournament.name}" deleted successfully',
      );
      _loadTournaments(); // Refresh list
    } catch (e) {
      _showErrorSnackBar('Failed to delete tournament: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
