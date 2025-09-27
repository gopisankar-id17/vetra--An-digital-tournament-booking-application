import 'package:flutter/material.dart';
import '../landing_page.dart';
import 'tournaments_list_page.dart';
import 'add_tournament_page.dart';
import 'tournament_details_demo.dart';
import '../../auth_service.dart';
import '../../models/tournament.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFE74C3C),
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
                  colors: [Color(0xFFE74C3C), Color(0xFFC0392B)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 35,
                      color: Color(0xFFE74C3C),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Tournament Management',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFFE74C3C)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sports_soccer,
                color: Color(0xFFE74C3C),
              ),
              title: const Text('Tournament Management'),
              subtitle: const Text('Create, manage & track tournaments'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TournamentsListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Color(0xFF9B59B6)),
              title: const Text('Demo Features'),
              subtitle: const Text('View comprehensive tournament details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TournamentDetailsDemo(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFFE74C3C)),
              title: const Text('View Users'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User management coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Color(0xFFE74C3C)),
              title: const Text('Reports & Analytics'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFFE74C3C)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                // Clear admin session
                final authService = AuthService();
                await authService.logoutAdmin();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingPage(),
                    ),
                    (route) => false,
                  );
                }
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome, Admin!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your tournament platform',
                style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
              ),
              const SizedBox(height: 16),

              // Quick Action Buttons Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tournament Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            'View All Tournaments',
                            Icons.list,
                            const Color(0xFF3498DB),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TournamentsListPage(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            'Demo Features',
                            Icons.play_circle,
                            const Color(0xFF9B59B6),
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TournamentDetailsDemo(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildDashboardCard(
                      'Tournaments',
                      '12',
                      Icons.sports_soccer,
                      const Color(0xFF3498DB),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TournamentsListPage(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      'Participants',
                      '245',
                      Icons.people,
                      const Color(0xFF2ECC71),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TournamentsListPage(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      'Active Matches',
                      '8',
                      Icons.sports_esports,
                      const Color(0xFFF39C12),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TournamentsListPage(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      'Demo Features',
                      'View',
                      Icons.visibility,
                      const Color(0xFF9B59B6),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TournamentDetailsDemo(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "tournament_list",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TournamentsListPage(),
              ),
            ),
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            child: const Icon(Icons.list),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "new_tournament",
            onPressed: _showAddTournamentDialog,
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('New Tournament'),
            elevation: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 6),
              FittedBox(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Color(0xFF7F8C8D)),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
    );
  }

  void _showAddTournamentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Dialog Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create New Tournament',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                // Tournament Form Content
                Expanded(
                  child: AddTournamentPage(
                    onTournamentCreated: (Tournament tournament) {
                      Navigator.of(context).pop(); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tournament "${tournament.name}" created successfully!',
                          ),
                          backgroundColor: const Color(0xFF2ECC71),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      // Optionally refresh dashboard data here
                      setState(() {
                        // You can update dashboard stats here if needed
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
