import 'package:flutter/material.dart';
import '../services/session_service.dart';

class SessionDebugHelper {
  // Debug all current sessions
  static Future<void> debugCurrentSessions() async {
    print('=== SESSION DEBUG INFO ===');

    // Check admin session
    final isAdminLoggedIn = await SessionService.isAdminLoggedIn();
    print('Admin logged in: $isAdminLoggedIn');
    if (isAdminLoggedIn) {
      final adminSession = await SessionService.getAdminSession();
      print('Admin session data: $adminSession');
    }

    // Check user session
    final isUserLoggedIn = await SessionService.isUserLoggedIn();
    print('User logged in: $isUserLoggedIn');
    if (isUserLoggedIn) {
      final userSession = await SessionService.getUserSession();
      print('User session data: $userSession');
    }

    // Check organizer session
    final isOrganizerLoggedIn = await SessionService.isOrganizerLoggedIn();
    print('Organizer logged in: $isOrganizerLoggedIn');
    if (isOrganizerLoggedIn) {
      final organizerSession = await SessionService.getOrganizerSession();
      print('Organizer session data: $organizerSession');
    }

    // Get logged in user type
    final userType = await SessionService.getLoggedInUserType();
    print('Current logged in user type: $userType');

    print('=== END SESSION DEBUG ===');
  }

  // Test session persistence
  static Future<void> testSessionPersistence() async {
    print('=== SESSION PERSISTENCE TEST ===');

    // Create test organizer session
    print('Creating test organizer session...');
    await SessionService.createOrganizerSession(
      organizerId: 'test_id',
      email: 'test@example.com',
      name: 'Test Organizer',
      organization: 'Test Organization',
    );

    // Check if it persists
    await debugCurrentSessions();

    // Clear session
    print('Clearing organizer session...');
    await SessionService.clearOrganizerSession();

    // Check if cleared
    await debugCurrentSessions();

    print('=== END SESSION PERSISTENCE TEST ===');
  }

  // Widget to display session debug info
  static Widget buildDebugWidget(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await debugCurrentSessions();
          },
          child: const Text('Debug Current Sessions'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            await testSessionPersistence();
          },
          child: const Text('Test Session Persistence'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            await SessionService.clearAllSessions();
            print('All sessions cleared');
          },
          child: const Text('Clear All Sessions'),
        ),
      ],
    );
  }

  // Show session debug dialog
  static void showSessionDebugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Debug'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [buildDebugWidget(context)],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
