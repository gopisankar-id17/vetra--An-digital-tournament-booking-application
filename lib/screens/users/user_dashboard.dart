import 'package:flutter/material.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar automatically displays the drawer icon when a drawer is present.
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      // The Drawer widget is the sliding menu.
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            // The DrawerHeader provides a header for the drawer.
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'User Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // The ListTile widget is used for each menu item.
            ListTile(
              leading: const Icon(Icons.sports),
              title: const Text('Find Tournaments'),
              onTap: () {
                // TODO: Navigate to the tournament search page.
                Navigator.pop(context); // Closes the drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('My Bookings'),
              onTap: () {
                // TODO: Navigate to the my bookings page.
                Navigator.pop(context); // Closes the drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                // TODO: Navigate to the user profile page.
                Navigator.pop(context); // Closes the drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Implement logout functionality.
                Navigator.pop(context); // Closes the drawer.
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome, User!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
