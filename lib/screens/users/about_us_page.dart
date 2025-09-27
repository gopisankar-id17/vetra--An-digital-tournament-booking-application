import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'About VETRA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(),
            
            // App Features
            _buildFeaturesSection(),
            
            // Mission & Vision
            _buildMissionVisionSection(),
            
            // Statistics
            _buildStatisticsSection(),
            
            // Team Section
            _buildTeamSection(),
            
            // Contact Section
            _buildContactSection(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // App Logo/Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_esports,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'VETRA',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Where Every Match Begins...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Your ultimate digital tournament booking platform that connects players, organizers, and sports enthusiasts in one seamless experience.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.calendar_today,
        'title': 'Easy Tournament Booking',
        'description': 'Browse and register for tournaments with just a few taps. Filter by sport, date, location, and skill level.',
        'color': Colors.blue,
      },
      {
        'icon': Icons.group,
        'title': 'Team Management',
        'description': 'Create teams, invite players, and manage your squad efficiently. Track team statistics and performance.',
        'color': Colors.green,
      },
      {
        'icon': Icons.leaderboard,
        'title': 'Live Leaderboards',
        'description': 'Real-time tournament standings, match results, and player statistics. Stay updated with live scores.',
        'color': Colors.orange,
      },
      {
        'icon': Icons.payment,
        'title': 'Secure Payments',
        'description': 'Safe and secure payment processing for tournament registrations. Multiple payment methods supported.',
        'color': Colors.purple,
      },
      {
        'icon': Icons.notifications_active,
        'title': 'Smart Notifications',
        'description': 'Get notified about upcoming matches, registration deadlines, and tournament updates.',
        'color': Colors.red,
      },
      {
        'icon': Icons.analytics,
        'title': 'Performance Analytics',
        'description': 'Detailed analytics of your tournament performance, win rates, and improvement suggestions.',
        'color': Colors.teal,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Features That Make Us Different',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Discover what makes VETRA the preferred choice for tournament enthusiasts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureCard(
                feature['icon'] as IconData,
                feature['title'] as String,
                feature['description'] as String,
                feature['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionVisionSection() {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryColor.withOpacity(0.05),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Our Mission & Vision',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: _buildMissionVisionCard(
                  'Mission',
                  'To democratize sports by making tournament participation accessible, enjoyable, and rewarding for everyone.',
                  Icons.flag,
                  AppTheme.primaryColor,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildMissionVisionCard(
                  'Vision',
                  'To become the global leader in digital sports tournament management and community building.',
                  Icons.visibility,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionVisionCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 40,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'VETRA by Numbers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('500+', 'Tournaments', Icons.emoji_events),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('10K+', 'Players', Icons.group),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard('25+', 'Sports', Icons.sports_soccer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('50+', 'Cities', Icons.location_city),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      width: double.infinity,
      color: Colors.grey[50],
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Meet Our Team',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildTeamCard('John Doe', 'Founder & CEO', 'Leading the vision for sports digitization'),
              _buildTeamCard('Jane Smith', 'CTO', 'Building cutting-edge tournament technology'),
              _buildTeamCard('Mike Johnson', 'Head of Sports', 'Ensuring authentic sports experience'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String name, String role, String description) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: Text(
              name.split(' ').map((e) => e[0]).join(''),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
            ),
          ),
          
          Text(
            role,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.textDarkColor,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Get In Touch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Contact Information
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactItem(Icons.email, 'hello@vetra.com'),
              _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
              _buildContactItem(Icons.language, 'www.vetra.com'),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Social Media Section
          const Text(
            'Follow Us',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialMediaButton(
                Icons.facebook,
                'Facebook',
                Colors.blue[700]!,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Visit us on Facebook: @VetraApp'),
                      backgroundColor: Colors.blue,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 16),
              
              _buildSocialMediaButton(
                Icons.camera_alt, // Instagram icon
                'Instagram',
                Colors.pink[400]!,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Follow us on Instagram: @VetraApp'),
                      backgroundColor: Colors.pink[400],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 16),
              
              _buildSocialMediaButton(
                Icons.business, // LinkedIn icon
                'LinkedIn',
                Colors.blue[800]!,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Connect with us on LinkedIn: VETRA'),
                      backgroundColor: Colors.blue[800],
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            '© 2025 VETRA. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaButton(
    IconData icon,
    String platform,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}