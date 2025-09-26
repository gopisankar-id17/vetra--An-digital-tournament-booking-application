import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final VoidCallback? onEdit;

  const ProfileCard({super.key, required this.user, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile header
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Background design
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        user.isAdmin
                            ? AppTheme.primaryColor
                            : AppTheme.secondaryColor,
                        user.isAdmin
                            ? AppTheme.primaryDarkColor
                            : AppTheme.secondaryDarkColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // Edit button
                if (onEdit != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: onEdit,
                      tooltip: 'Edit Profile',
                    ),
                  ),

                // Profile image
                Positioned(
                  bottom: -50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(
                          user.photoUrl ??
                              'https://ui-avatars.com/api/?name=${user.name.replaceAll(' ', '+')}&background=random',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Space for the overlapping profile picture
            const SizedBox(height: 60),

            // User name
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDarkColor,
              ),
            ),

            const SizedBox(height: 4),

            // User role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.isAdmin
                    ? AppTheme.primaryLightColor.withOpacity(0.2)
                    : AppTheme.secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.isAdmin ? 'Administrator' : 'Tournament Visitor',
                style: TextStyle(
                  color: user.isAdmin
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Contact information
            _buildInfoRow(Icons.email, user.email),

            if (user.phone != null) _buildInfoRow(Icons.phone, user.phone!),

            if (user.address != null)
              _buildInfoRow(Icons.location_on, user.address!),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: user.isAdmin
                ? AppTheme.primaryColor
                : AppTheme.secondaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textDarkColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
