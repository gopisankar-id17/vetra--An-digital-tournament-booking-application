import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../services/tournament_service.dart';
import '../../utils/app_theme.dart';
import 'add_tournament_page.dart';
import 'tournament_details_page.dart';

class TournamentsListPage extends StatefulWidget {
  const TournamentsListPage({Key? key}) : super(key: key);

  @override
  State<TournamentsListPage> createState() => _TournamentsListPageState();
}

class _TournamentsListPageState extends State<TournamentsListPage> {
  final TournamentService _tournamentService = TournamentService();
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
      final tournaments = await _tournamentService.getAllTournaments();
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tournaments',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDarkColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          IconButton(
            onPressed: _loadTournaments,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTournament(),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Tournament'),
        elevation: 2,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : _tournaments.isEmpty
            ? _buildEmptyState()
            : _buildTournamentsList(),
      ),
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
          ElevatedButton.icon(
            onPressed: () => _navigateToAddTournament(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Tournament'),
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

    switch (tournament.status) {
      case TournamentStatus.upcoming:
        statusColor = const Color(0xFF3498DB);
        statusLabel = 'UPCOMING';
        statusIcon = Icons.schedule;
        break;
      case TournamentStatus.ongoing:
        statusColor = const Color(0xFFE74C3C);
        statusLabel = 'LIVE';
        statusIcon = Icons.play_circle_filled;
        break;
      case TournamentStatus.completed:
        statusColor = const Color(0xFF27AE60);
        statusLabel = 'COMPLETED';
        statusIcon = Icons.check_circle;
        break;
      case TournamentStatus.cancelled:
        statusColor = Colors.red;
        statusLabel = 'CANCELLED';
        statusIcon = Icons.cancel;
        break;
    }

    return GestureDetector(
      onTap: () => _navigateToTournamentDetails(tournament),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDarkColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tournament.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMediumColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tournament details in a grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_on,
                      tournament.location,
                      AppTheme.textMediumColor,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      _formatDate(tournament.startDate),
                      AppTheme.textMediumColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.people,
                      '${tournament.currentParticipants}/${tournament.maxParticipants}',
                      AppTheme.textMediumColor,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      '₹${tournament.entryFee.toInt()}',
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              // Categories
              if (tournament.categories.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tournament.categories.take(4).map((category) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, size: 16, color: textColor.withOpacity(0.7)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: textColor == AppTheme.primaryColor
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _navigateToTournamentDetails(Tournament tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentDetailsPage(tournament: tournament),
      ),
    );
  }

  void _navigateToAddTournament() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTournamentPage(
          onTournamentCreated: (tournament) {
            _showSuccessSnackBar(
              'Tournament "${tournament.name}" created successfully!',
            );
            _loadTournaments(); // Refresh the list
          },
        ),
      ),
    );

    // Refresh the list when returning from add tournament page
    if (result != null) {
      _loadTournaments();
    }
  }
}
