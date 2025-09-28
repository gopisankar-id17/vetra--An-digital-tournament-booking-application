import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participant.dart';

class ParticipantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _participantsCollection =>
      _firestore.collection('participants');

  // Register a participant for a tournament
  Future<String> registerParticipant({
    required String tournamentId,
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? profileImageUrl,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final participantId = DateTime.now().millisecondsSinceEpoch.toString();

      final participant = Participant(
        id: participantId,
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
        registrationDate: DateTime.now(),
        status: ParticipantStatus.approved, // Auto-approve for now
        additionalInfo: additionalInfo,
      );

      await _participantsCollection
          .doc(tournamentId)
          .collection('participants')
          .doc(participantId)
          .set(participant.toMap());

      // Update tournament participant count
      await _updateTournamentParticipantCount(tournamentId);

      return participantId;
    } catch (e) {
      throw Exception('Failed to register participant: $e');
    }
  }

  // Get participants for a tournament with real-time updates
  Stream<List<Participant>> getParticipantsStream(String tournamentId) {
    return _participantsCollection
        .doc(tournamentId)
        .collection('participants')
        .orderBy('registrationDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Participant.fromMap(data);
          }).toList();
        });
  }

  // Get participants for a tournament (one-time fetch)
  Future<List<Participant>> getParticipants(String tournamentId) async {
    try {
      final snapshot = await _participantsCollection
          .doc(tournamentId)
          .collection('participants')
          .orderBy('registrationDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Participant.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get participants: $e');
    }
  }

  // Get participant count for a tournament
  Future<int> getParticipantCount(String tournamentId) async {
    try {
      final snapshot = await _participantsCollection
          .doc(tournamentId)
          .collection('participants')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get participant count: $e');
    }
  }

  // Remove a participant from tournament
  Future<bool> removeParticipant(
    String tournamentId,
    String participantId,
  ) async {
    try {
      await _participantsCollection
          .doc(tournamentId)
          .collection('participants')
          .doc(participantId)
          .delete();

      // Update tournament participant count
      await _updateTournamentParticipantCount(tournamentId);

      return true;
    } catch (e) {
      throw Exception('Failed to remove participant: $e');
    }
  }

  // Update participant status
  Future<bool> updateParticipantStatus(
    String tournamentId,
    String participantId,
    ParticipantStatus status, {
    String? rejectionReason,
  }) async {
    try {
      final updateData = <String, dynamic>{'status': status.name};

      if (rejectionReason != null) {
        updateData['rejectionReason'] = rejectionReason;
      }

      await _participantsCollection
          .doc(tournamentId)
          .collection('participants')
          .doc(participantId)
          .update(updateData);

      return true;
    } catch (e) {
      throw Exception('Failed to update participant status: $e');
    }
  }

  // Check if user is already registered for a tournament
  Future<bool> isUserRegistered(String tournamentId, String userId) async {
    try {
      final snapshot = await _participantsCollection
          .doc(tournamentId)
          .collection('participants')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check user registration: $e');
    }
  }

  // Get user's tournament participations
  Future<List<String>> getUserTournaments(String userId) async {
    try {
      final tournaments = <String>[];

      // Get all tournament documents
      final tournamentsSnapshot = await _firestore
          .collection('tournaments')
          .get();

      for (final tournamentDoc in tournamentsSnapshot.docs) {
        final participantsSnapshot = await _participantsCollection
            .doc(tournamentDoc.id)
            .collection('participants')
            .where('userId', isEqualTo: userId)
            .get();

        if (participantsSnapshot.docs.isNotEmpty) {
          tournaments.add(tournamentDoc.id);
        }
      }

      return tournaments;
    } catch (e) {
      throw Exception('Failed to get user tournaments: $e');
    }
  }

  // Private method to update tournament participant count
  Future<void> _updateTournamentParticipantCount(String tournamentId) async {
    try {
      final count = await getParticipantCount(tournamentId);

      await _firestore.collection('tournaments').doc(tournamentId).update({
        'currentParticipants': count,
        'participantsCount': count,
      });
    } catch (e) {
      // Don't throw error for count update failure
    }
  }

  // Get participant details by user and tournament
  Future<Participant?> getParticipantByUser(
    String tournamentId,
    String userId,
  ) async {
    try {
      final snapshot = await _participantsCollection
          .doc(tournamentId)
          .collection('participants')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return Participant.fromMap(data);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get participant: $e');
    }
  }

  // Send notification to all participants
  Future<bool> notifyAllParticipants(
    String tournamentId,
    String title,
    String message,
  ) async {
    try {
      // This would integrate with a notification service
      // For now, just return true as a placeholder
      return true;
    } catch (e) {
      throw Exception('Failed to send notifications: $e');
    }
  }

  // Export participants list (returns list for CSV/PDF generation)
  Future<List<Map<String, dynamic>>> exportParticipantsList(
    String tournamentId,
  ) async {
    try {
      final participants = await getParticipants(tournamentId);

      return participants
          .map(
            (participant) => {
              'Name': participant.name,
              'Email': participant.email,
              'Phone': participant.phone ?? 'N/A',
              'Registration Date': participant.registrationDate.toString(),
              'Status': participant.status.name,
            },
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to export participants: $e');
    }
  }
}
