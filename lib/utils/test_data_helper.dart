import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/participant_service.dart';

class TestDataHelper {
  static final ParticipantService _participantService = ParticipantService();

  // Add some test participants for a tournament
  static Future<void> addTestParticipants(String tournamentId) async {
    try {
      // Add test participant 1
      await _participantService.registerParticipant(
        tournamentId: tournamentId,
        userId: 'user1',
        name: 'John Doe',
        email: 'john.doe@example.com',
        phone: '+1234567890',
      );

      // Add test participant 2
      await _participantService.registerParticipant(
        tournamentId: tournamentId,
        userId: 'user2',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phone: '+1234567891',
      );

      // Add test participant 3
      await _participantService.registerParticipant(
        tournamentId: tournamentId,
        userId: 'user3',
        name: 'Mike Johnson',
        email: 'mike.johnson@example.com',
        phone: '+1234567892',
      );

      print('Test participants added successfully');
    } catch (e) {
      print('Error adding test participants: $e');
    }
  }

  // Check if participants exist for a tournament
  static Future<void> checkParticipants(String tournamentId) async {
    try {
      final participants = await _participantService.getParticipants(
        tournamentId,
      );
      print(
        'Found ${participants.length} participants for tournament $tournamentId',
      );

      for (var participant in participants) {
        print('- ${participant.name} (${participant.email})');
      }
    } catch (e) {
      print('Error checking participants: $e');
    }
  }

  // Check Firestore structure directly
  static Future<void> checkFirestoreStructure(String tournamentId) async {
    try {
      print('=== FIRESTORE STRUCTURE CHECK ===');
      print('Tournament ID: $tournamentId');

      // Check if tournament document exists
      final tournamentDoc = await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentId)
          .get();

      if (!tournamentDoc.exists) {
        print('❌ Tournament document does NOT exist!');
        return;
      }

      print('✅ Tournament document exists');
      final tournamentData = tournamentDoc.data();
      print(
        'Tournament currentParticipants: ${tournamentData?['currentParticipants'] ?? 'null'}',
      );
      print(
        'Tournament participantsCount: ${tournamentData?['participantsCount'] ?? 'null'}',
      );

      // Check participants collection
      final snapshot = await FirebaseFirestore.instance
          .collection('participants')
          .doc(tournamentId)
          .collection('participants')
          .get();

      print('Firestore check: Found ${snapshot.docs.length} documents');
      print('Collection path: participants/$tournamentId/participants');

      for (var doc in snapshot.docs) {
        print('Document ID: ${doc.id}');
        final data = doc.data();
        print('  - Name: ${data['name'] ?? 'null'}');
        print('  - Email: ${data['email'] ?? 'null'}');
        print('  - UserId: ${data['userId'] ?? 'null'}');
        print('  - Status: ${data['status'] ?? 'null'}');
        print('  ---');
      }

      // Check if there are participants in other potential locations
      print('Checking alternative participant locations...');

      // Check tournaments/{tournamentId}/participants (alternative path)
      try {
        final altSnapshot = await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tournamentId)
            .collection('participants')
            .get();
        print(
          'Alternative path tournaments/$tournamentId/participants: ${altSnapshot.docs.length} documents',
        );
      } catch (e) {
        print('Alternative path check failed: $e');
      }

      print('=== END FIRESTORE CHECK ===');
    } catch (e) {
      print('Error checking Firestore structure: $e');
    }
  }
}
