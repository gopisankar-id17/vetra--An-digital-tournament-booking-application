import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tournament.dart';
import '../services/participant_service.dart';

class RegistrationService {
  final ParticipantService _participantService = ParticipantService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register user for a tournament
  Future<String> registerForTournament({
    required String tournamentId,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      // Check if user is already registered
      final isRegistered = await _participantService.isUserRegistered(
        tournamentId,
        userId,
      );

      if (isRegistered) {
        throw Exception('User is already registered for this tournament');
      }

      // Check if tournament is full
      final tournament = await _getTournament(tournamentId);
      if (tournament == null) {
        throw Exception('Tournament not found');
      }

      final currentParticipants = await _participantService.getParticipantCount(
        tournamentId,
      );
      if (currentParticipants >= tournament.maxParticipants) {
        throw Exception('Tournament is full');
      }

      // Check if registration deadline has passed
      if (tournament.registrationDeadline != null &&
          DateTime.now().isAfter(tournament.registrationDeadline!)) {
        throw Exception('Registration deadline has passed');
      }

      // Register the participant
      final participantId = await _participantService.registerParticipant(
        tournamentId: tournamentId,
        userId: userId,
        name: userName,
        email: userEmail,
        phone: userPhone,
        additionalInfo: additionalInfo,
      );

      return participantId;
    } catch (e) {
      throw Exception('Failed to register for tournament: $e');
    }
  }

  // Get tournament details
  Future<Tournament?> _getTournament(String tournamentId) async {
    try {
      final doc = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
      return Tournament.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  // Unregister user from tournament
  Future<bool> unregisterFromTournament(
    String tournamentId,
    String userId,
  ) async {
    try {
      // Get participant by user ID
      final participant = await _participantService.getParticipantByUser(
        tournamentId,
        userId,
      );

      if (participant == null) {
        throw Exception('User is not registered for this tournament');
      }

      // Remove participant
      return await _participantService.removeParticipant(
        tournamentId,
        participant.id,
      );
    } catch (e) {
      throw Exception('Failed to unregister from tournament: $e');
    }
  }

  // Check if user can register for tournament
  Future<bool> canUserRegister(String tournamentId, String userId) async {
    try {
      // Check if already registered
      final isRegistered = await _participantService.isUserRegistered(
        tournamentId,
        userId,
      );

      if (isRegistered) {
        return false;
      }

      // Check tournament availability
      final tournament = await _getTournament(tournamentId);
      if (tournament == null) {
        return false;
      }

      // Check if tournament is full
      final currentParticipants = await _participantService.getParticipantCount(
        tournamentId,
      );
      if (currentParticipants >= tournament.maxParticipants) {
        return false;
      }

      // Check registration deadline
      if (tournament.registrationDeadline != null &&
          DateTime.now().isAfter(tournament.registrationDeadline!)) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user's tournament registrations
  Future<List<String>> getUserRegistrations(String userId) async {
    try {
      return await _participantService.getUserTournaments(userId);
    } catch (e) {
      return [];
    }
  }
}
