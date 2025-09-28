import 'package:flutter/material.dart';
import '../common/profile_customization_screen.dart';
import '../common/about_us_page.dart';
import '../../models/user.dart';
import '../../services/session_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Sample data for recent activities
  final List<Map<String, dynamic>> recentActivities = [
    {
      'title': 'Joined Chess Championship',
      'subtitle': 'Successfully registered for the tournament',
      'icon': Icons.sports_esports,
      'color': const Color(0xFF6f42c1),
      'timeAgo': '2 days ago',
    },
    {
      'title': 'Updated Profile',
      'subtitle': 'Changed profile information',
      'icon': Icons.person,
      'color': const Color(0xFF17a2b8),
      'timeAgo': '1 week ago',
    },
    {
      'title': 'Won 2nd Place',
      'subtitle': 'Junior Chess Championship',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFffc107),
      'timeAgo': '2 weeks ago',
    },
  ];

  // Sample data for achievements
  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'Tournament Winner',
      'subtitle': 'Won first place in a chess tournament',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFD54F), // Golden yellow
      'backgroundColor': const Color(0xFFFFF8E1), // Light yellow background
      'isUnlocked': true,
    },
    {
      'title': 'Active Participant',
      'subtitle': 'Participated in 10+ tournaments',
      'icon': Icons.directions_run,
      'color': const Color(0xFF42A5F5), // Light blue
      'backgroundColor': const Color(0xFFE3F2FD), // Light blue background
      'isUnlocked': true,
    },
    {
      'title': 'Rising Star',
      'subtitle': 'Achieve 5 consecutive wins',
      'icon': Icons.star,
      'color': Colors.grey,
      'backgroundColor': const Color(0xFFE0E0E0), // Light grey background
      'isUnlocked': false,
    },
    {
      'title': 'Social Player',
      'subtitle': 'Connect with 20+ players',
      'icon': Icons.people,
      'color': Colors.grey,
      'backgroundColor': const Color(0xFFE0E0E0), // Light grey background
      'isUnlocked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20), // Add gap between top bar and profile container
            // Profile Header Section with custom app bar
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9, // Reduced to 80% of screen width for more spacing
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF6f42c1), Color(0xFF8a63d2)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  child: Column(
                    children: [
                      // Custom App Bar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'My Profile',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              // Navigate to profile customization
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileCustomizationScreen(user: User.sampleUser()),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Profile Avatar and User Info - Dynamic from Session
                      FutureBuilder<Map<String, String?>>(
                        future: SessionService.getUserSession(),
                        builder: (context, snapshot) {
                          String userName = 'User';
                          String userInitials = 'U';
                          String phoneNumber = '';
                          
                          if (snapshot.hasData && snapshot.data != null) {
                            final sessionData = snapshot.data!;
                            userName = sessionData['name'] ?? 'User';
                            phoneNumber = sessionData['phone'] ?? '';
                            
                            // Generate initials from name
                            if (userName != 'User' && userName.isNotEmpty) {
                              List<String> nameParts = userName.split(' ');
                              if (nameParts.length >= 2) {
                                userInitials = '${nameParts[0][0]}${nameParts[1][0]}';
                              } else {
                                userInitials = userName.length >= 2 ? userName.substring(0, 2) : userName[0];
                              }
                              userInitials = userInitials.toUpperCase();
                            }
                          }
                          
                          return Column(
                            children: [
                              // Profile Avatar
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: const Color(0xFF7CB342),
                                  child: Text(
                                    userInitials,
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // User Name
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Phone Number
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    phoneNumber.isNotEmpty ? phoneNumber : 'No phone number',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
            const SizedBox(height: 30),
            
            // Recent Activity Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timeline,
                        color: Color(0xFF6f42c1),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Show all activities
                          _showAllActivities();
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF6f42c1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ...recentActivities.map((activity) => _buildActivityItem(activity)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Achievements Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Color(0xFFffc107),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.9, // Increased height to prevent overflow
                    ),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      return _buildAchievementCard(achievements[index]);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // About Us Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF6f42c1),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'About VETRA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // About Us Card
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutUsPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6f42c1), Color(0xFF8a63d2)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6f42c1).withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sports_esports,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Learn More About VETRA',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Discover our mission, features, and team',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Where Every Match Begins...',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatBadge('500+', 'Tournaments'),
                              _buildStatBadge('10K+', 'Players'),
                              _buildStatBadge('25+', 'Sports'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['subtitle'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          Text(
            activity['timeAgo'],
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFBDC3C7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    bool isUnlocked = achievement['isUnlocked'] as bool;
    Color cardColor = isUnlocked 
        ? (achievement['color'] as Color) 
        : Colors.grey.withOpacity(0.5);
    Color backgroundColor = isUnlocked 
        ? (achievement['backgroundColor'] as Color)
        : const Color(0xFFF5F5F5);
    
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked 
            ? Border.all(color: cardColor.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? cardColor.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to minimize space usage
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Reduced from 16 to 12
            decoration: BoxDecoration(
              color: isUnlocked ? cardColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement['icon'] as IconData,
              size: 28, // Reduced from 32 to 28
              color: cardColor,
            ),
          ),
          const SizedBox(height: 8), // Reduced from 12 to 8
          Text(
            achievement['title'],
            style: TextStyle(
              fontSize: 13, // Reduced from 14 to 13
              fontWeight: FontWeight.bold,
              color: isUnlocked ? const Color(0xFF2C3E50) : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4), // Reduced from 6 to 4
          Text(
            achievement['subtitle'],
            style: TextStyle(
              fontSize: 10, // Reduced from 11 to 10
              color: isUnlocked ? const Color(0xFF7F8C8D) : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (!isUnlocked) ...[
            const SizedBox(height: 6), // Reduced from 8 to 6
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6), // Reduced radius
              ),
              child: const Text(
                'LOCKED',
                style: TextStyle(
                  fontSize: 7, // Reduced from 8 to 7
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAllActivities() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'All Activities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: recentActivities.length * 2, // Show more activities
                      itemBuilder: (context, index) {
                        int actualIndex = index % recentActivities.length;
                        return _buildActivityItem(recentActivities[actualIndex]);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatBadge(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}