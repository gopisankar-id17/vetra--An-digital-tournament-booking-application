import 'package:flutter/material.dart';
import 'admin/admin_login_page.dart';
import 'users/user_login_page.dart';
import 'users/user_signup_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Define a max width for consistent card sizing
  static const double _cardMaxWidth = 350.0;
  // Define a consistent padding for the cards
  static const EdgeInsets _cardPadding = EdgeInsets.all(30);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        // New Purple gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A), // Medium Purple
              Color(0xFF4A148C), // Deep Purple
              Color(0xFF311B92), // Deeper Indigo/Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Header Section (Now at the top)
                _buildHeader(),
                const SizedBox(height: 80), // Increased spacing to bring cards down
                // Options Section
                Column(
                  children: [
                    _buildAdminCard(context),
                    const SizedBox(height: 20),
                    _buildVisitorCard(context),
                  ],
                ),
                const Spacer(), // Pushes the following element (Footer) to the bottom
                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Image.asset(
            'assets/Vetra_logo.png',
            fit: BoxFit.contain,
            // Fallback in case the asset is missing
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.sports_soccer, // Placeholder for the logo
                size: 60,
                color: Color(0xFF6f42c1),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Digital Tournament Booking Platform',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

Widget _buildAdminCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
      child: Card(
        elevation: 25,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
          ),
          padding: _cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and text in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6f42c1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/Vetra_logo.png',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.admin_panel_settings,
                          size: 26,
                          color: Color(0xFF6f42c1),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                // height: 48, // REMOVED fixed height
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminLoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6f42c1),
                    foregroundColor: Colors.white,
                    // ADDED padding for consistent height
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 12,
                  ),
                  child: const Text(
                    'Admin Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
      child: Card(
        elevation: 25,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
          ),
          padding: _cardPadding,
          child: Column(
            children: [
              // Icon and text in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6f42c1).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 25,
                      color: Color(0xFF6f42c1),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Text(
                    'Visitor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Replace to UserLoginPage
                        Navigator.push( // 👈 CHANGE HERE
  context,
  MaterialPageRoute(
    builder: (context) => const UserLoginPage(),
  ),
);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6f42c1),
                        side: const BorderSide(
                          color: Color(0xFF6f42c1),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Replace to UserSignupPage
                        Navigator.push( // 👈 CHANGE HERE
  context,
  MaterialPageRoute(
    builder: (context) => const UserSignupPage(),
  ),
);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6f42c1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 12,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      'Choose your role to get started',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}