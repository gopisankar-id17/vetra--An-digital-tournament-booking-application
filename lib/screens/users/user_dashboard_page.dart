import 'package:flutter/material.dart';
import 'package:vetra/screens/users/dashboard_content_page.dart';
import 'package:vetra/screens/users/search_page.dart';
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
  // CORRECTED: Renamed variable to match its purpose
  String? _initialSportFilter;
  String? _initialStatusFilter;

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
    final List<Widget> pages = [
      // CORRECTED: Parameter name changed from onCategorySelected to onSportSelected
      DashboardContentPage(
        onSportSelected: (sport) => _navigateToSearchWithFilters(sport: sport),
        onNavigateToSearch: _navigateToSearchWithFilters,
      ),
      // CORRECTED: Parameter name changed from initialFormatFilter to initialSportFilter
      SearchPage(
        initialSportFilter: _initialSportFilter,
        initialStatusFilter: _initialStatusFilter,
      ),
      const MyBookingsPage(), // New bookings page with sample data
      const UserProfileScreen(),
      const AboutUsPage(), // Added About Us page as 5th tab
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vetra'),
        backgroundColor: const Color(0xFF6f42c1),
        foregroundColor: Colors.white,
        elevation: 0,
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
            leading: const Icon(Icons.person, color: Color(0xFF6f42c1)),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              _onBottomNavTap(3);
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