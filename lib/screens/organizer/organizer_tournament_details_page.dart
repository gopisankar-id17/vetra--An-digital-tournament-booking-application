import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/participant.dart';
import '../../models/match.dart';
import '../../models/notification.dart' as AppNotification;
import '../../utils/app_theme.dart';
import '../../services/organizer_service.dart';
import '../../services/session_service.dart';
import '../../services/participant_service.dart';
import '../../services/booking_service.dart';

// Extension to capitalize first letter
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class OrganizerTournamentDetailsPage extends StatefulWidget {
  final Tournament tournament;
  final Function(Tournament)? onTournamentUpdated;

  const OrganizerTournamentDetailsPage({
    Key? key,
    required this.tournament,
    this.onTournamentUpdated,
  }) : super(key: key);

  @override
  State<OrganizerTournamentDetailsPage> createState() =>
      _OrganizerTournamentDetailsPageState();
}

class _OrganizerTournamentDetailsPageState
    extends State<OrganizerTournamentDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Tournament _tournament;
  final ParticipantService _participantService = ParticipantService();
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;

  // Mock data - replace with actual data from your services
  List<Participant> participants = [];
  List<Match> matches = [];
  List<AppNotification.Notification> notifications = [];
  List<Map<String, dynamic>> teamBookings = [];

  @override
  void initState() {
    super.initState();
    _tournament = widget.tournament;
    _tabController = TabController(length: 5, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Date formatting functions
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

  void _loadMockData() async {
    setState(() => _isLoading = true);

    try {
      // Load real participants data from database
      participants = await _participantService.getParticipants(_tournament.id);

      // Load team bookings data
      teamBookings = await _bookingService.getTournamentTeams(_tournament.id);
      print('Loaded ${teamBookings.length} team bookings');
    } catch (e) {
      // Fallback to empty list if error
      participants = [];
      teamBookings = [];
      print('Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }

    // Mock matches data - you can replace this with real match service later
    matches = [
      Match(
        id: '1',
        tournamentId: _tournament.id,
        player1Id: '1',
        player1Name: 'John Doe',
        player2Id: '2',
        player2Name: 'Jane Smith',
        scheduledTime: DateTime.now().add(const Duration(days: 1)),
        status: MatchStatus.scheduled,
        round: 1,
        matchNumber: 1,
      ),
      Match(
        id: '2',
        tournamentId: _tournament.id,
        player1Id: '3',
        player1Name: 'Mike Johnson',
        player2Id: '1',
        player2Name: 'John Doe',
        scheduledTime: DateTime.now().add(const Duration(days: 2)),
        status: MatchStatus.scheduled,
        round: 1,
        matchNumber: 2,
      ),
    ];

    // Mock notifications data - you can replace this with real notification service later
    notifications = [
      AppNotification.Notification(
        id: '1',
        userId: 'organizer1',
        title: 'Registration Deadline Reminder',
        message: 'Registration for ${_tournament.name} closes in 2 days',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: AppNotification.NotificationType.reminder,
        isRead: false,
      ),
      AppNotification.Notification(
        id: '2',
        userId: 'organizer1',
        title: 'New Participant Registered',
        message: 'John Doe has registered for the tournament',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: AppNotification.NotificationType.booking,
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _tournament.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDarkColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: AppTheme.primaryColor.withOpacity(0.1),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text('Edit Tournament'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Registration'),
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

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'edit':
        _showEditTournamentDialog();
        break;
      case 'duplicate':
        _duplicateTournament();
        break;
      case 'delete':
        _deleteTournament();
        break;
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournament Info Card
          _buildInfoCard(),
          const SizedBox(height: 16),

          // Statistics Cards Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Participants',
                  '${_tournament.currentParticipants}',
                  '${_tournament.maxParticipants}',
                  Icons.people,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Matches',
                  '${matches.length}',
                  'Total',
                  Icons.sports_esports,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Entry Fee',
                  '₹${_tournament.entryFee.toStringAsFixed(0)}',
                  'Per Person',
                  Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Prize Pool',
                  '₹${_tournament.prizePool.toStringAsFixed(0)}',
                  'Total',
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 16),

          // Recent Activity
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tournament.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDarkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _tournament.categories.join(', '),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _tournament.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.location_on, 'Location', _tournament.location),
          _buildInfoRow(
            Icons.calendar_today,
            'Start Date',
            _formatDate(_tournament.startDate),
          ),
          _buildInfoRow(
            Icons.event,
            'End Date',
            _formatDate(_tournament.endDate),
          ),
          if (_tournament.registrationDeadline != null)
            _buildInfoRow(
              Icons.schedule,
              'Registration Deadline',
              _formatDate(_tournament.registrationDeadline!),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (_tournament.status) {
      case TournamentStatus.upcoming:
        statusColor = Colors.orange;
        statusText = 'Upcoming';
        break;
      case TournamentStatus.ongoing:
        statusColor = Colors.green;
        statusText = 'Ongoing';
        break;
      case TournamentStatus.completed:
        statusColor = Colors.blue;
        statusText = 'Completed';
        break;
      case TournamentStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 18),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDarkColor,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Generate Fixtures',
                  Icons.sports_soccer,
                  AppTheme.primaryColor,
                  () => _generateFixtures(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Export Data',
                  Icons.download,
                  Colors.purple,
                  () => _exportData(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),
          ...notifications
              .take(3)
              .map((notification) => _buildActivityItem(notification)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(AppNotification.Notification notification) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case AppNotification.NotificationType.booking:
        icon = Icons.person_add;
        iconColor = Colors.green;
        break;
      case AppNotification.NotificationType.reminder:
        icon = Icons.schedule;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            _formatDateTimeShort(notification.timestamp),
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Teams Management (${teamBookings.length}/${_tournament.maxParticipants})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
                onPressed: _loadMockData,
                tooltip: 'Refresh Teams List',
              ),
            ],
          ),
        ),
        Expanded(child: _buildTeamsList()),
      ],
    );
  }

  Widget _buildTeamsList() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : teamBookings.isEmpty
        ? const Center(child: Text('No teams registered yet'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: teamBookings.length,
            itemBuilder: (context, index) {
              final booking = teamBookings[index];
              return _buildTeamBookingCard(booking);
            },
          );
  }

  Widget _buildTeamBookingCard(Map<String, dynamic> booking) {
    final teamName = booking['teamName'] ?? 'No Team Name';
    final captainName = booking['captainName'] ?? 'Unknown';
    final email = booking['email'] ?? '';
    final phoneNumber =
        booking['phoneNumber'] ?? ''; // We'll keep this for future use
    final playerCount = booking['playerCount']?.toString() ?? '1';
    final status = booking['status'] ?? 'pending';
    final paymentStatus = booking['paymentStatus'] ?? 'pending';

    // Define colors based on status
    Color statusColor = Colors.orange;
    if (status == 'approved')
      statusColor = Colors.green;
    else if (status == 'rejected')
      statusColor = Colors.red;

    Color paymentStatusColor = Colors.orange;
    if (paymentStatus == 'paid')
      paymentStatusColor = Colors.green;
    else if (paymentStatus == 'refunded')
      paymentStatusColor = Colors.grey;
    else if (paymentStatus == 'failed')
      paymentStatusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Captain: $captainName',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phone: $phoneNumber',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusChip('Status', status, statusColor),
                const SizedBox(width: 8),
                _buildStatusChip('Payment', paymentStatus, paymentStatusColor),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.people, '$playerCount players'),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          Text(
            status.capitalize(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(Participant participant) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (participant.status) {
      case ParticipantStatus.approved:
        statusColor = Colors.green;
        statusText = 'Approved';
        statusIcon = Icons.check_circle;
        break;
      case ParticipantStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending';
        statusIcon = Icons.schedule;
        break;
      case ParticipantStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Rejected';
        statusIcon = Icons.cancel;
        break;
      case ParticipantStatus.withdrawn:
        statusColor = Colors.grey;
        statusText = 'Withdrawn';
        statusIcon = Icons.exit_to_app;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              participant.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  participant.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  'Registered: ${_formatDate(participant.registrationDate)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleParticipantAction(value, participant),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'approve', child: Text('Approve')),
              const PopupMenuItem(value: 'reject', child: Text('Reject')),
              const PopupMenuItem(value: 'remove', child: Text('Remove')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFixturesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Fixtures & Matches',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _generateFixtures,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: matches.isEmpty
              ? _buildEmptyFixtures()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return _buildMatchCard(match);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyFixtures() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_esports, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No fixtures generated yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate fixtures to create match schedule',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateFixtures,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Fixtures'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (match.status) {
      case MatchStatus.scheduled:
        statusColor = Colors.blue;
        statusText = 'Scheduled';
        statusIcon = Icons.schedule;
        break;
      case MatchStatus.ongoing:
        statusColor = Colors.orange;
        statusText = 'Live';
        statusIcon = Icons.play_circle;
        break;
      case MatchStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case MatchStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
      case MatchStatus.postponed:
        statusColor = Colors.grey;
        statusText = 'Postponed';
        statusIcon = Icons.pause_circle;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Round ${match.round}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        match.player1Name?[0].toUpperCase() ?? 'P1',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.player1Name ?? 'Participant 1',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange.withOpacity(0.1),
                      child: Text(
                        match.player2Name?[0].toUpperCase() ?? 'P2',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      match.player2Name ?? 'Participant 2',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.grey[600], size: 16),
              const SizedBox(width: 8),
              Text(
                'Scheduled: ${_formatDateTime(match.scheduledTime!)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _editMatch(match),
                child: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoresTab() {
    // Mock team scores data - in a real app this would come from your database
    final List<Map<String, dynamic>> teamScores = [
      {
        'teamName': teamBookings.isNotEmpty
            ? teamBookings[0]['teamName']
            : 'Seniors',
        'matchesPlayed': 3,
        'matchesWon': 2,
        'matchesLost': 1,
        'points': 6,
        'status': 'leading',
      },
      {
        'teamName': teamBookings.length > 1
            ? teamBookings[1]['teamName']
            : 'Juniors',
        'matchesPlayed': 3,
        'matchesWon': 1,
        'matchesLost': 2,
        'points': 3,
        'status': 'trailing',
      },
      {
        'teamName': 'Golden Stars',
        'matchesPlayed': 2,
        'matchesWon': 1,
        'matchesLost': 1,
        'points': 3,
        'status': 'middle',
      },
      {
        'teamName': 'Blue Thunder',
        'matchesPlayed': 2,
        'matchesWon': 0,
        'matchesLost': 2,
        'points': 0,
        'status': 'bottom',
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Team Scores & Rankings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addScore,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Update Scores'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(color: Colors.grey.shade100),
          child: const Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  'Rank',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Team',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'Played',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  'Won',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  'Lost',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  'Points',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: teamScores.isEmpty
              ? _buildEmptyScores()
              : ListView.builder(
                  padding: const EdgeInsets.all(0),
                  itemCount: teamScores.length,
                  itemBuilder: (context, index) {
                    final score = teamScores[index];
                    return _buildTeamScoreRow(score, index + 1);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyScores() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.scoreboard, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No scores recorded yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete matches to record scores',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreRow(Map<String, dynamic> score, int rank) {
    final teamName = score['teamName'] ?? 'Unknown Team';
    final matchesPlayed = score['matchesPlayed'] ?? 0;
    final matchesWon = score['matchesWon'] ?? 0;
    final matchesLost = score['matchesLost'] ?? 0;
    final points = score['points'] ?? 0;

    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade300;
    } else {
      rankColor = Colors.grey.shade700;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: rank <= 3 ? 2 : 1),
              ),
              child: Center(
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    teamName.isNotEmpty ? teamName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  teamName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(matchesPlayed.toString(), textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 40,
            child: Text(
              matchesWon.toString(),
              style: const TextStyle(color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              matchesLost.toString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              points.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Team vs team match card for future implementation
  Widget _buildTeamMatchCard(
    Map<String, dynamic> team1,
    Map<String, dynamic> team2,
    int score1,
    int score2,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Match: ${team1['teamName']} vs ${team2['teamName']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      team1['teamName'] ?? 'Team 1',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        score1.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      team2['teamName'] ?? 'Team 2',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        score2.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: score2 > score1 ? Colors.green : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Tournament Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _sendNotification,
                icon: const Icon(Icons.send, size: 18),
                label: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(AppNotification.Notification notification) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case AppNotification.NotificationType.booking:
        icon = Icons.person_add;
        iconColor = Colors.green;
        break;
      case AppNotification.NotificationType.reminder:
        icon = Icons.schedule;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: notification.isRead
            ? null
            : Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(notification.timestamp),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action methods
  void _generateFixtures() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fixtures generated successfully!')),
    );
  }

  void _sendNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Send notification functionality will be implemented'),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export data functionality will be implemented'),
      ),
    );
  }

  void _addScore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add score functionality will be implemented'),
      ),
    );
  }

  void _editMatch(Match match) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit match ${match.id} functionality will be implemented',
        ),
      ),
    );
  }

  void _handleParticipantAction(String action, Participant participant) {
    switch (action) {
      case 'approve':
        // Create new participant with approved status
        final updatedParticipant = Participant(
          id: participant.id,
          userId: participant.userId,
          name: participant.name,
          email: participant.email,
          phone: participant.phone,
          profileImageUrl: participant.profileImageUrl,
          registrationDate: participant.registrationDate,
          status: ParticipantStatus.approved,
          rejectionReason: participant.rejectionReason,
          additionalInfo: participant.additionalInfo,
        );
        setState(() {
          final index = participants.indexWhere((p) => p.id == participant.id);
          if (index != -1) {
            participants[index] = updatedParticipant;
          }
        });
        break;
      case 'reject':
        // Create new participant with rejected status
        final rejectedParticipant = Participant(
          id: participant.id,
          userId: participant.userId,
          name: participant.name,
          email: participant.email,
          phone: participant.phone,
          profileImageUrl: participant.profileImageUrl,
          registrationDate: participant.registrationDate,
          status: ParticipantStatus.rejected,
          rejectionReason: 'Rejected by organizer',
          additionalInfo: participant.additionalInfo,
        );
        setState(() {
          final index = participants.indexWhere((p) => p.id == participant.id);
          if (index != -1) {
            participants[index] = rejectedParticipant;
          }
        });
        break;
      case 'remove':
        setState(() {
          participants.remove(participant);
        });
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Participant ${action}d successfully')),
    );
  }

  void _showEditTournamentDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit tournament functionality will be implemented'),
      ),
    );
  }

  void _duplicateTournament() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tournament duplicated successfully!')),
    );
  }

  void _deleteTournament() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tournament'),
        content: Text(
          'Are you sure you want to delete "${_tournament.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);

      try {
        final organizerData = await SessionService.getOrganizerSession();
        if (organizerData['id'] != null) {
          final deleted = await OrganizerService.deleteTournament(
            _tournament.id,
          );
          if (deleted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tournament deleted successfully'),
                ),
              );
              Navigator.pop(context);
            }
          } else {
            throw Exception('Failed to delete tournament');
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting tournament: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
