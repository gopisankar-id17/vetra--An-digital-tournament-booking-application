import 'package:flutter/material.dart';
import 'session_service.dart';
import '../screens/landing_page.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/users/user_dashboard_page.dart';

class RouteGuard {
  static Future<Widget> getInitialRoute() async {
    try {
      // Check if admin is logged in
      final isAdminLoggedIn = await SessionService.isAdminLoggedIn();
      if (isAdminLoggedIn) {
        final adminSession = await SessionService.getAdminSession();
        print('RouteGuard: Admin session found for ${adminSession['email']}');
        return const AdminDashboardScreen();
      }

      // Check if user is logged in
      final isUserLoggedIn = await SessionService.isUserLoggedIn();
      if (isUserLoggedIn) {
        final userSession = await SessionService.getUserSession();
        print('RouteGuard: User session found for ${userSession['phone']}');
        return const UserDashboardPage();
      }

      // No active sessions, go to landing page
      print('RouteGuard: No active sessions, showing landing page');
      return const LandingPage();
    } catch (e) {
      print('RouteGuard: Error checking sessions: $e');
      return const LandingPage();
    }
  }

  static Future<bool> requireAdminAuth() async {
    return await SessionService.isAdminLoggedIn();
  }

  static Future<bool> requireUserAuth() async {
    return await SessionService.isUserLoggedIn();
  }

  static Future<String> getCurrentUserType() async {
    final isAdmin = await SessionService.isAdminLoggedIn();
    final isUser = await SessionService.isUserLoggedIn();
    
    if (isAdmin) return 'admin';
    if (isUser) return 'user';
    return 'guest';
  }
}
