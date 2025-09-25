// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/users/user_dashboard_screen.dart';
import 'utils/app_theme.dart';

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
      theme: AppTheme.getTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/user': (context) => const UserDashboardScreen(),
      },
    );
  }
}
