import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for bookings
  CollectionReference get _bookingsCollection =>
      _firestore.collection('bookings');

  // Get all bookings for a specific tournament
  Future<List<Map<String, dynamic>>> getTournamentBookings(
    String tournamentId,
  ) async {
    try {
      final querySnapshot = await _bookingsCollection
          .where('tournamentId', isEqualTo: tournamentId)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw Exception('Failed to get tournament bookings: $e');
    }
  }

  // Get bookings with team names for a tournament
  Future<List<Map<String, dynamic>>> getTournamentTeams(
    String tournamentId,
  ) async {
    try {
      final querySnapshot = await _bookingsCollection
          .where('tournamentId', isEqualTo: tournamentId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'teamName': data['teamName'] ?? 'No Team Name',
          'captainName': data['captainName'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'bookingDate': data['bookingDate'] != null
              ? (data['bookingDate'] as Timestamp).toDate()
              : DateTime.now(),
          'playerCount': data['playerCount'] ?? 1,
          'paymentStatus': data['paymentStatus'] ?? 'pending',
          'status': data['status'] ?? 'pending',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tournament teams: $e');
    }
  }

  // Create a new booking
  Future<String> createBooking({
    required String tournamentId,
    required String tournamentName,
    required String captainName,
    required String email,
    required String phoneNumber,
    required String teamName,
    required int playerCount,
    required double entryFee,
    String? userId,
  }) async {
    try {
      final docRef = _bookingsCollection.doc();

      final bookingData = {
        'id': docRef.id,
        'tournamentId': tournamentId,
        'tournamentName': tournamentName,
        'userId': userId,
        'captainName': captainName,
        'email': email,
        'phoneNumber': phoneNumber,
        'teamName': teamName,
        'bookingDate': Timestamp.now(),
        'playerCount': playerCount,
        'entryFee': entryFee,
        'paymentStatus': 'pending',
        'status': 'pending',
      };

      await docRef.set(bookingData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingsCollection.doc(bookingId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    try {
      await _bookingsCollection.doc(bookingId).update({
        'paymentStatus': paymentStatus,
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }
}
