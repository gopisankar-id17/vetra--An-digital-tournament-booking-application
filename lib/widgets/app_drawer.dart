import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';
import '../auth_service.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.user,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    // Common drawer items for both users and admins
                    _buildDrawerItem(
                      context,
                      index: 0,
                      title: 'Dashboard',
                      icon: Icons.dashboard,
                    ),

                    _buildDrawerItem(
                      context,
                      index: 1,
                      title: 'Tournaments',
                      icon: Icons.emoji_events,
                    ),

                    _buildDrawerItem(
                      context,
                      index: 2,
                      title: 'Bookings',
                      icon: Icons.calendar_today,
                    ),

                    _buildDrawerItem(
                      context,
                      index: 3,
                      title: 'Notifications',
                      icon: Icons.notifications,
                    ),

                    // Admin-only drawer items
                    if (user.isAdmin) ...[
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'ADMIN',
                          style: TextStyle(
                            color: AppTheme.textLightColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      _buildDrawerItem(
                        context,
                        index: 4,
                        title: 'Manage Users',
                        icon: Icons.people,
                      ),

                      _buildDrawerItem(
                        context,
                        index: 5,
                        title: 'Analytics',
                        icon: Icons.bar_chart,
                      ),

                      _buildDrawerItem(
                        context,
                        index: 6,
                        title: 'Reports',
                        icon: Icons.summarize,
                      ),
                    ],

                    const Divider(),

                    _buildDrawerItem(
                      context,
                      index: 7,
                      title: 'Profile',
                      icon: Icons.account_circle,
                    ),

                    _buildDrawerItem(
                      context,
                      index: 8,
                      title: 'Settings',
                      icon: Icons.settings,
                    ),
                  ],
                ),
              ),
            ),
          ),

          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  image: DecorationImage(
                    image: NetworkImage(
                      user.photoUrl ??
                          'https://ui-avatars.com/api/?name=${user.name.replaceAll(' ', '+')}&background=random',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: user.isAdmin
                  ? AppTheme.primaryLightColor
                  : AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.isAdmin ? 'Admin' : 'User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textMediumColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textDarkColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: () {
        onItemSelected(index);
        // Close drawer on mobile
        if (Scaffold.of(context).hasDrawer) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout Confirmation'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          print('AppDrawer: Logout button pressed');
                          print('AppDrawer: User isAdmin: ${user.isAdmin}');
                          Navigator.pop(context); // Close dialog first
                          
                          // Clear appropriate session based on user type
                          final authService = AuthService();
                          if (user.isAdmin) {
                            print('AppDrawer: Calling logoutAdmin');
                            await authService.logoutAdmin();
                          } else {
                            print('AppDrawer: Calling logoutUser');
                            await authService.logoutUser();
                          }
                          
                          print('AppDrawer: Navigating to landing page');
                          // Navigate to landing page
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
