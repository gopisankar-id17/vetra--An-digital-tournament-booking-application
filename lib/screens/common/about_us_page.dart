import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6f42c1), Color(0xFF8a63d2)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      // App Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          size: 50,
                          color: Color(0xFF6f42c1),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // App Name
                      const Text(
                        'VETRA',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Tagline
                      const Text(
                        'Where Every Match Begins...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Description
                      const Text(
                        'Your ultimate digital tournament booking platform that connects players, organizers, and sports enthusiasts in one seamless experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Features That Make Us Different',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Discover what makes VETRA the preferred choice for tournament enthusiasts',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Features Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.0,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.event_available,
                        iconColor: Colors.blue,
                        iconBgColor: Colors.blue.shade50,
                        title: 'Easy Tournament\nBooking',
                        description: 'Simple and quick tournament registration process',
                      ),
                      _buildFeatureCard(
                        icon: Icons.people,
                        iconColor: Colors.green,
                        iconBgColor: Colors.green.shade50,
                        title: 'Team Management',
                        description: 'Efficient team formation and management tools',
                      ),
                      _buildFeatureCard(
                        icon: Icons.bar_chart,
                        iconColor: Colors.orange,
                        iconBgColor: Colors.orange.shade50,
                        title: 'Live Leaderboards',
                        description: 'Real-time tournament standings, match results, and player statistics. Stay updated with live scores.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.payment,
                        iconColor: const Color(0xFF6f42c1),
                        iconBgColor: const Color(0xFF6f42c1).withOpacity(0.1),
                        title: 'Secure Payments',
                        description: 'Safe and secure payment processing for tournament registrations. Multiple payment methods supported.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.notifications_active,
                        iconColor: Colors.red,
                        iconBgColor: Colors.red.shade50,
                        title: 'Smart Notifications',
                        description: 'Get notified about upcoming matches, registration deadlines, and tournament updates.',
                      ),
                      _buildFeatureCard(
                        icon: Icons.analytics,
                        iconColor: Colors.teal,
                        iconBgColor: Colors.teal.shade50,
                        title: 'Performance Analytics',
                        description: 'Detailed analytics of your tournament performance, win rates, and improvement suggestions.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Mission & Vision Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    'Our Mission & Vision',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'To revolutionize the sports tournament experience by providing a comprehensive platform that brings together players, organizers, and fans in a digital ecosystem that promotes fair play, competition, and community building.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'VETRA by Numbers',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.4, // Increased from 1.8 to 1.4 to give more height
                    children: [
                      _buildStatCard(
                        icon: Icons.emoji_events,
                        number: '500+',
                        label: 'Tournaments',
                      ),
                      _buildStatCard(
                        icon: Icons.people,
                        number: '10K+',
                        label: 'Players',
                      ),
                      _buildStatCard(
                        icon: Icons.sports_soccer,
                        number: '25+',
                        label: 'Sports',
                      ),
                      _buildStatCard(
                        icon: Icons.location_city,
                        number: '50+',
                        label: 'Cities',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Team Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    'Meet Our Team',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Team Members
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamMember(
                          initials: 'JD',
                          name: 'John Doe',
                          position: 'Founder & CEO',
                          description: 'Leading the vision for sports digitization',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildTeamMember(
                          initials: 'JS',
                          name: 'Jane Smith',
                          position: 'CTO',
                          description: 'Building cutting-edge tournament technology',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Third team member (centered)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: _buildTeamMember(
                      initials: 'MJ',
                      name: 'Mike Johnson',
                      position: 'Head of Sports',
                      description: 'Ensuring authentic sports experience',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Contact Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                ),
              ),
              padding: const EdgeInsets.all(30),
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
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactItem(
                        icon: Icons.email,
                        text: 'hello@vetra.com',
                        iconColor: Colors.blue,
                      ),
                      _buildContactItem(
                        icon: Icons.phone,
                        text: '+1 (555) 123-4567',
                        iconColor: Colors.green,
                      ),
                      _buildContactItem(
                        icon: Icons.web,
                        text: 'www.vetra.com',
                        iconColor: Colors.orange,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  const Text(
                    'Follow Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 15),
                      _buildSocialButton(
                        icon: Icons.camera_alt,
                        color: Colors.pink,
                      ),
                      const SizedBox(width: 15),
                      _buildSocialButton(
                        icon: Icons.business,
                        color: Colors.blue.shade800,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    '© 2025 VETRA. All rights reserved.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String number,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6f42c1), Color(0xFF8a63d2)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Added to minimize space usage
        children: [
          Icon(
            icon,
            size: 36, // Reduced from 40 to 36
            color: Colors.white,
          ),
          const SizedBox(height: 8), // Reduced from 10 to 8
          Text(
            number,
            style: const TextStyle(
              fontSize: 28, // Reduced from 32 to 28
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2), // Added small spacing
          Text(
            label,
            style: const TextStyle(
              fontSize: 14, // Reduced from 16 to 14
              color: Colors.white70,
            ),
            textAlign: TextAlign.center, // Added to center the text
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String initials,
    required String name,
    required String position,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF6f42c1),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            position,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6f42c1),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}