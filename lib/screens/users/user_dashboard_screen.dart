import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/tournament.dart';
import '../../models/booking.dart';
import '../../models/notification.dart' as model;
import '../../utils/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/tournament_card.dart';
import '../../widgets/booking_card.dart';
import '../../widgets/notification_card.dart';
import '../../widgets/profile_card.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  int _selectedIndex = 0;
  final User _user = User.sampleUser();
  final List<Tournament> _tournaments = Tournament.getSampleTournaments();
  final List<Booking> _bookings = Booking.getSampleBookings();
  final List<model.Notification> _notifications =
      model.Notification.getSampleNotifications()
          .where((notification) => notification.userId == '2')
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        actions: [
          Badge(
            isLabelVisible: _getUnreadNotificationsCount() > 0,
            label: Text(_getUnreadNotificationsCount().toString()),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Show notifications
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        user: _user,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _buildBody(),
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Tournaments';
      case 2:
        return 'My Bookings';
      case 3:
        return 'Notifications';
      case 7:
        return 'Profile';
      case 8:
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  int _getUnreadNotificationsCount() {
    return _notifications.where((notification) => !notification.isRead).length;
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
      case 7:
        return _buildProfileContent();
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
    // Filter tournaments by status
    final upcomingTournaments = _tournaments
        .where((t) => t.status == TournamentStatus.upcoming)
        .toList();

    final myBookings = _bookings;

    // Get unread notifications
    final unreadNotifications = _notifications
        .where((notification) => !notification.isRead)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate data refresh
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          // Just rebuild for demo
        });
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message with user name
            Text(
              'Welcome, ${_user.name.split(' ')[0]}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDarkColor,
              ),
            ),
            const Text(
              'Find and book your next tournament',
              style: TextStyle(fontSize: 16, color: AppTheme.textMediumColor),
            ),

            const SizedBox(height: 24),

            // Quick stats cards
            _buildQuickStatsRow(),

            const SizedBox(height: 24),

            // Unread notifications
            if (unreadNotifications.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDarkColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unreadNotifications.length.clamp(0, 2),
                itemBuilder: (context, index) {
                  return NotificationCard(
                    notification: unreadNotifications[index],
                    onTap: () {
                      // Mark as read and handle action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Viewing notification: ${unreadNotifications[index].title}',
                          ),
                        ),
                      );
                    },
                    onMarkAsRead: () {
                      // Mark notification as read
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification marked as read'),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),
            ],

            // My bookings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (myBookings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No bookings yet',
                    style: TextStyle(color: AppTheme.textMediumColor),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myBookings.length.clamp(0, 2),
                itemBuilder: (context, index) {
                  return BookingCard(
                    booking: myBookings[index],
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'View booking details for: ${myBookings[index].tournamentName}',
                          ),
                        ),
                      );
                    },
                    onCancelBooking:
                        myBookings[index].status == BookingStatus.pending ||
                            myBookings[index].status == BookingStatus.confirmed
                        ? () {
                            // Handle cancellation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Booking cancellation coming soon',
                                ),
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),

            const SizedBox(height: 24),

            // Upcoming tournaments section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Tournaments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

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
                itemCount: upcomingTournaments.length.clamp(0, 2),
                itemBuilder: (context, index) {
                  return TournamentCard(
                    tournament: upcomingTournaments[index],
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
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        _buildQuickStatCard(
          title: 'My Bookings',
          value: _bookings.length.toString(),
          icon: Icons.calendar_today,
          color: AppTheme.primaryColor,
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
        ),
        const SizedBox(width: 16),
        _buildQuickStatCard(
          title: 'Tournaments',
          value: _tournaments
              .where((t) => t.status == TournamentStatus.upcoming)
              .length
              .toString(),
          icon: Icons.emoji_events,
          color: AppTheme.secondaryColor,
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.textMediumColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMediumColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentsContent() {
    return _tournaments.isEmpty
        ? const Center(
            child: Text(
              'No tournaments available',
              style: TextStyle(fontSize: 18, color: AppTheme.textMediumColor),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tournaments.length,
            itemBuilder: (context, index) {
              return TournamentCard(
                tournament: _tournaments[index],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'View details of: ${_tournaments[index].name}',
                      ),
                    ),
                  );
                },
              );
            },
          );
  }

  Widget _buildBookingsContent() {
    return _bookings.isEmpty
        ? const Center(
            child: Text(
              'No bookings available',
              style: TextStyle(fontSize: 18, color: AppTheme.textMediumColor),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(
                booking: _bookings[index],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'View booking details for: ${_bookings[index].tournamentName}',
                      ),
                    ),
                  );
                },
                onCancelBooking:
                    _bookings[index].status == BookingStatus.pending ||
                        _bookings[index].status == BookingStatus.confirmed
                    ? () {
                        // Handle cancellation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Booking cancellation coming soon'),
                          ),
                        );
                      }
                    : null,
              );
            },
          );
  }

  Widget _buildNotificationsContent() {
    return _notifications.isEmpty
        ? const Center(
            child: Text(
              'No notifications',
              style: TextStyle(fontSize: 18, color: AppTheme.textMediumColor),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              return NotificationCard(
                notification: _notifications[index],
                onTap: () {
                  // Handle notification tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Viewing notification: ${_notifications[index].title}',
                      ),
                    ),
                  );
                },
                onMarkAsRead: !_notifications[index].isRead
                    ? () {
                        // Mark notification as read
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notification marked as read'),
                          ),
                        );
                      }
                    : null,
              );
            },
          );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile card
          ProfileCard(
            user: _user,
            onEdit: () {
              // Open profile edit
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile functionality coming soon'),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Account actions
          const Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 16),

          // Edit Profile button
          _buildActionButton(
            icon: Icons.edit,
            title: 'Edit Profile',
            description: 'Update your personal information',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit profile functionality coming soon'),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Change Password button
          _buildActionButton(
            icon: Icons.lock,
            title: 'Change Password',
            description: 'Update your password for security',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Change password functionality coming soon'),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Payment Methods button
          _buildActionButton(
            icon: Icons.payment,
            title: 'Payment Methods',
            description: 'Manage your payment options',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment methods functionality coming soon'),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Preferences button
          _buildActionButton(
            icon: Icons.settings,
            title: 'Preferences',
            description: 'Customize app settings and notifications',
            onTap: () {
              setState(() {
                _selectedIndex = 8; // Settings
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.secondaryColor, size: 24),
              ),

              const SizedBox(width: 16),

              // Text content
              Expanded(
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
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMediumColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              const Icon(Icons.chevron_right, color: AppTheme.textMediumColor),
            ],
          ),
        ),
      ),
    );
  }
}
