import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/user.dart';
import '../../models/tournament.dart';
import '../../services/tournament_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/professional_fab.dart';
import 'add_tournament_page.dart';
import 'tournament_details_page.dart';
import 'tournaments_list_page.dart';
import 'tournament_requests_page.dart';
import 'package:vetra/screens/admin/add_video_page.dart'; // Adjust the path as per your project structure

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final User _adminUser = User.sampleAdmin();
  int _refreshCounter = 0; // Used to force rebuilds

  // Tournament service and data
  final TournamentService _tournamentService = TournamentService();
  List<Tournament> _allTournaments = [];
  bool _isLoadingTournaments = true;

  // Carousel controllers and indices for tournament carousels
  final CarouselSliderController _upcomingCarouselController =
      CarouselSliderController();
  final CarouselSliderController _ongoingCarouselController =
      CarouselSliderController();
  final CarouselSliderController _completedCarouselController =
      CarouselSliderController();
  int _upcomingCurrentIndex = 0;
  int _ongoingCurrentIndex = 0;
  int _completedCurrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  // Load tournaments from database
  Future<void> _loadTournaments() async {
    try {
      setState(() => _isLoadingTournaments = true);
      final tournaments = await _tournamentService.getAllTournaments();

      // Debug: Log tournament image URLs
      for (var tournament in tournaments) {
        print('Tournament: ${tournament.name}');
        print('Image URL: ${tournament.imageUrl}');
        print('Image URL is empty: ${tournament.imageUrl?.isEmpty ?? true}');
        print('---');
      }

      setState(() {
        _allTournaments = tournaments;
        _isLoadingTournaments = false;
      });
    } catch (e) {
      setState(() => _isLoadingTournaments = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tournaments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to map drawer index to bottom navigation index
  int _getBottomNavIndex(int selectedDrawerIndex) {
    switch (selectedDrawerIndex) {
      case 0: return 0; // Dashboard
      case 1: return 1; // Tournaments
      case 2: return 2; // Requests
      case 3: return 3; // Notifications
      case 7: return 4; // Profile (assuming profile is the 5th item in bottom nav)
      default: return 0; // Default to Dashboard for other pages like Videos, Analytics, etc.
    }
  }

  // Handles taps on the bottom navigation bar
  void _onBottomNavTap(int index) {
    setState(() {
      switch (index) {
        case 0: _selectedIndex = 0; break; // Dashboard
        case 1: _selectedIndex = 1; break; // Tournaments
        case 2: _selectedIndex = 2; break; // Requests
        case 3: _selectedIndex = 3; break; // Notifications
        case 4: _selectedIndex = 7; break; // Profile (maps to drawer index 7)
        default: _selectedIndex = 0;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        actions: [
          // Show refresh button for Dashboard, Tournaments and Tournament Requests tabs
          if (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_selectedIndex == 0) {
                  _loadTournaments(); // Refresh dashboard data
                } else {
                  // Refresh tournaments or requests page by changing key
                  setState(() {
                    _refreshCounter++;
                  });
                }
              },
              tooltip: 'Refresh',
            ),
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
  currentIndex: _getBottomNavIndex(_selectedIndex),
  selectedItemColor: AppTheme.primaryColor,
  unselectedItemColor: Colors.grey,
  backgroundColor: Colors.white,
  elevation: 10,
  onTap: _onBottomNavTap,
  iconSize: 32.0, // Increased icon size as per your previous request
  selectedFontSize: 0, // Remove label height to reduce gap
  unselectedFontSize: 0, // Remove label height to reduce gap
  items: const [
    BottomNavigationBarItem(
      icon: Center(
        child: Icon(Icons.dashboard),
      ),
      label: '', // Empty label
    ),
    BottomNavigationBarItem(
      icon: Center(
        child: Icon(Icons.emoji_events),
      ),
      label: '', // Empty label
    ),
    BottomNavigationBarItem(
      icon: Center(
        child: Icon(Icons.approval),
      ),
      label: '', // Empty label
    ),
    BottomNavigationBarItem(
      icon: Center(
        child: Icon(Icons.notifications),
      ),
      label: '', // Empty label
    ),
    BottomNavigationBarItem(
      icon: Center(
        child: Icon(Icons.person),
      ),
      label: '', // Empty label
    ),
  ],
),
      
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Admin Dashboard';
      case 1:
        return 'Manage Tournaments';
      case 2:
        return 'Tournament Requests';
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
      case 9: // This index is now only for the drawer
        return 'YouTube Videos';
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
        return TournamentRequestsPage(key: ValueKey(_refreshCounter));
      case 3:
        return _buildNotificationsContent();
      case 4:
        return const Center(child: Text('Manage Users - Coming Soon!', style: TextStyle(fontSize: 22)));
      case 5:
        return const Center(child: Text('Analytics Dashboard - Coming Soon!', style: TextStyle(fontSize: 22)));
      case 6:
        return _buildReportsContent();
      case 7:
        return _buildProfileContent();
      case 8:
        return _buildSettingsContent();
      case 9:
        return const AddVideoPage(); // This is the correct page, accessed via drawer
      default:
        return Center(
          child: Text(
            '${_getScreenTitle()} - Coming Soon',
            style: const TextStyle(fontSize: 18),
          ),
        );
    }
  }

  // The rest of your methods (_buildDashboardContent, _buildTournamentsContent,
  // _buildNotificationsContent, _buildProfileContent, _buildSettingsContent,
  // _showCreateTournamentDialog, _buildTournamentCarousel, _buildAdminTournamentCard,
  // _formatDate, _getDisplayDate, _getTournamentProgress, _buildFilterChip)
  // remain unchanged as you provided.
  // I will only include the missing ones that were in the original AdminDashboardScreen but not provided by you in the previous prompt.

  Widget _buildDashboardContent() {
    if (_isLoadingTournaments) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    final now = DateTime.now();

    final upcomingTournaments = _allTournaments.where((t) {
      return t.startDate.isAfter(now);
    }).toList();

    final ongoingTournaments = _allTournaments.where((t) {
      return t.startDate.isBefore(now) && t.endDate.isAfter(now);
    }).toList();

    final completedTournaments = _allTournaments.where((t) {
      return t.endDate.isBefore(now);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTournamentCarousel(
            title: 'Upcoming Tournaments 🗓️',
            tournaments: upcomingTournaments,
            carouselController: _upcomingCarouselController,
            currentIndex: _upcomingCurrentIndex,
            onPageChanged: (index) =>
                setState(() => _upcomingCurrentIndex = index),
            cardType: 'upcoming',
          ),
          const SizedBox(height: 24),
          _buildTournamentCarousel(
            title: 'Ongoing Tournaments 🥇',
            tournaments: ongoingTournaments,
            carouselController: _ongoingCarouselController,
            currentIndex: _ongoingCurrentIndex,
            onPageChanged: (index) =>
                setState(() => _ongoingCurrentIndex = index),
            cardType: 'ongoing',
          ),
          const SizedBox(height: 24),
          _buildTournamentCarousel(
            title: 'Completed Tournaments ✅',
            tournaments: completedTournaments,
            carouselController: _completedCarouselController,
            currentIndex: _completedCurrentIndex,
            onPageChanged: (index) =>
                setState(() => _completedCurrentIndex = index),
            cardType: 'completed',
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsContent() {
    return TournamentsListPage(key: ValueKey(_refreshCounter));
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
            _loadTournaments(); // Reload tournament data from database
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

  // Tournament Carousel Builder
  Widget _buildTournamentCarousel({
    required String title,
    required List<Tournament> tournaments,
    required CarouselSliderController carouselController,
    required int currentIndex,
    required Function(int) onPageChanged,
    required String cardType,
  }) {
    if (tournaments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No ${cardType.toLowerCase()} tournaments',
                style: const TextStyle(color: AppTheme.textMediumColor),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDarkColor,
          ),
        ),
        const SizedBox(height: 15),
        CarouselSlider(
          carouselController: carouselController,
          options: CarouselOptions(
            height: 180.0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: cardType == 'ongoing' ? 4 : 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            aspectRatio: 16 / 9,
            onPageChanged: (index, reason) {
              onPageChanged(index);
            },
          ),
          items: tournaments.map((tournament) {
            return Builder(
              builder: (BuildContext context) {
                return _buildAdminTournamentCard(context, tournament, cardType);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: tournaments.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => carouselController.animateToPage(entry.key),
              child: Container(
                width: currentIndex == entry.key ? 12.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: currentIndex == entry.key
                      ? AppTheme.primaryColor
                      : Colors.grey.withOpacity(0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Admin Tournament Card Builder
  Widget _buildAdminTournamentCard(
    BuildContext context,
    Tournament tournament,
    String cardType,
  ) {
    // Debug: Print tournament info
    print('Building card for: ${tournament.name}');
    print('Image URL: "${tournament.imageUrl}"');
    print(
      'Has image URL: ${tournament.imageUrl != null && tournament.imageUrl!.isNotEmpty}',
    );
    print('Is HTTP URL: ${tournament.imageUrl?.startsWith('http') ?? false}');

    // Get actual status based on dates
    final now = DateTime.now();
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (tournament.startDate.isAfter(now)) {
      statusColor = const Color(0xFF3498DB);
      statusLabel = 'UPCOMING';
      statusIcon = Icons.schedule;
    } else if (tournament.startDate.isBefore(now) &&
        tournament.endDate.isAfter(now)) {
      statusColor = const Color(0xFFE74C3C);
      statusLabel = 'LIVE';
      statusIcon = Icons.play_circle_filled;
    } else {
      statusColor = const Color(0xFF27AE60);
      statusLabel = 'COMPLETED';
      statusIcon = Icons.check_circle;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentDetailsPage(tournament: tournament),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Tournament image from database as background
              Builder(
                builder: (context) {
                  final hasValidImageUrl =
                      tournament.imageUrl != null &&
                      tournament.imageUrl!.isNotEmpty &&
                      (tournament.imageUrl!.startsWith('http://') ||
                          tournament.imageUrl!.startsWith('https://'));

                  print('Has valid image URL: $hasValidImageUrl');

                  if (hasValidImageUrl) {
                    return Image.network(
                      tournament.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          print(
                            'Image loaded successfully: ${tournament.imageUrl}',
                          );
                          return child;
                        }
                        print('Loading image: ${tournament.imageUrl}');
                        return Container(
                          color: Colors.grey[200],
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
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        print('Image URL: ${tournament.imageUrl}');
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                statusColor.withOpacity(0.8),
                                statusColor.withOpacity(0.6),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white70,
                                  size: 30,
                                ),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    print('Using fallback gradient - no valid image URL');
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            statusColor.withOpacity(0.8),
                            statusColor.withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              color: Colors.white70,
                              size: 30,
                            ),
                            Text(
                              'No image available',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              // Dark overlay for better text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              // Content overlay
              Positioned(
                bottom: 20,
                left: 15,
                right: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tournament.location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDisplayDate(tournament),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    // Show progress bar for ongoing tournaments
                    if (tournament.startDate.isBefore(DateTime.now()) &&
                        tournament.endDate.isAfter(DateTime.now())) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white30,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _getTournamentProgress(tournament),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'In Progress • ${(_getTournamentProgress(tournament) * 100).toInt()}% Complete',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status chip
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
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
              ),
              // Participants count
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '${tournament.currentParticipants}/${tournament.maxParticipants}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Get appropriate date text based on tournament status
  String _getDisplayDate(Tournament tournament) {
    final now = DateTime.now();

    if (tournament.startDate.isAfter(now)) {
      // Upcoming tournament - show start date
      return 'Starts ${_formatDate(tournament.startDate)}';
    } else if (tournament.startDate.isBefore(now) &&
        tournament.endDate.isAfter(now)) {
      // Ongoing tournament - show end date
      return 'Ends ${_formatDate(tournament.endDate)}';
    } else {
      // Completed tournament - show completion date
      return 'Completed ${_formatDate(tournament.endDate)}';
    }
  }

  // Calculate tournament progress (0.0 to 1.0) for ongoing tournaments
  double _getTournamentProgress(Tournament tournament) {
    final now = DateTime.now();
    if (now.isBefore(tournament.startDate)) return 0.0;
    if (now.isAfter(tournament.endDate)) return 1.0;

    final totalDuration = tournament.endDate
        .difference(tournament.startDate)
        .inMilliseconds;
    final elapsed = now.difference(tournament.startDate).inMilliseconds;

    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }
}