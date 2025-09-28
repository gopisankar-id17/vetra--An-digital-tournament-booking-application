import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      statusColor = const Color.fromARGB(255, 163, 207, 243);
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

    // Calculate days remaining or elapsed
    String timeInfo;
    if (tournament.startDate.isAfter(now)) {
      final daysRemaining = tournament.startDate.difference(now).inDays;
      timeInfo = 'Starts in $daysRemaining days';
    } else if (tournament.endDate.isAfter(now)) {
      final daysElapsed = now.difference(tournament.startDate).inDays;
      timeInfo = 'Started $daysElapsed days ago';
    } else {
      final daysElapsed = now.difference(tournament.endDate).inDays;
      timeInfo = 'Ended $daysElapsed days ago';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Show subtle feedback when tapped
          HapticFeedback.mediumImpact();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrganizerTournamentDetailsPage(tournament: tournament),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, statusColor.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament image with gradient overlay
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      tournament.imageUrl ??
                          'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=800&q=80',
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    // Status badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              statusLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Tournament title with gradient background
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Text(
                          tournament.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time info
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.timelapse, size: 16, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            timeInfo,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Info rows with nicer layout
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRowEnhanced(
                            Icons.calendar_today_outlined,
                            '${_formatDate(tournament.startDate)} - ${_formatDate(tournament.endDate)}',
                            'Schedule',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoRowEnhanced(
                            Icons.location_on_outlined,
                            tournament.location,
                            'Location',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRowEnhanced(
                            Icons.people_outline,
                            '${tournament.currentParticipants}/${tournament.maxParticipants}',
                            'Participants',
                          ),
                        ),
                        Expanded(
                          child: _buildInfoRowEnhanced(
                            Icons.currency_rupee,
                            '${tournament.entryFee.toStringAsFixed(0)}',
                            'Entry Fee',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Participants progress with percentage
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Registration Progress',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${(tournament.maxParticipants > 0 ? (tournament.currentParticipants / tournament.maxParticipants) * 100 : 0).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: tournament.maxParticipants > 0
                                ? tournament.currentParticipants /
                                      tournament.maxParticipants
                                : 0,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // View details button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrganizerTournamentDetailsPage(
                                    tournament: tournament,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildInfoRowEnhanced(IconData icon, String text, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDarkColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Delete functionality removed as requested

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showUpdateStatusDialog(Tournament tournament) {
    // Current status for the dropdown
    TournamentStatus selectedStatus = tournament.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Update Tournament Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tournament: ${tournament.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Select new status:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<TournamentStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: TournamentStatus.values.map((status) {
                    String label;
                    Color color;

                    switch (status) {
                      case TournamentStatus.upcoming:
                        label = 'Upcoming';
                        color = Colors.blue;
                        break;
                      case TournamentStatus.ongoing:
                        label = 'Ongoing';
                        color = Colors.green;
                        break;
                      case TournamentStatus.completed:
                        label = 'Completed';
                        color = Colors.grey;
                        break;
                      case TournamentStatus.cancelled:
                        label = 'Cancelled';
                        color = Colors.red;
                        break;
                    }

                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setStateDialog(() {
                        selectedStatus = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateTournamentStatus(tournament, selectedStatus);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Frontend-only method to update tournament status (doesn't affect backend)
  void _updateTournamentStatus(
    Tournament tournament,
    TournamentStatus newStatus,
  ) {
    // Create a new tournament object with the updated status
    final updatedTournament = Tournament(
      id: tournament.id,
      name: tournament.name,
      description: tournament.description,
      startDate: tournament.startDate,
      endDate: tournament.endDate,
      registrationDeadline: tournament.registrationDeadline,
      location: tournament.location,
      organizerId: tournament.organizerId,
      organizerName: tournament.organizerName,
      organizer: tournament.organizer,
      imageUrl: tournament.imageUrl,
      maxParticipants: tournament.maxParticipants,
      currentParticipants: tournament.currentParticipants,
      entryFee: tournament.entryFee,
      status: newStatus, // Updated status
      categories: tournament.categories,
      format: tournament.format,
      mode: tournament.mode,
      rules: tournament.rules,
      prizes: tournament.prizes,
      contactInfo: tournament.contactInfo,
    );

    // Update the tournament in the state
    setState(() {
      final index = _tournaments.indexWhere((t) => t.id == tournament.id);
      if (index != -1) {
        _tournaments[index] = updatedTournament;
      }
    });

    _showSuccessSnackBar('Tournament status updated successfully');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
