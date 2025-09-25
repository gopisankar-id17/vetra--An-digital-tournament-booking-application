// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:async'; // for Timer
import 'screens/landing_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VETRA - Tournament Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // start with Splash
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String fullText = "Where every match begins...";
  String displayedText = "";
  int textIndex = 0;
  Timer? typingTimer;

  @override
  void initState() {
    super.initState();

    // Typing effect
    typingTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (textIndex < fullText.length) {
        setState(() {
          displayedText += fullText[textIndex];
          textIndex++;
        });
      } else {
        typingTimer?.cancel();
      }
    });

    // Navigate to LandingPage after 10 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    });
  }

  @override
  void dispose() {
    typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6f42c1), // theme color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Rounded Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(30), // round corners
              child: Image.asset(
                "assets/Vetra_logo.png",
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "VETRA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Typing animation text
            Text(
              displayedText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
