import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar automatically displays the drawer icon when a drawer is present.
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.indigo,
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
                color: Colors.indigo,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            // The ListTile widget is used for each menu item.
            ListTile(
              leading: const Icon(Icons.sports_soccer),
              title: const Text('Manage Tournaments'),
              onTap: () {
                // TODO: Navigate to the manage tournaments page.
                Navigator.pop(context); // Closes the drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('View Users'),
              onTap: () {
                // TODO: Navigate to the view users page.
                Navigator.pop(context); // Closes the drawer.
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('View Reports'),
              onTap: () {
                // TODO: Navigate to the reports page.
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
          'Welcome, Admin!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
  