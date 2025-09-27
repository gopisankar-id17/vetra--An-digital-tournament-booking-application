import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tournament.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection reference for tournaments
  CollectionReference get _tournamentsCollection =>
      _firestore.collection('tournaments');

  // Create a new tournament
  Future<String> createTournament({
    required Tournament tournament,
    XFile? imageFile,
  }) async {
    try {
      // Upload image to Firebase Storage if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadTournamentImage(tournament.id, imageFile);
      } else if (tournament.imageUrl != null &&
          tournament.imageUrl!.isNotEmpty) {
        // Use provided URL if no file is uploaded
        imageUrl = tournament.imageUrl;
      }

      // Create tournament data map
      final tournamentData = _tournamentToMap(tournament, imageUrl);

      // Add tournament to Firestore
      await _tournamentsCollection.doc(tournament.id).set(tournamentData);

      return tournament.id;
    } catch (e) {
      throw Exception('Failed to create tournament: $e');
    }
  }

  // Upload tournament image to Firebase Storage
  Future<String> _uploadTournamentImage(
    String tournamentId,
    XFile imageFile,
  ) async {
    try {
      // Create a unique filename
      final fileName =
          'tournament_${tournamentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Create storage reference
      final storageRef = _storage.ref().child('tournaments').child(fileName);

      // Upload file
      final uploadTask = storageRef.putFile(File(imageFile.path));

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Convert Tournament object to Firestore map
  Map<String, dynamic> _tournamentToMap(
    Tournament tournament,
    String? imageUrl,
  ) {
    return {
      'id': tournament.id,
      'name': tournament.name,
      'description': tournament.description,
      'startDate': Timestamp.fromDate(tournament.startDate),
      'endDate': Timestamp.fromDate(tournament.endDate),
      'registrationDeadline': tournament.registrationDeadline != null
          ? Timestamp.fromDate(tournament.registrationDeadline!)
          : null,
      'location': tournament.location,
      'organizer': tournament.organizer,
      'organizerId': tournament.organizerId, // Add organizerId field
      'organizerName': tournament.organizerName, // Add organizerName field
      'imageUrl': imageUrl,
      'maxParticipants': tournament.maxParticipants,
      'currentParticipants': tournament.currentParticipants,
      'entryFee': tournament.entryFee,
      'status': tournament.status.name,
      'categories': tournament.categories,
      'format': tournament.format.name,
      'mode': tournament.mode.name,
      'rules': tournament.rules,
      'prizes': tournament.prizes,
      'contactInfo': tournament.contactInfo,
      'ticketTypes': tournament.ticketTypes,
      'participantsCount': tournament.participantsCount,
      'prizePool': tournament.prizePool,
      'organizerPhotoUrl': tournament.organizerPhotoUrl,
      'organizerPastTournaments': tournament.organizerPastTournaments,
      'startTime': tournament.startTime,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // Get all tournaments
  Future<List<Tournament>> getAllTournaments() async {
    try {
      final querySnapshot = await _tournamentsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => _mapToTournament(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tournaments: $e');
    }
  }

  // Get tournament by ID
  Future<Tournament?> getTournamentById(String id) async {
    try {
      final doc = await _tournamentsCollection.doc(id).get();

      if (doc.exists) {
        return _mapToTournament(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tournament: $e');
    }
  }

  // Update tournament
  Future<void> updateTournament(Tournament tournament) async {
    try {
      final tournamentData = _tournamentToMap(tournament, tournament.imageUrl);
      tournamentData['updatedAt'] = Timestamp.now();

      await _tournamentsCollection.doc(tournament.id).update(tournamentData);
    } catch (e) {
      throw Exception('Failed to update tournament: $e');
    }
  }

  // Delete tournament
  Future<void> deleteTournament(String id) async {
    try {
      await _tournamentsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete tournament: $e');
    }
  }

  // Get tournaments by status
  Future<List<Tournament>> getTournamentsByStatus(
    TournamentStatus status,
  ) async {
    try {
      final querySnapshot = await _tournamentsCollection
          .where('status', isEqualTo: status.name)
          .orderBy('startDate')
          .get();

      return querySnapshot.docs
          .map((doc) => _mapToTournament(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tournaments by status: $e');
    }
  }

  // Get tournaments by category
  Future<List<Tournament>> getTournamentsByCategory(String category) async {
    try {
      final querySnapshot = await _tournamentsCollection
          .where('categories', arrayContains: category)
          .orderBy('startDate')
          .get();

      return querySnapshot.docs
          .map((doc) => _mapToTournament(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tournaments by category: $e');
    }
  }

  // Convert Firestore map to Tournament object
  Tournament _mapToTournament(Map<String, dynamic> data) {
    return Tournament(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      registrationDeadline: data['registrationDeadline'] != null
          ? (data['registrationDeadline'] as Timestamp).toDate()
          : null,
      location: data['location'] ?? '',
      organizer: data['organizer'] ?? '',
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      imageUrl: data['imageUrl'],
      maxParticipants: data['maxParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      entryFee: (data['entryFee'] ?? 0).toDouble(),
      status: _parseStatus(data['status']),
      categories: List<String>.from(data['categories'] ?? []),
      format: _parseFormat(data['format']),
      mode: _parseMode(data['mode']),
      rules: data['rules'],
      prizes: data['prizes'],
      contactInfo: data['contactInfo'],
      ticketTypes: Map<String, double>.from(data['ticketTypes'] ?? {}),
      participantsCount: data['participantsCount'] ?? 0,
      prizePool: (data['prizePool'] ?? 0.0).toDouble(),
      organizerPhotoUrl: data['organizerPhotoUrl'] ?? '',
      organizerPastTournaments: data['organizerPastTournaments'] ?? 0,
      startTime: data['startTime'] ?? '',
    );
  }

  // Parse tournament status from string
  TournamentStatus _parseStatus(String? status) {
    switch (status) {
      case 'upcoming':
        return TournamentStatus.upcoming;
      case 'ongoing':
        return TournamentStatus.ongoing;
      case 'completed':
        return TournamentStatus.completed;
      case 'cancelled':
        return TournamentStatus.cancelled;
      default:
        return TournamentStatus.upcoming;
    }
  }

  // Parse tournament format from string
  TournamentFormat _parseFormat(String? format) {
    switch (format) {
      case 'singleElimination':
        return TournamentFormat.singleElimination;
      case 'doubleElimination':
        return TournamentFormat.doubleElimination;
      case 'roundRobin':
        return TournamentFormat.roundRobin;
      case 'swiss':
        return TournamentFormat.swiss;
      default:
        return TournamentFormat.singleElimination;
    }
  }

  // Parse tournament mode from string
  TournamentMode _parseMode(String? mode) {
    switch (mode) {
      case 'online':
        return TournamentMode.online;
      case 'offline':
        return TournamentMode.offline;
      case 'hybrid':
        return TournamentMode.hybrid;
      default:
        return TournamentMode.online;
    }
  }

  // Stream tournaments (real-time updates)
  Stream<List<Tournament>> streamTournaments() {
    return _tournamentsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => _mapToTournament(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  // Update tournament participant count
  Future<void> updateParticipantCount(String tournamentId, int newCount) async {
    try {
      await _tournamentsCollection.doc(tournamentId).update({
        'currentParticipants': newCount,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to update participant count: $e');
    }
  }
}
