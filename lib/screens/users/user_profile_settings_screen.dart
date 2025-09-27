import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';

class UserProfileSettingsScreen extends StatefulWidget {
  final User user;

  const UserProfileSettingsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserProfileSettingsScreen> createState() => _UserProfileSettingsScreenState();
}

class _UserProfileSettingsScreenState extends State<UserProfileSettingsScreen> {
  late User _user;
  
  // Privacy Settings
  bool _profileVisible = true;
  bool _statsVisible = true;
  bool _activityVisible = false;
  bool _contactInfoVisible = true;
  
  // Notification Settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _tournamentReminders = true;
  bool _bookingConfirmations = true;
  bool _marketingEmails = false;
  bool _weeklyDigest = true;
  
  // Account Settings
  bool _twoFactorAuth = false;
  bool _loginNotifications = true;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(color: AppTheme.textDarkColor),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDarkColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 24),
            _buildPrivacySettings(),
            const SizedBox(height: 24),
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildAccountSettings(),
            const SizedBox(height: 24),
            _buildDangerZone(),
            const SizedBox(height: 100), // Extra space for bottom
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveSettings,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save Settings',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
              image: _user.photoUrl != null
                  ? DecorationImage(
                      image: NetworkImage(_user.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _user.photoUrl == null
                ? const Icon(
                    Icons.person,
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
                Text(
                  _user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
                Text(
                  _user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMediumColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _user.isAdmin ? 'Administrator' : 'Tournament Participant',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySettings() {
    return _buildSection(
      'Privacy Settings',
      Icons.privacy_tip_outlined,
      [
        _buildSwitchTile(
          'Public Profile',
          'Allow others to view your profile',
          _profileVisible,
          (value) => setState(() => _profileVisible = value),
        ),
        _buildSwitchTile(
          'Show Statistics',
          'Display your tournament statistics to others',
          _statsVisible,
          (value) => setState(() => _statsVisible = value),
        ),
        _buildSwitchTile(
          'Activity Visibility',
          'Show your recent tournament activity',
          _activityVisible,
          (value) => setState(() => _activityVisible = value),
        ),
        _buildSwitchTile(
          'Contact Information',
          'Allow others to see your contact details',
          _contactInfoVisible,
          (value) => setState(() => _contactInfoVisible = value),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSection(
      'Notification Preferences',
      Icons.notifications_outlined,
      [
        _buildSwitchTile(
          'Email Notifications',
          'Receive updates via email',
          _emailNotifications,
          (value) => setState(() => _emailNotifications = value),
        ),
        _buildSwitchTile(
          'Push Notifications',
          'Get instant notifications on your device',
          _pushNotifications,
          (value) => setState(() => _pushNotifications = value),
        ),
        _buildSwitchTile(
          'Tournament Reminders',
          'Get reminded about upcoming tournaments',
          _tournamentReminders,
          (value) => setState(() => _tournamentReminders = value),
        ),
        _buildSwitchTile(
          'Booking Confirmations',
          'Receive confirmations for your bookings',
          _bookingConfirmations,
          (value) => setState(() => _bookingConfirmations = value),
        ),
        _buildSwitchTile(
          'Marketing Emails',
          'Get promotional offers and updates',
          _marketingEmails,
          (value) => setState(() => _marketingEmails = value),
        ),
        _buildSwitchTile(
          'Weekly Digest',
          'Receive weekly summary of activities',
          _weeklyDigest,
          (value) => setState(() => _weeklyDigest = value),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return _buildSection(
      'Account Security',
      Icons.security_outlined,
      [
        _buildSwitchTile(
          'Two-Factor Authentication',
          'Add extra security to your account',
          _twoFactorAuth,
          (value) => setState(() => _twoFactorAuth = value),
        ),
        _buildSwitchTile(
          'Login Notifications',
          'Get notified when someone logs into your account',
          _loginNotifications,
          (value) => setState(() => _loginNotifications = value),
        ),
        _buildListTile(
          'Change Password',
          'Update your account password',
          Icons.lock_outline,
          () => _showChangePasswordDialog(),
        ),
        _buildListTile(
          'Download Data',
          'Export your tournament and booking data',
          Icons.download_outlined,
          () => _showDataExportDialog(),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.red.shade600),
              const SizedBox(width: 12),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDangerButton(
            'Deactivate Account',
            'Temporarily disable your account',
            Icons.pause_circle_outline,
            () => _showDeactivateDialog(),
          ),
          const SizedBox(height: 12),
          _buildDangerButton(
            'Delete Account',
            'Permanently delete your account and data',
            Icons.delete_forever_outlined,
            () => _showDeleteAccountDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDarkColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textDarkColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textMediumColor,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textDarkColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textMediumColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDangerButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.red.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red.shade600),
          ],
        ),
      ),
    );
  }

  void _saveSettings() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate saving
    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pop(); // Close loading dialog

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle password change
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showDataExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'We\'ll prepare your data export and send it to your email address. This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export initiated. Check your email shortly.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export Data'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your account? You can reactivate it by logging in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivated. You can reactivate by logging in.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: Colors.red.shade700),
        ),
        content: const Text(
          'This action cannot be undone. All your data, including tournaments, bookings, and profile information will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account deletion cancelled for demo purposes.'),
                  backgroundColor: Colors.red.shade600,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}