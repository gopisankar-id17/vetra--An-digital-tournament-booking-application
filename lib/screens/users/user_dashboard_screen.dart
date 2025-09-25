import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/tournament.dart';
import '../../models/booking.dart';
import '../../models/notification.dart' as model;
import '../../utils/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/tournament_card.dart';
import '../../widgets/tournament_carousel.dart';
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

            // Upcoming tournaments carousel - MOVED TO TOP
            TournamentCarousel(
              tournaments: upcomingTournaments,
              title: 'Upcoming Tournaments',
              onViewAll: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              onTournamentTap: (tournament) {
                _showTournamentDetails(context, tournament);
              },
            ),

            const SizedBox(height: 24),

            // Ongoing tournaments carousel
            TournamentCarousel(
              tournaments: _tournaments
                  .where((t) => t.status == TournamentStatus.ongoing)
                  .toList(),
              title: 'Ongoing Tournaments',
              onViewAll: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              onTournamentTap: (tournament) {
                _showTournamentDetails(context, tournament);
              },
            ),

            const SizedBox(height: 24),

            // Completed tournaments carousel
            TournamentCarousel(
              tournaments: _tournaments
                  .where((t) => t.status == TournamentStatus.completed)
                  .toList(),
              title: 'Completed Tournaments',
              onViewAll: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              onTournamentTap: (tournament) {
                _showTournamentDetails(context, tournament);
              },
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
          ],
        ),
      ),
    );
  }

  void _showTournamentDetails(BuildContext context, Tournament tournament) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tournament Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: tournament.imageUrl != null
                              ? Image.network(
                                  tournament.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.2),
                                        child: const Center(
                                          child: Icon(
                                            Icons.emoji_events,
                                            size: 60,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ),
                                )
                              : Container(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  child: const Center(
                                    child: Icon(
                                      Icons.emoji_events,
                                      size: 60,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tournament Name
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tournament.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: tournament.statusColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tournament.status.name.toUpperCase(),
                          style: TextStyle(
                            color: tournament.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Details
                      _buildDetailRow(
                        Icons.location_on,
                        'Location',
                        tournament.location,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date',
                        '${tournament.startDate.day}/${tournament.startDate.month}/${tournament.startDate.year}',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.access_time,
                        'Time',
                        '${tournament.startDate.hour}:${tournament.startDate.minute.toString().padLeft(2, '0')}',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.currency_rupee,
                        'Entry Fee',
                        '₹${tournament.entryFee.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.people,
                        'Participants',
                        '${tournament.currentParticipants}/${tournament.maxParticipants}',
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tournament.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textMediumColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Registration Button
                      if (tournament.status == TournamentStatus.upcoming)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: tournament.availabilityPercentage < 1.0
                                ? () => _showRegistrationDialog(
                                    context,
                                    tournament,
                                  )
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  tournament.availabilityPercentage < 1.0
                                  ? AppTheme.primaryColor
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              tournament.availabilityPercentage < 1.0
                                  ? 'Register Now - ₹${tournament.entryFee.toStringAsFixed(0)}'
                                  : 'Tournament Full',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDarkColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textMediumColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showRegistrationDialog(BuildContext context, Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tournament Registration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to register for "${tournament.name}"?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Entry Fee:'),
                      Text(
                        '₹${tournament.entryFee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Available Slots:'),
                      Text(
                        '${tournament.maxParticipants - tournament.currentParticipants}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
              Navigator.pop(context); // Close the tournament details
              _processRegistration(tournament);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void _processRegistration(Tournament tournament) {
    // Simulate registration process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration successful for ${tournament.name}!'),
        backgroundColor: AppTheme.successColor,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _selectedIndex = 2; // Navigate to bookings
            });
          },
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
            padding: const EdgeInsets.all(12), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Added to prevent overflow
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6), // Reduced padding
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 18,
                      ), // Reduced icon size
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14, // Reduced icon size
                      color: AppTheme.textMediumColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduced spacing
                Flexible(
                  // Made text flexible
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  // Made text flexible
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
