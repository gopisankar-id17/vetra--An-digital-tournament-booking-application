import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/organizer.dart';
import '../models/tournament.dart';

class OrganizerService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _collection = 'organizers';

  // Create a new organizer account
  static Future<String?> createOrganizer({
    required String organizationName,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      // Create Firebase Auth user
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Create organizer document
        final organizer = Organizer(
          id: userCredential.user!.uid,
          organizationName: organizationName,
          email: email,
          phone: phone,
          address: address,
        );

        // Store in Firestore
        await _firestore
            .collection(_collection)
            .doc(organizer.id)
            .set(organizer.toMap());

        return organizer.id;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign in organizer
  static Future<Organizer?> signInOrganizer({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        return await getOrganizerById(userCredential.user!.uid);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get organizer by ID
  static Future<Organizer?> getOrganizerById(String organizerId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(organizerId)
          .get();

      if (doc.exists) {
        return Organizer.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get organizer by email
  static Future<Organizer?> getOrganizerByEmail(String email) async {
    try {
      final QuerySnapshot query = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return Organizer.fromMap(
          query.docs.first.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update organizer
  static Future<bool> updateOrganizer(Organizer organizer) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(organizer.id)
          .update(organizer.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete organizer
  static Future<bool> deleteOrganizer(String organizerId) async {
    try {
      await _firestore.collection(_collection).doc(organizerId).delete();

      // Also delete from Firebase Auth
      final User? user = _auth.currentUser;
      if (user != null && user.uid == organizerId) {
        await user.delete();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all organizers (for admin purposes)
  static Future<List<Organizer>> getAllOrganizers() async {
    try {
      final QuerySnapshot query = await _firestore
          .collection(_collection)
          .orderBy('registrationDate', descending: true)
          .get();

      return query.docs
          .map((doc) => Organizer.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add tournament to organizer
  static Future<bool> addTournamentToOrganizer(
    String organizerId,
    String tournamentId,
  ) async {
    try {
      // First, check if the organizer document exists
      final organizerDoc = await _firestore
          .collection(_collection)
          .doc(organizerId)
          .get();

      if (!organizerDoc.exists) {
        return false;
      }

      final data = organizerDoc.data() as Map<String, dynamic>;
      List<String> currentTournaments = [];

      if (data.containsKey('tournamentIds') && data['tournamentIds'] is List) {
        currentTournaments = List<String>.from(data['tournamentIds']);
      }

      if (!currentTournaments.contains(tournamentId)) {
        currentTournaments.add(tournamentId);

        await _firestore.collection(_collection).doc(organizerId).update({
          'tournamentIds': currentTournaments,
        });
      } else {}

      return true;
    } catch (e) {
      return false;
    }
  }

  // Remove tournament from organizer
  static Future<bool> removeTournamentFromOrganizer(
    String organizerId,
    String tournamentId,
  ) async {
    try {
      await _firestore.collection(_collection).doc(organizerId).update({
        'tournamentIds': FieldValue.arrayRemove([tournamentId]),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out organizer
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('OrganizerService: Firebase Auth signed out successfully');
    } catch (e) {
      print('OrganizerService: Error signing out from Firebase Auth: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get tournaments created by specific organizer
  static Future<List<Tournament>> getOrganizerTournaments(
    String organizerId,
  ) async {
    try {
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('tournaments')
          .where('organizerId', isEqualTo: organizerId)
          .get(); // Temporarily removed orderBy to avoid indexing issues

      List<Tournament> tournaments = [];
      for (var doc in query.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          // Add document ID to data
          data['id'] = doc.id;
          tournaments.add(Tournament.fromMap(data));
        } catch (e) {
          // Skip invalid tournament documents
        }
      }

      // Sort manually by startDate (descending)
      tournaments.sort((a, b) => b.startDate.compareTo(a.startDate));

      return tournaments;
    } catch (e) {
      return [];
    }
  }

  // Create tournament for organizer
  static Future<String?> createTournament({
    required String organizerId,
    required Tournament tournament,
  }) async {
    try {
      // Update tournament with organizer information
      final organizer = await getOrganizerById(organizerId);
      if (organizer == null) {
        return null;
      }

      final updatedTournament = Tournament(
        id: tournament.id,
        name: tournament.name,
        description: tournament.description,
        startDate: tournament.startDate,
        endDate: tournament.endDate,
        registrationDeadline: tournament.registrationDeadline,
        location: tournament.location,
        organizerId: organizerId,
        organizerName: organizer.organizationName,
        organizer: organizer.organizationName,
        imageUrl: tournament.imageUrl,
        maxParticipants: tournament.maxParticipants,
        entryFee: tournament.entryFee,
        status: tournament.status,
        categories: tournament.categories,
        format: tournament.format,
        mode: tournament.mode,
        rules: tournament.rules,
        prizes: tournament.prizes,
        contactInfo: tournament.contactInfo ?? organizer.email,
        ticketTypes: tournament.ticketTypes,
        participantsCount: tournament.participantsCount,
        prizePool: tournament.prizePool,
        organizerPhotoUrl: tournament.organizerPhotoUrl,
        organizerPastTournaments: tournament.organizerPastTournaments,
        startTime: tournament.startTime,
      );

      // Add tournament to Firestore
      try {
        final docRef = await FirebaseFirestore.instance
            .collection('tournaments')
            .add(updatedTournament.toMap());

        // Add tournament ID to organizer's tournament list
        final addResult = await addTournamentToOrganizer(
          organizerId,
          docRef.id,
        );

        if (addResult) {
          return docRef.id;
        } else {
          // Still return the ID as the tournament was created
          return docRef.id;
        }
      } on FirebaseException catch (e) {
        throw Exception('Firebase error: ${e.message}');
      } catch (e) {
        throw Exception('Failed to save tournament: $e');
      }
    } catch (e) {
      return null;
    }
  }

  // Get current signed-in organizer
  static Future<Organizer?> getCurrentOrganizer() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      return await getOrganizerById(user.uid);
    }
    return null;
  }

  // Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      final organizer = await getOrganizerByEmail(email);
      return organizer != null;
    } catch (e) {
      return false;
    }
  }

  // Delete tournament (only if created by organizer)
  static Future<bool> deleteTournament(String tournamentId) async {
    try {
      // Get current organizer
      final organizer = await getCurrentOrganizer();
      if (organizer == null) {
        return false;
      }

      // Check if tournament exists and belongs to this organizer
      final tournamentDoc = await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentId)
          .get();

      if (!tournamentDoc.exists) {
        return false;
      }

      final tournamentData = tournamentDoc.data() as Map<String, dynamic>;
      if (tournamentData['organizerId'] != organizer.id) {
        return false;
      }

      // Delete tournament from Firestore
      await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentId)
          .delete();

      // Remove tournament from organizer's tournament list
      await removeTournamentFromOrganizer(organizer.id, tournamentId);

      return true;
    } catch (e) {
      return false;
    }
  }
}
