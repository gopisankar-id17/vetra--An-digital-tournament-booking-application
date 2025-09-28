import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/user.dart';
import '../../models/tournament.dart';
import '../../services/organizer_service.dart';
import '../../services/session_service.dart';
import '../../utils/app_theme.dart';

import '../../widgets/app_drawer.dart';
import '../../widgets/professional_fab.dart';
import 'organizer_add_tournament_page.dart';
import 'organizer_tournament_details_page.dart';
import 'organizer_tournaments_list_page.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() =>
      _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, String?> _organizerData = {}; // Current organizer data
  int _refreshCounter = 0; // Used to force rebuilds

  // Tournament data
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
    _loadOrganizerData();
  }

  // Load organizer data and tournaments
  Future<void> _loadOrganizerData() async {
    try {
      final organizerData = await SessionService.getOrganizerSession();
      if (organizerData['id'] != null) {
        setState(() {
          _organizerData = organizerData;
        });
        await _loadTournaments();
      }
    } catch (e) {
      print('Error loading organizer data: $e');
    }
  }

  // Load tournaments from database (filtered for this organizer)
  Future<void> _loadTournaments() async {
    if (_organizerData['id'] == null) return;

    try {
      setState(() => _isLoadingTournaments = true);
      final tournaments = await OrganizerService.getOrganizerTournaments(
        _organizerData['id']!,
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        actions: [
          // Show refresh button for Dashboard and Tournaments tabs
          if (_selectedIndex == 0 || _selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_selectedIndex == 0) {
                  _loadTournaments(); // Refresh dashboard data
                } else {
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
        user: User(
          id: _organizerData['id'] ?? '',
          name: _organizerData['name'] ?? 'Organizer',
          email: _organizerData['email'] ?? '',
          isAdmin: false,
          role: 'organizer',
        ),
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
        currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex,
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
            label: 'My Tournaments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Participants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
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
        return 'Organizer Dashboard';
      case 1:
        return 'My Tournaments';
      case 2:
        return 'Participant Management';
      case 3:
        return 'Notifications';
      case 4:
        return 'Profile';
      default:
        return 'Organizer Dashboard';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildTournamentsContent();
      case 2:
        return _buildParticipantsContent();
      case 3:
        return _buildNotificationsContent();
      case 4:
        return _buildProfileContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    if (_isLoadingTournaments) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    // Filter tournaments by actual dates instead of status field
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
          // Welcome Card
          _buildWelcomeCard(),

          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(),

          const SizedBox(height: 24),

          // Upcoming tournaments
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

          // Ongoing tournaments
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

          // Completed tournaments
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

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: _organizerData['photoUrl'] != null
                    ? NetworkImage(_organizerData['photoUrl']!)
                    : null,
                backgroundColor: Colors.white,
                child: _organizerData['photoUrl'] == null
                    ? const Icon(
                        Icons.business,
                        size: 30,
                        color: AppTheme.primaryColor,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      _organizerData['name'] ?? 'Organizer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage your tournaments and engage with participants',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Tournaments',
            '${_allTournaments.length}',
            Icons.emoji_events,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            '${_allTournaments.where((t) => t.startDate.isBefore(DateTime.now()) && t.endDate.isAfter(DateTime.now())).length}',
            Icons.play_circle_fill,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Participants',
            '${_allTournaments.fold(0, (sum, t) => sum + t.currentParticipants)}',
            Icons.people,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentsContent() {
    return OrganizerTournamentsListPage(key: ValueKey(_refreshCounter));
  }

  Widget _buildParticipantsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Participants Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go to Tournaments tab and select a tournament\nto manage its participants',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() => _selectedIndex = 1); // Navigate to tournaments tab
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('View Tournaments'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsContent() {
    return const Center(
      child: Text(
        'Notifications for organizers',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      (_organizerData['name'] ?? 'O')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _organizerData['name'] ?? 'Organizer',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _organizerData['email'] ?? 'organizer@example.com',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Organizer',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Profile Options
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit Profile - Coming Soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.business,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Organization Settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Organization Settings - Coming Soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: AppTheme.primaryColor,
                  ),
                  title: const Text('Notification Settings'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification Settings - Coming Soon'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help, color: AppTheme.primaryColor),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Help & Support - Coming Soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout Button
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _handleLogout(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        print('Organizer logout: Starting logout process...');

        // Clear organizer session
        await SessionService.clearOrganizerSession();
        print('Organizer logout: Session cleared');

        // Sign out from Firebase Auth as well
        try {
          await OrganizerService.signOut();
          print('Organizer logout: Firebase Auth signed out');
        } catch (e) {
          print('Organizer logout: Firebase Auth error: $e');
          // Continue even if Firebase signout fails
        }

        print('Organizer logout: Navigating to landing page...');
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          print('Organizer logout: Navigation completed');
        }
      } catch (e) {
        print('Organizer logout: Error during logout: $e');

        // Even on error, try to navigate
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout error: $e'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      }
    }
  }

  // Tournament carousel builder (similar to admin dashboard)
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
                return _buildOrganizerTournamentCard(
                  context,
                  tournament,
                  cardType,
                );
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
                      : Colors.grey.withValues(alpha: 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrganizerTournamentCard(
    BuildContext context,
    Tournament tournament,
    String cardType,
  ) {
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
            builder: (context) =>
                OrganizerTournamentDetailsPage(tournament: tournament),
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
              color: Colors.black.withValues(alpha: 0.1),
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
              // Tournament image or gradient background
              if (tournament.imageUrl != null &&
                  tournament.imageUrl!.isNotEmpty &&
                  (tournament.imageUrl!.startsWith('http://') ||
                      tournament.imageUrl!.startsWith('https://')))
                Image.network(
                  tournament.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            statusColor.withValues(alpha: 0.8),
                            statusColor.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        statusColor.withValues(alpha: 0.8),
                        statusColor.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              // Dark overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Content
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
                        const Icon(
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
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(tournament.startDate),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
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
                    color: Colors.white.withValues(alpha: 0.9),
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
                    color: Colors.black.withValues(alpha: 0.6),
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

  void _showCreateTournamentDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrganizerAddTournamentPage(
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
