import 'package:flutter/material.dart';
import 'package:vetra/screens/users/dashboard_content_page.dart';
import 'package:vetra/screens/users/search_page.dart';
import 'package:vetra/screens/users/user_profile_page.dart';
import '../../models/user.dart';
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
  // Sample user for the profile page
  late User _currentUser;
  
  @override
  void initState() {
    super.initState();
    _currentUser = User.sampleUser(); // Initialize with a sample user
  }

  // CORRECTED: Renamed method to match its purpose
  void _navigateToSearchWithSportFilter(String sport) {
    setState(() {
      _initialSportFilter = sport;
      _selectedIndex = 1; // Index of the Search Page
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      if (_selectedIndex == 1 || index != 1) {
        _initialSportFilter = null;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // CORRECTED: Parameter name changed from onCategorySelected to onSportSelected
      DashboardContentPage(onSportSelected: _navigateToSearchWithSportFilter),
      // CORRECTED: Parameter name changed from initialFormatFilter to initialSportFilter
      SearchPage(initialSportFilter: _initialSportFilter),
      const Center(child: Text('My Bookings - Coming Soon!', style: TextStyle(fontSize: 22))),
      UserProfilePage(user: _currentUser), // Using the user profile page with the sample user
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
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
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