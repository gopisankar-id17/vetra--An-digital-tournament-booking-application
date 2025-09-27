import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/participant.dart';
import '../../models/match.dart';
import '../../models/notification.dart' as AppNotification;
import '../../utils/app_theme.dart';

class TournamentDetailsPage extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailsPage({Key? key, required this.tournament})
    : super(key: key);

  @override
  State<TournamentDetailsPage> createState() => _TournamentDetailsPageState();
}

class _TournamentDetailsPageState extends State<TournamentDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock data - replace with actual data from your services
  List<Participant> participants = [];
  List<Match> matches = [];
  List<AppNotification.Notification> notifications = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Simple date formatting functions
  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTimeShort(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return monthNames[month - 1];
  }

  void _loadMockData() {
    // Mock participants data
    participants = [
      Participant(
        id: '1',
        userId: 'user1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        registrationDate: DateTime.now().subtract(const Duration(days: 5)),
        status: ParticipantStatus.approved,
      ),
      Participant(
        id: '2',
        userId: 'user2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '+1234567891',
        registrationDate: DateTime.now().subtract(const Duration(days: 3)),
        status: ParticipantStatus.pending,
      ),
      Participant(
        id: '3',
        userId: 'user3',
        name: 'Mike Johnson',
        email: 'mike@example.com',
        phone: '+1234567892',
        registrationDate: DateTime.now().subtract(const Duration(days: 2)),
        status: ParticipantStatus.approved,
      ),
    ];

    // Mock matches data
    matches = [
      Match(
        id: '1',
        tournamentId: widget.tournament.id,
        player1Name: 'John Doe',
        player2Name: 'Jane Smith',
        player1Score: 21,
        player2Score: 18,
        status: MatchStatus.completed,
        result: MatchResult.player1Win,
        round: 3,
        matchNumber: 1,
        winnerId: 'user1',
      ),
      Match(
        id: '2',
        tournamentId: widget.tournament.id,
        player1Name: 'Mike Johnson',
        player2Name: 'TBD',
        status: MatchStatus.scheduled,
        round: 3,
        matchNumber: 2,
      ),
    ];

    // Mock notifications
    notifications = [
      AppNotification.Notification(
        id: '1',
        userId: 'admin',
        title: 'Tournament Starting Soon',
        message: 'Your tournament will start in 2 hours. Please be ready!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        type: AppNotification.NotificationType.announcement,
      ),
      AppNotification.Notification(
        id: '2',
        userId: 'admin',
        title: 'Match Results Updated',
        message: 'Semi-final match results have been updated.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        type: AppNotification.NotificationType.result,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.tournament.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Participants'),
            Tab(text: 'Fixtures'),
            Tab(text: 'Scores'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildParticipantsTab(),
          _buildFixturesTab(),
          _buildScoresTab(),
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Image and Status
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: widget.tournament.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(widget.tournament.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: widget.tournament.imageUrl == null
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : null,
            ),
            child: Stack(
              children: [
                if (widget.tournament.imageUrl == null)
                  const Center(
                    child: Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                Positioned(top: 16, right: 16, child: _buildStatusBadge()),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tournament Info Cards
          _buildInfoCard('Basic Information', [
            _buildInfoRow('Tournament Name', widget.tournament.name),
            _buildInfoRow('Sport', widget.tournament.categories.join(', ')),
            _buildInfoRow('Location', widget.tournament.location),
            _buildInfoRow('Organizer', widget.tournament.organizer),
          ]),

          const SizedBox(height: 16),

          _buildInfoCard('Schedule & Fees', [
            _buildInfoRow(
              'Start Date',
              _formatDate(widget.tournament.startDate),
            ),
            _buildInfoRow('End Date', _formatDate(widget.tournament.endDate)),
            _buildInfoRow(
              'Entry Fee',
              '₹${widget.tournament.entryFee.toStringAsFixed(0)}',
            ),
            _buildInfoRow('Prize Info', widget.tournament.prizes ?? 'TBD'),
          ]),

          const SizedBox(height: 16),

          _buildInfoCard('Participation', [
            _buildInfoRow(
              'Max Participants',
              widget.tournament.maxParticipants.toString(),
            ),
            _buildInfoRow(
              'Current Participants',
              widget.tournament.currentParticipants.toString(),
            ),
            _buildInfoRow(
              'Available Spots',
              (widget.tournament.maxParticipants -
                      widget.tournament.currentParticipants)
                  .toString(),
            ),
          ]),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _editTournament,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Tournament'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _updateStatus,
                  icon: const Icon(Icons.update),
                  label: const Text('Update Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteTournament,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Tournament'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab() {
    final approvedParticipants = participants
        .where((p) => p.status == ParticipantStatus.approved)
        .toList();
    final pendingParticipants = participants
        .where((p) => p.status == ParticipantStatus.pending)
        .toList();

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search participants...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Approved', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Rejected', false),
                ],
              ),
            ],
          ),
        ),

        // Participants List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendingParticipants.isNotEmpty) ...[
                Text(
                  'Pending Approval (${pendingParticipants.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                const SizedBox(height: 12),
                ...pendingParticipants.map(
                  (participant) => _buildParticipantCard(participant),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                'Approved Participants (${approvedParticipants.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),
              const SizedBox(height: 12),
              ...approvedParticipants.map(
                (participant) => _buildParticipantCard(participant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Bracket Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tournament Bracket',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Single Elimination • ${matches.length} Matches',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMediumColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Bracket View
          _buildBracketView(),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _editFixture,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Fixtures'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateBracket,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Generate Bracket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoresTab() {
    final completedMatches = matches
        .where((m) => m.status == MatchStatus.completed)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Match Results (${completedMatches.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDarkColor,
          ),
        ),
        const SizedBox(height: 16),

        if (completedMatches.isEmpty)
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed matches yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          ...completedMatches.map((match) => _buildScoreCard(match)),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    return Column(
      children: [
        // Send Notification Form
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Tournament Announcement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sendNotification,
                  icon: const Icon(Icons.send),
                  label: const Text('Send to All Participants'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Notification History
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Notification History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDarkColor,
                ),
              ),
              const SizedBox(height: 16),
              ...notifications.map(
                (notification) => _buildNotificationCard(notification),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _buildStatusBadge() {
    String statusText;
    Color statusColor;

    switch (widget.tournament.status) {
      case TournamentStatus.upcoming:
        statusText = 'Upcoming';
        statusColor = AppTheme.warningColor;
        break;
      case TournamentStatus.ongoing:
        statusText = 'Ongoing';
        statusColor = AppTheme.infoColor;
        break;
      case TournamentStatus.completed:
        statusText = 'Completed';
        statusColor = AppTheme.successColor;
        break;
      case TournamentStatus.cancelled:
        statusText = 'Cancelled';
        statusColor = AppTheme.errorColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMediumColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: AppTheme.textMediumColor)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textDarkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Handle filter selection
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textMediumColor,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildParticipantCard(Participant participant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                backgroundImage: participant.profileImageUrl != null
                    ? NetworkImage(participant.profileImageUrl!)
                    : null,
                child: participant.profileImageUrl == null
                    ? Text(
                        participant.name.isNotEmpty
                            ? participant.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                    Text(
                      participant.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMediumColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: participant.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  participant.statusDisplayName,
                  style: TextStyle(
                    color: participant.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (participant.phone != null) ...[
            const SizedBox(height: 8),
            Text(
              'Phone: ${participant.phone}',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMediumColor,
              ),
            ),
          ],

          Text(
            'Registered: ${_formatDate(participant.registrationDate)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMediumColor,
            ),
          ),

          if (participant.status == ParticipantStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveParticipant(participant),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectParticipant(participant),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBracketView() {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.account_tree_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No bracket generated yet',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate bracket after participant approval',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: matches.map((match) => _buildMatchCard(match, true)).toList(),
    );
  }

  Widget _buildMatchCard(Match match, bool showScoreInput) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: match.status == MatchStatus.ongoing
              ? AppTheme.infoColor
              : Colors.grey.shade200,
          width: match.status == MatchStatus.ongoing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Match Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.roundDisplayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMediumColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: match.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  match.statusDisplayName,
                  style: TextStyle(
                    color: match.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Players and Score
          Row(
            children: [
              // Player 1
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage: match.player1ImageUrl != null
                          ? NetworkImage(match.player1ImageUrl!)
                          : null,
                      child: match.player1ImageUrl == null
                          ? Text(
                              match.player1Name?.isNotEmpty == true
                                  ? match.player1Name![0].toUpperCase()
                                  : 'P1',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.player1Name ?? 'TBD',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDarkColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (showScoreInput && match.status == MatchStatus.ongoing)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 40,
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8),
                              ),
                              controller: TextEditingController(
                                text: match.player1Score?.toString() ?? '',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('-'),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(8),
                              ),
                              controller: TextEditingController(
                                text: match.player2Score?.toString() ?? '',
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        match.formattedScore,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: match.status == MatchStatus.completed
                              ? AppTheme.textDarkColor
                              : AppTheme.textMediumColor,
                        ),
                      ),
                  ],
                ),
              ),

              // Player 2
              Expanded(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      backgroundImage: match.player2ImageUrl != null
                          ? NetworkImage(match.player2ImageUrl!)
                          : null,
                      child: match.player2ImageUrl == null
                          ? Text(
                              match.player2Name?.isNotEmpty == true
                                  ? match.player2Name![0].toUpperCase()
                                  : 'P2',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.player2Name ?? 'TBD',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDarkColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (showScoreInput &&
              (match.status == MatchStatus.ongoing ||
                  match.status == MatchStatus.scheduled)) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _updateScore(match),
                style: ElevatedButton.styleFrom(
                  backgroundColor: match.status == MatchStatus.ongoing
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  match.status == MatchStatus.ongoing
                      ? 'Update Score'
                      : 'Start Match',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScoreCard(Match match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.roundDisplayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMediumColor,
                ),
              ),
              if (match.completionTime != null)
                Text(
                  _formatDateTimeShort(match.completionTime!),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMediumColor,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Winner indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: match.winnerId == match.player1Id
                      ? AppTheme.successColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.player1Name ?? 'Player 1',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: match.winnerId == match.player1Id
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                    if (match.winnerId == match.player1Id)
                      const Text(
                        'Winner',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              Text(
                '${match.player1Score ?? 0}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: match.winnerId == match.player1Id
                      ? AppTheme.successColor
                      : AppTheme.textDarkColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: match.winnerId == match.player2Id
                      ? AppTheme.successColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.player2Name ?? 'Player 2',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: match.winnerId == match.player2Id
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                    if (match.winnerId == match.player2Id)
                      const Text(
                        'Winner',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              Text(
                '${match.player2Score ?? 0}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: match.winnerId == match.player2Id
                      ? AppTheme.successColor
                      : AppTheme.textDarkColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editScore(match),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification.Notification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade200
              : AppTheme.primaryColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: notification.isRead
                        ? FontWeight.w500
                        : FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            notification.message,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textMediumColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _formatDateTime(notification.timestamp),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMediumColor,
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods (UI only - no backend implementation)
  void _editTournament() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit Tournament clicked')));
  }

  void _updateStatus() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Update Status clicked')));
  }

  void _deleteTournament() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: const Text(
          'Are you sure you want to delete this tournament? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tournament deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _approveParticipant(Participant participant) {
    setState(() {
      final index = participants.indexWhere((p) => p.id == participant.id);
      if (index != -1) {
        participants[index] = participant.copyWith(
          status: ParticipantStatus.approved,
        );
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${participant.name} approved')));
  }

  void _rejectParticipant(Participant participant) {
    setState(() {
      final index = participants.indexWhere((p) => p.id == participant.id);
      if (index != -1) {
        participants[index] = participant.copyWith(
          status: ParticipantStatus.rejected,
        );
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${participant.name} rejected')));
  }

  void _editFixture() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit Fixtures clicked')));
  }

  void _generateBracket() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Generate Bracket clicked')));
  }

  void _updateScore(Match match) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Update Score clicked')));
  }

  void _editScore(Match match) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit Score clicked')));
  }

  void _sendNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent to all participants')),
    );
  }
}
