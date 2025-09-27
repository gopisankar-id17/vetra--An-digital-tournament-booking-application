import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../landing_page.dart'; // Assuming this path is correct
import '../../auth_service.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  // Bottom navigation
  int _selectedIndex = 0;

  // Carousel Controllers and Indices
  final CarouselSliderController _upcomingCarouselController = CarouselSliderController();
  final CarouselSliderController _ongoingCarouselController = CarouselSliderController();
  final CarouselSliderController _trendingCarouselController = CarouselSliderController();
  int _upcomingCurrentIndex = 0;
  int _ongoingCurrentIndex = 0;
  int _trendingCurrentIndex = 0;

  final List<Map<String, dynamic>> _upcomingTournaments = [
    {'title': 'Football Cup 2025', 'date': 'Jan 15', 'imageUrl': 'assets/images/football.jpg'},
    {'title': 'Basketball League', 'date': 'Feb 01', 'imageUrl': 'assets/images/basketball.jpg'},
    {'title': 'Cricket Series', 'date': 'Mar 10', 'imageUrl': 'assets/images/cricket.jpg'},
  ];

  final List<Map<String, dynamic>> _ongoingTournaments = [
    {'title': 'Esports Masters', 'imageUrl': 'assets/images/esports_1.jpg', 'color': const Color(0xFF6f42c1)},
    {'title': 'Tennis Open', 'imageUrl': 'assets/images/tennis_2.jpg', 'color': const Color(0xFF8a63d2)},
    {'title': 'Volleyball Smash', 'imageUrl': 'assets/images/volleyball_3.jpg', 'color': const Color(0xFF6f42c1)},
    {'title': 'Badminton Blitz', 'imageUrl': 'assets/images/badminton_4.jpg', 'color': const Color(0xFF8a63d2)},
    {'title': 'Chess Championship', 'imageUrl': 'assets/images/chess_5.jpg', 'color': const Color(0xFF6f42c1)},
  ];

  final List<Map<String, dynamic>> _trendingTournaments = [
    {'title': 'City Marathon', 'status': 'HIGH DEMAND', 'imageUrl': 'assets/images/running.jpg', 'color': const Color(0xFF6f42c1)},
    {'title': 'Beach Soccer', 'status': 'POPULAR', 'imageUrl': 'assets/images/beach_soccer.jpg', 'color': const Color(0xFF8a63d2)},
    {'title': 'Mountain Bike Race', 'status': 'NEW', 'imageUrl': 'assets/images/mtb.jpg', 'color': const Color(0xFF6f42c1)},
    {'title': 'Local Swimming Meet', 'status': 'HOT', 'imageUrl': 'assets/images/swimming.jpg', 'color': const Color(0xFF8a63d2)},
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        _showComingSoonSnackbar(context, 'Tournament search');
        break;
      case 2:
        _showComingSoonSnackbar(context, 'My bookings');
        break;
      case 3:
        _showComingSoonSnackbar(context, 'My profile');
        break;
      case 4:
        _showComingSoonSnackbar(context, 'Notifications');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: const Color(0xFF6f42c1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                _showProfileMenu(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage('assets/images/ronaldo.jpg'), // You can change this to user's actual profile image
                  onBackgroundImageError: (exception, stackTrace) {
                    // Image will fall back to child icon
                  },
                  child: const Icon(
                    Icons.person,
                    size: 20,
                    color: Color(0xFF6f42c1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6f42c1), Color(0xFF8a63d2)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Color(0xFF6f42c1),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'User Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tournament Participant',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF6f42c1)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports, color: Color(0xFF6f42c1)),
              title: const Text('Find Tournaments'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar(context, 'Tournament search');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF6f42c1)),
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar(context, 'Booking history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF6f42c1)),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar(context, 'Profile management');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFF6f42c1)),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar(context, 'Notifications');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                // Clear user session
                final authService = AuthService();
                await authService.logoutUser();
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FA), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back! 👋',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ready to join some tournaments?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
                const SizedBox(height: 30),

                // --- Upcoming Tournaments Section ---
                _buildSectionHeader(context, 'Upcoming Tournaments 🗓️', () => _showComingSoonSnackbar(context, 'Upcoming Tournaments')),
                const SizedBox(height: 15),
                CarouselSlider(
                  carouselController: _upcomingCarouselController,
                  options: CarouselOptions(
                    height: 160.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 16 / 9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _upcomingCurrentIndex = index;
                      });
                    },
                  ),
                  items: _upcomingTournaments.map((tournament) {
                    return Builder(
                      builder: (BuildContext context) {
                        return _buildUpcomingTournamentPhotoCard(
                          context,
                          tournament['title']!,
                          tournament['date']!,
                          tournament['imageUrl']!,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // Page indicator for upcoming tournaments
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _upcomingTournaments.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _upcomingCarouselController.animateToPage(entry.key),
                      child: Container(
                        width: _upcomingCurrentIndex == entry.key ? 12.0 : 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: _upcomingCurrentIndex == entry.key
                              ? const Color(0xFF6f42c1)
                              : Colors.grey.withOpacity(0.4),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // --- Ongoing Tournaments Section ---
                _buildSectionHeader(context, 'Ongoing Tournaments 🥇', () => _showComingSoonSnackbar(context, 'Ongoing Tournaments')),
                const SizedBox(height: 15),
                CarouselSlider(
                  carouselController: _ongoingCarouselController,
                  options: CarouselOptions(
                    height: 160.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 16 / 9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _ongoingCurrentIndex = index;
                      });
                    },
                  ),
                  items: _ongoingTournaments.map((tournament) {
                    return Builder(
                      builder: (BuildContext context) {
                        return _buildOngoingTournamentPhotoCard(
                          context,
                          tournament['title']!,
                          tournament['imageUrl']!,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // Page indicator for ongoing tournaments
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _ongoingTournaments.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _ongoingCarouselController.animateToPage(entry.key),
                      child: Container(
                        width: _ongoingCurrentIndex == entry.key ? 12.0 : 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: _ongoingCurrentIndex == entry.key
                              ? const Color(0xFF8a63d2)
                              : Colors.grey.withOpacity(0.4),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // --- Trending Tournaments Section ---
                _buildSectionHeader(context, 'Trending Now 🔥', () => _showComingSoonSnackbar(context, 'Trending Tournaments')),
                const SizedBox(height: 15),
                CarouselSlider(
                  carouselController: _trendingCarouselController,
                  options: CarouselOptions(
                    height: 160.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    aspectRatio: 16 / 9,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _trendingCurrentIndex = index;
                      });
                    },
                  ),
                  items: _trendingTournaments.map((tournament) {
                    return Builder(
                      builder: (BuildContext context) {
                        return _buildTrendingTournamentCard(
                          context,
                          tournament['title']!,
                          tournament['status']!,
                          tournament['imageUrl']!,
                          tournament['color'] as Color,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // Page indicator for trending tournaments
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _trendingTournaments.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _trendingCarouselController.animateToPage(entry.key),
                      child: Container(
                        width: _trendingCurrentIndex == entry.key ? 12.0 : 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          color: _trendingCurrentIndex == entry.key
                              ? const Color(0xFF6f42c1)
                              : Colors.grey.withOpacity(0.4),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // --- Tournament Stats Section ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6f42c1),
                        const Color(0xFF8a63d2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6f42c1).withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your Tournament Journey',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Tournaments\nJoined', '8', Icons.sports_soccer),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatCard('Wins', '3', Icons.emoji_events),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatCard('Rank', '#24', Icons.trending_up),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Achievement: Tournament Enthusiast Unlocked!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90), // Extra space for bottom nav
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        selectedItemColor: const Color(0xFF6f42c1),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  // --- Utility Functions ---

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF6f42c1).withOpacity(0.1),
                    backgroundImage: const AssetImage('assets/images/ronaldo.jpg'),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Color(0xFF6f42c1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        Text(
                          'Tournament Enthusiast',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Menu items
              ListTile(
                leading: const Icon(Icons.person_outline, color: Color(0xFF6f42c1)),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackbar(context, 'Profile editing');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Color(0xFF6f42c1)),
                title: const Text('Settings'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackbar(context, 'Settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Color(0xFF6f42c1)),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonSnackbar(context, 'Help & Support');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  
                  // Clear user session
                  final authService = AuthService();
                  await authService.logoutUser();
                  
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LandingPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6f42c1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrendingTournamentCard(BuildContext context, String title, String status, String imagePath, Color tagColor) {
    return GestureDetector(
      onTap: () {
        _showComingSoonSnackbar(context, 'Viewing trending tournament $title');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: tagColor.withOpacity(0.2),
                  child: Center(
                      child: Text(title,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: tagColor, fontWeight: FontWeight.bold))),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Trending Now',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text(status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  backgroundColor: tagColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTournamentPhotoCard(BuildContext context, String title, String date, String imagePath) {
    return GestureDetector(
      onTap: () {
        _showUpcomingTournamentDetails(context, title, date);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF6f42c1).withOpacity(0.2),
                  child: Center(child: Text(title, textAlign: TextAlign.center)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 10,
                right: 10,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text('UPCOMING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  backgroundColor: Color(0xFF6f42c1),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingTournamentPhotoCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        _showOngoingTournamentDetails(context, title);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF8a63d2).withOpacity(0.2),
                  child: Center(child: Text(title, textAlign: TextAlign.center)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                  backgroundColor: Color(0xFF8a63d2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showUpcomingTournamentDetails(BuildContext context, String title, String date) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7F8C8D)),
                  const SizedBox(width: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text('View Details'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoonSnackbar(context, 'Viewing details for $title');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6f42c1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text('Register'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoonSnackbar(context, 'Registering for $title');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8a63d2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showOngoingTournamentDetails(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text('View Details'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoonSnackbar(context, 'Viewing details for $title');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6f42c1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.how_to_reg),
                    label: const Text('Register'),
                    onPressed: () {
                      Navigator.pop(context);
                      _showComingSoonSnackbar(context, 'Registering for $title');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8a63d2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }



  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


}