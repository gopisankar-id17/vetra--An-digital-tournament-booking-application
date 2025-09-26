import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_theme.dart';
import 'landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LandingPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value * 0.3, // Subtle rotation
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/Vetra_logo.png',
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: AppTheme.primary,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // App name with fade animation
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
                    ),
                  ),
                  child: const Text(
                    'VETRA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline with delayed fade
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
                    ),
                  ),
                  child: const Text(
                    'Tournament Booking Platform',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // Loading indicator with delayed animation
                FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                    ),
                  ),
                  child: _buildLoadingIndicator(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withOpacity(0.8),
            ),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressText(),
      ],
    );
  }

  Widget _buildProgressText() {
    // Text that changes during the animation
    final List<String> loadingTexts = [
      'Initializing...',
      'Loading tournaments...',
      'Almost there...',
    ];

    // Use a tween sequence for progress text
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        String text = '';
        double progress = _animationController.value;

        if (progress < 0.3) {
          text = loadingTexts[0];
        } else if (progress < 0.7) {
          text = loadingTexts[1];
        } else {
          text = loadingTexts[2];
        }

        return Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        );
      },
    );
  }
}
