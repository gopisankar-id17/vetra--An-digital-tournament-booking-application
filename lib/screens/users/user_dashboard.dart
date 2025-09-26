import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../landing_page.dart'; // Assuming this path is correct

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  // 1. Add Carousel Controller and Index for Trending
  final CarouselSliderController _upcomingCarouselController = CarouselSliderController();
  final CarouselSliderController _ongoingCarouselController = CarouselSliderController();
  final CarouselSliderController _trendingCarouselController = CarouselSliderController(); // New Controller
  int _upcomingCurrentIndex = 0;
  int _ongoingCurrentIndex = 0;
  int _trendingCurrentIndex = 0; // New Index

  final List<Map<String, dynamic>> _upcomingTournaments = [
    {'title': 'Football Cup 2025', 'date': 'Jan 15', 'imageUrl': 'assets/images/football.jpg'},
    {'title': 'Basketball League', 'date': 'Feb 01', 'imageUrl': 'assets/images/basketball.jpg'},
    {'title': 'Cricket Series', 'date': 'Mar 10', 'imageUrl': 'assets/images/cricket.jpg'},
  ];

  final List<Map<String, dynamic>> _ongoingTournaments = [
    {'title': 'Esports Masters', 'imageUrl': 'assets/images/esports_1.jpg', 'color': const Color(0xFF1ABC9C)},
    {'title': 'Tennis Open', 'imageUrl': 'assets/images/tennis_2.jpg', 'color': const Color(0xFF2ECC71)},
    {'title': 'Volleyball Smash', 'imageUrl': 'assets/images/volleyball_3.jpg', 'color': const Color(0xFF3498DB)},
    {'title': 'Badminton Blitz', 'imageUrl': 'assets/images/badminton_4.jpg', 'color': const Color(0xFF9B59B6)},
    {'title': 'Chess Championship', 'imageUrl': 'assets/images/chess_5.jpg', 'color': const Color(0xFFE67E22)},
  ];

  // Modified structure to include image for carousel card look
  final List<Map<String, dynamic>> _trendingTournaments = [
    {'title': 'City Marathon', 'status': 'HIGH DEMAND', 'imageUrl': 'assets/images/running.jpg', 'color': const Color(0xFF3498DB)},
    {'title': 'Beach Soccer', 'status': 'POPULAR', 'imageUrl': 'assets/images/beach_soccer.jpg', 'color': const Color(0xFFE67E22)},
    {'title': 'Mountain Bike Race', 'status': 'NEW', 'imageUrl': 'assets/images/mtb.jpg', 'color': const Color(0xFF2ECC71)},
    {'title': 'Local Swimming Meet', 'status': 'HOT', 'imageUrl': 'assets/images/swimming.jpg', 'color': const Color(0xFF9B59B6)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: const Color(0xFF27AE60),
        foregroundColor: Colors.white,
        elevation: 0,
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
                  colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
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
                      color: Color(0xFF27AE60),
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
              leading: const Icon(Icons.dashboard, color: Color(0xFF27AE60)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports, color: Color(0xFF27AE60)),
              title: const Text('Find Tournaments'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar(context, 'Tournament search');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF27AE60)),
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar(context, 'Booking history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF27AE60)),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackbar(context, 'Profile management');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFF27AE60)),
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
              onTap: () {
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
                              ? const Color(0xFF3498DB)
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
                              ? const Color(0xFFE74C3C)
                              : Colors.grey.withOpacity(0.4),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // --- Trending Tournaments Section (Now a Carousel) ---
                _buildSectionHeader(context, 'Trending Now 🔥', () => _showComingSoonSnackbar(context, 'Trending Tournaments')),
                const SizedBox(height: 15),
                // NEW CAROUSEL IMPLEMENTATION
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
                              ? const Color(0xFFE67E22) // Use a distinct color for trending
                              : Colors.grey.withOpacity(0.4),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                // END NEW CAROUSEL IMPLEMENTATION

                const SizedBox(height: 30),

                // --- Quick Actions Section ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildQuickActionButton(
                            'Find Tournament',
                            Icons.search,
                            () => _showComingSoonSnackbar(context, 'Tournament search'),
                          ),
                          _buildQuickActionButton(
                            'Book Slot',
                            Icons.add_circle,
                            () => _showComingSoonSnackbar(context, 'Booking feature'),
                          ),
                          _buildQuickActionButton(
                            'View History',
                            Icons.history,
                            () => _showComingSoonSnackbar(context, 'History feature'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Utility Functions ---

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
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
              color: Color(0xFF27AE60),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
  
  // New: Trending Tournament Card for Carousel
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

  // Existing: Upcoming Tournament Card
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
                  color: Colors.blue[100],
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
                  backgroundColor: Color(0xFF3498DB),
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

  // Existing: Ongoing Tournament Card
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
                  color: Colors.red[100],
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
                  backgroundColor: Color(0xFFE74C3C),
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
                      backgroundColor: const Color(0xFF3498DB),
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
                      backgroundColor: const Color(0xFF2ECC71),
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
                      backgroundColor: const Color(0xFF3498DB),
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
                      backgroundColor: const Color(0xFF2ECC71),
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

  // NOTE: This function is no longer used in the build method as it was for the previous ListTiles
  Widget _buildTrendingTournamentTile(BuildContext context, String title, String status, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showComingSoonSnackbar(context, 'Viewing trending tournament $title'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
          ),
          trailing: Chip(
            label: Text(
              status,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
            ),
            backgroundColor: color,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: const Color(0xFF27AE60),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}