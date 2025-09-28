import 'package:flutter/material.dart';
import 'package:vetra/screens/users/bookings_page.dart'; // Add this new import
import 'package:vetra/screens/users/dashboard_content_page.dart';
import 'package:vetra/screens/users/search_page.dart';
import 'package:vetra/screens/users/tournament_videos_page.dart';
import 'package:vetra/screens/users/user_profile_screen.dart';
import 'package:vetra/screens/users/my_bookings_page.dart';
import 'package:vetra/screens/common/about_us_page.dart';
import 'package:vetra/services/session_service.dart';
import '../landing_page.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _selectedIndex = 0;
  String? _initialSportFilter;
  String? _initialStatusFilter;


  void _navigateToSearchWithSportFilter(String sport) {

  // CORRECTED: Renamed method to match its purpose
  void _navigateToSearchWithFilters({String? sport, String? status}) {

    setState(() {
      _initialSportFilter = sport;
      _initialStatusFilter = status;
      _selectedIndex = 1; // Index of the Search Page
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      if (_selectedIndex == 1 || index != 1) {
        _initialSportFilter = null;
        _initialStatusFilter = null;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- ✅ UPDATED THIS LIST ---
    final List<Widget> pages = [

      DashboardContentPage(onSportSelected: _navigateToSearchWithSportFilter),
      SearchPage(initialSportFilter: _initialSportFilter),
      const BookingsPage(), // Replaced placeholder with the actual page
      const TournamentVideosPage(),
      const Center(child: Text('My Profile - Coming Soon!', style: TextStyle(fontSize: 22))),

    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vetra'),
        backgroundColor: const Color(0xFF6f42c1),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to profile page when icon is tapped
                _onBottomNavTap(3);
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 18,
                child: Icon(
                  Icons.person,
                  size: 24,
                  color: Color(0xFF6f42c1),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
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
        // --- ✅ UPDATED THIS LIST ---
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
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About Us',
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          FutureBuilder<Map<String, String?>>(
            future: SessionService.getUserSession(),
            builder: (context, snapshot) {
              String displayName = 'User';
              if (snapshot.hasData && snapshot.data != null) {
                displayName = snapshot.data!['name'] ?? 
                            snapshot.data!['phone']?.replaceAll('+91', '') ?? 
                            'User';
              }
              
              return DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6f42c1), Color(0xFF8a63d2)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Color(0xFF6f42c1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tournament Participant',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Color(0xFF6f42c1)),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              _onBottomNavTap(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Color(0xFF6f42c1)),
            title: const Text('Find Tournaments'),
            onTap: () {
              Navigator.pop(context);
              _onBottomNavTap(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Color(0xFF6f42c1)),
            title: const Text('My Bookings'),
            onTap: () {
              Navigator.pop(context);
              _onBottomNavTap(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_library, color: Color(0xFF6f42c1)),
            title: const Text('Tournament Videos'),
            onTap: () {
              Navigator.pop(context);
              _onBottomNavTap(3);
            },
          ),
          // --- ✅ UPDATED PROFILE NAVIGATION ---
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF6f42c1)),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              _onBottomNavTap(4); // Corrected index to 4
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFF6f42c1)),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              _onBottomNavTap(4); // Navigate to About Us tab (index 4)
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
    );
  }
}