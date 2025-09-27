import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/tournament.dart';
import '../../models/booking.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/tournament_card.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/professional_fab.dart';
import 'add_tournament_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final User _adminUser = User.sampleAdmin();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        user: _adminUser,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex > 4
            ? 0
            : _selectedIndex, // Ensure index is within bounds
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Tournaments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? ProfessionalFloatingActionButton(
              onPressed: () {
                _showCreateTournamentDialog(context);
              },
              tooltip: 'Create New Tournament',
              icon: Icons.sports_esports,
              label: 'New Tournament',
            )
          : null,
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Manage Tournaments';
      case 2:
        return 'Manage Bookings';
      case 3:
        return 'Notifications';
      case 4:
        return 'Manage Users';
      case 5:
        return 'Analytics Dashboard';
      case 6:
        return 'Reports';
      case 7:
        return 'Profile';
      case 8:
        return 'Settings';
      default:
        return 'Admin Dashboard';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildTournamentsContent();
      case 2:
        return _buildBookingsContent();
      case 3:
        return _buildNotificationsContent();
      case 4:
        // Redirect to the Users screen, but use push instead of pushReplacement
        // to allow navigation back to the dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/admin-users');
          // Reset the selected index to dashboard to avoid re-navigating
          // when returning from the users screen
          setState(() {
            _selectedIndex = 0;
          });
        });
        return const Center(child: CircularProgressIndicator());
      case 5:
        // Redirect to the Analytics screen, but use push instead of pushReplacement
        // to allow navigation back to the dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamed(context, '/admin-analytics');
          // Reset the selected index to dashboard to avoid re-navigating
          // when returning from the analytics screen
          setState(() {
            _selectedIndex = 0;
          });
        });
        return const Center(child: CircularProgressIndicator());
      case 6:
        return _buildReportsContent();
      case 7:
        return _buildProfileContent();
      case 8:
        return _buildSettingsContent();
      default:
        return Center(
          child: Text(
            '${_getScreenTitle()} - Coming Soon',
            style: const TextStyle(fontSize: 18),
          ),
        );
    }
  }

  Widget _buildDashboardContent() {
    final tournaments = Tournament.getSampleTournaments();
    final upcomingTournaments = tournaments
        .where((t) => t.status == TournamentStatus.upcoming)
        .toList();
    final ongoingTournaments = tournaments
        .where((t) => t.status == TournamentStatus.ongoing)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          const Text(
            'Welcome back, Admin!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const Text(
            'Here\'s what\'s happening with your tournaments',
            style: TextStyle(fontSize: 16, color: AppTheme.textMediumColor),
          ),
          const SizedBox(height: 24),

          // Stats cards
          _buildStatsGrid(),
          const SizedBox(height: 24),

          // Recent tournaments
          const Text(
            'Upcoming Tournaments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 12),

          if (upcomingTournaments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No upcoming tournaments',
                  style: TextStyle(color: AppTheme.textMediumColor),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingTournaments.length.clamp(0, 3),
              itemBuilder: (context, index) {
                return TournamentCard(
                  tournament: upcomingTournaments[index],
                  showActions: false,
                  onTap: () {
                    // Show tournament details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'View details of ${upcomingTournaments[index].name}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),

          const SizedBox(height: 24),

          // Ongoing tournaments
          const Text(
            'Ongoing Tournaments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 12),

          if (ongoingTournaments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No ongoing tournaments',
                  style: TextStyle(color: AppTheme.textMediumColor),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ongoingTournaments.length,
              itemBuilder: (context, index) {
                return TournamentCard(
                  tournament: ongoingTournaments[index],
                  showActions: false,
                  onTap: () {
                    // Show tournament details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'View details of ${ongoingTournaments[index].name}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1, // Adjust aspect ratio to prevent overflow
      children: [
        _buildStatCard(
          title: 'Tournaments',
          value: '4',
          icon: Icons.emoji_events,
          color: AppTheme.primaryColor,
        ),
        _buildStatCard(
          title: 'Bookings',
          value: '78',
          icon: Icons.calendar_today,
          color: AppTheme.secondaryColor,
        ),
        _buildStatCard(
          title: 'Revenue',
          value: '₹1,50,000',
          icon: Icons.attach_money,
          color: AppTheme.successColor,
        ),
        _buildStatCard(
          title: 'Users',
          value: '125',
          icon: Icons.people,
          color: AppTheme.infoColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // Changed to center
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
            Container(
              padding: const EdgeInsets.all(6), // Reduced padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20), // Reduced icon size
            ),
            const SizedBox(height: 8), // Reduced spacing
            Flexible(
              // Made text flexible to prevent overflow
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24, // Reduced font size
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              // Made text flexible to prevent overflow
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12, // Reduced font size
                  color: AppTheme.textMediumColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentsContent() {
    final tournaments = Tournament.getSampleTournaments();

    return tournaments.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No tournaments yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first tournament to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textMediumColor,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTournamentDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Create Tournament',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              // Header with stats
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      'Total',
                      tournaments.length.toString(),
                      Icons.emoji_events,
                      AppTheme.primaryColor,
                    ),
                    _buildStatColumn(
                      'Upcoming',
                      tournaments
                          .where((t) => t.status == TournamentStatus.upcoming)
                          .length
                          .toString(),
                      Icons.schedule,
                      Colors.blue,
                    ),
                    _buildStatColumn(
                      'Ongoing',
                      tournaments
                          .where((t) => t.status == TournamentStatus.ongoing)
                          .length
                          .toString(),
                      Icons.play_arrow,
                      Colors.green,
                    ),
                    _buildStatColumn(
                      'Completed',
                      tournaments
                          .where((t) => t.status == TournamentStatus.completed)
                          .length
                          .toString(),
                      Icons.check_circle,
                      Colors.grey,
                    ),
                  ],
                ),
              ),
              // Tournament list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tournaments.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: TournamentCard(
                        tournament: tournaments[index],
                        onTap: () {
                          _showTournamentManageDialog(
                            context,
                            tournaments[index],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDarkColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textMediumColor),
        ),
      ],
    );
  }

  void _showTournamentManageDialog(
    BuildContext context,
    Tournament tournament,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Manage: ${tournament.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
              title: const Text('Edit Tournament'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit tournament feature coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('View Participants'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Participants view coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.green),
              title: const Text('View Analytics'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics view coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Tournament'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, tournament);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tournament "${tournament.name}" deleted successfully',
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsContent() {
    final bookings = Booking.getSampleBookings();

    return bookings.isEmpty
        ? const Center(
            child: Text(
              'No bookings available',
              style: TextStyle(fontSize: 18, color: AppTheme.textMediumColor),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(
                booking: bookings[index],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'View booking details for: ${bookings[index].tournamentName}',
                      ),
                    ),
                  );
                },
              );
            },
          );
  }

  Widget _buildNotificationsContent() {
    final notifications = [
      {
        'title': 'New Tournament Registration',
        'message': 'John Doe registered for Basketball Championship 2025',
        'time': '2 minutes ago',
        'type': 'registration',
      },
      {
        'title': 'Tournament Full',
        'message': 'Chess Tournament 2025 has reached maximum capacity',
        'time': '1 hour ago',
        'type': 'alert',
      },
      {
        'title': 'Payment Received',
        'message': 'Payment of ₹500 received from Sarah Smith',
        'time': '3 hours ago',
        'type': 'payment',
      },
      {
        'title': 'Tournament Starting Soon',
        'message': 'Gaming Tournament starts in 30 minutes',
        'time': '5 hours ago',
        'type': 'reminder',
      },
    ];

    return notifications.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getNotificationColor(
                      notification['type']!,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification['type']!),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    notification['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        notification['message']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['time']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // Show notification options
                    },
                  ),
                  onTap: () {
                    // Handle notification tap
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notification: ${notification['title']}'),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'registration':
        return Colors.blue;
      case 'alert':
        return Colors.orange;
      case 'payment':
        return Colors.green;
      case 'reminder':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'registration':
        return Icons.person_add;
      case 'alert':
        return Icons.warning;
      case 'payment':
        return Icons.payment;
      case 'reminder':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(_adminUser.photoUrl!),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Name and role
                  Text(
                    _adminUser.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Administrator',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Divider(height: 32),

                  // Contact information
                  _buildProfileInfoRow(Icons.email, 'Email', _adminUser.email),
                  _buildProfileInfoRow(
                    Icons.phone,
                    'Phone',
                    _adminUser.phone ?? 'Not set',
                  ),
                  _buildProfileInfoRow(
                    Icons.location_on,
                    'Address',
                    _adminUser.address ?? 'Not set',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Edit Profile button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile functionality coming soon'),
                  ),
                );
              },
              child: const Text('Edit Profile'),
            ),
          ),

          const SizedBox(height: 16),

          // Change Password button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Change password functionality coming soon'),
                  ),
                );
              },
              child: const Text('Change Password'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateTournamentDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTournamentPage(
          onTournamentCreated: (tournament) {
            // Handle tournament creation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tournament "${tournament.name}" created successfully!',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 4),
              ),
            );

            // Refresh the tournaments list
            setState(() {
              // Add logic to refresh tournaments if needed
            });
          },
        ),
      ),
    );
  }

  // Implementation for Reports screen
  Widget _buildReportsContent() {
    final List<Map<String, dynamic>> reports = [
      {
        'title': 'Monthly Revenue Report',
        'description': 'Financial summary for the current month',
        'date': 'August 2023',
        'icon': Icons.attach_money,
        'type': 'Financial',
      },
      {
        'title': 'User Activity Analysis',
        'description': 'User engagement and activity patterns',
        'date': 'Last 30 days',
        'icon': Icons.analytics,
        'type': 'Analytics',
      },
      {
        'title': 'Tournament Performance',
        'description': 'Completion rates and participant satisfaction',
        'date': 'Q3 2023',
        'icon': Icons.emoji_events,
        'type': 'Performance',
      },
      {
        'title': 'Booking Conversion Report',
        'description': 'View to booking conversion analysis',
        'date': 'July 2023',
        'icon': Icons.assignment_turned_in,
        'type': 'Conversion',
      },
    ];

    // Create a completely new implementation with correct structure
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14.0,
        vertical: 16.0,
      ), // Adjusted padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and actions - fix overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Reports & Analytics',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Generate custom report feature coming soon!',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_chart, size: 18),
                label: const Text('Generate', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter options - Use SingleChildScrollView to prevent horizontal overflow
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Reports', true),
                _buildFilterChip('Financial', false),
                _buildFilterChip('User Analytics', false),
                _buildFilterChip('Tournaments', false),
                _buildFilterChip('Bookings', false),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reports grid - Use Expanded with regular ListView to fix overflow
          Expanded(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true, // Make grid take only needed space
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12, // Reduced spacing
                mainAxisSpacing: 12, // Reduced spacing
                // Use a dynamic aspect ratio based on screen size, minimum 2.0
                childAspectRatio: MediaQuery.of(context).size.width < 360
                    ? 2.3
                    : 2.0,
              ),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Viewing ${report['title']} - Coming soon!',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 8.0,
                      ), // Further reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Use minimum space
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Distribute space evenly
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(
                                  6,
                                ), // Reduced padding
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    6,
                                  ), // Smaller radius
                                ),
                                child: Icon(
                                  report['icon'],
                                  color: AppTheme.primaryColor,
                                  size: 18, // Smaller icon
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6, // Reduced padding
                                  vertical: 3, // Reduced padding
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ), // Smaller radius
                                  border: Border.all(
                                    color: AppTheme.secondaryColor.withOpacity(
                                      0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  report['type'],
                                  style: TextStyle(
                                    fontSize: 10, // Smaller text
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6), // Further reduced spacing
                          Text(
                            report['title'],
                            style: const TextStyle(
                              fontSize: 14, // Further reduced font size
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4), // Further reduced spacing
                          Text(
                            report['description'],
                            style: const TextStyle(
                              fontSize: 11, // Further reduced font size
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 2), // Minimal spacing
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  report['date'],
                                  style: const TextStyle(
                                    fontSize: 10, // Further reduced font size
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4), // Reduced spacing
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12, // Smaller icon
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0), // Reduced padding
      child: FilterChip(
        materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap, // Smaller tap target
        visualDensity: VisualDensity.compact, // More compact layout
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ), // Smaller text
        selected: isSelected,
        onSelected: (bool selected) {
          // Filter logic would go here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Filter by $label'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Implementation for Settings screen
  Widget _buildSettingsContent() {
    // Settings categories
    final List<Map<String, dynamic>> settingsCategories = [
      {
        'title': 'General Settings',
        'icon': Icons.settings,
        'settings': [
          {
            'title': 'App Preferences',
            'subtitle': 'Customize app behavior and appearance',
            'icon': Icons.tune,
          },
          {
            'title': 'Notifications',
            'subtitle': 'Configure notification preferences',
            'icon': Icons.notifications_active,
          },
          {
            'title': 'Language',
            'subtitle': 'Change app language',
            'icon': Icons.language,
            'value': 'English',
          },
        ],
      },
      {
        'title': 'Tournament Settings',
        'icon': Icons.emoji_events,
        'settings': [
          {
            'title': 'Default Tournament Settings',
            'subtitle': 'Configure default values for new tournaments',
            'icon': Icons.sports_esports,
          },
          {
            'title': 'Registration Rules',
            'subtitle': 'Set default registration and cancellation policies',
            'icon': Icons.rule,
          },
        ],
      },
      {
        'title': 'Payment Settings',
        'icon': Icons.payment,
        'settings': [
          {
            'title': 'Payment Methods',
            'subtitle': 'Manage accepted payment methods',
            'icon': Icons.credit_card,
          },
          {
            'title': 'Payout Schedule',
            'subtitle': 'Configure default payout timeline',
            'icon': Icons.schedule,
          },
        ],
      },
      {
        'title': 'System',
        'icon': Icons.computer,
        'settings': [
          {
            'title': 'Data Management',
            'subtitle': 'Configure backup and data retention policies',
            'icon': Icons.storage,
          },
          {
            'title': 'Admin Accounts',
            'subtitle': 'Manage admin users and permissions',
            'icon': Icons.admin_panel_settings,
          },
          {
            'title': 'Security Settings',
            'subtitle': 'Configure security options and password policies',
            'icon': Icons.security,
          },
        ],
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure your application settings',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search settings...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 24),

            // Settings categories
            ...settingsCategories.map(
              (category) => _buildSettingsCategory(category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCategory(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Icon(category['icon'], color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                category['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category['settings'].length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final setting = category['settings'][index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(setting['icon'], color: AppTheme.primaryColor),
                ),
                title: Text(setting['title']),
                subtitle: Text(setting['subtitle']),
                trailing: setting.containsKey('value')
                    ? Text(
                        setting['value'],
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${setting['title']} - Coming soon!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
