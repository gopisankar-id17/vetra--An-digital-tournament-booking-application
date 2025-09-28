import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      body: _buildBookingsList(),
    );
  }

  Widget _buildBookingsList() {
    String userId = _auth.currentUser?.uid ?? '';
    
    if (userId.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Please sign in to view your bookings',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_online, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No bookings found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Book your first tournament to see it here!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        var bookings = snapshot.data!.docs;
        
        // Sort by booking date (newest first)
        bookings.sort((a, b) {
          var aDate = (a['bookingDate'] as Timestamp).toDate();
          var bDate = (b['bookingDate'] as Timestamp).toDate();
          return bDate.compareTo(aDate);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            var booking = bookings[index].data() as Map<String, dynamic>;
            return _buildBookingCard(booking, bookings[index].id);
          },
        );
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, String bookingId) {
    Color statusColor = _getStatusColor(booking['status'] ?? 'pending');
    Color paymentColor = _getPaymentColor(booking['paymentStatus'] ?? 'pending');
    
    Timestamp bookingDate = booking['bookingDate'] as Timestamp;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking['tournamentName'] ?? 'Unknown Tournament',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
              ],
            ),

            const SizedBox(height: 12),

            // Team and Captain Info
            _buildBookingDetailRow('Team Name', booking['teamName'] ?? 'Not specified'),
            _buildBookingDetailRow('Captain', booking['captainName'] ?? 'Not specified'),
            _buildBookingDetailRow('Players', '${booking['playerCount'] ?? 0} players'),
            _buildBookingDetailRow('Contact', booking['phoneNumber'] ?? 'Not provided'),
            _buildBookingDetailRow('Email', booking['email'] ?? 'Not provided'),

            const SizedBox(height: 12),

            // Payment Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Entry Fee: ₹${booking['entryFee'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Booked on: ${_dateFormat.format(bookingDate.toDate())}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            _buildActionButtons(booking, bookingId),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking, String bookingId) {
    String status = booking['status'] ?? 'pending';
    String paymentStatus = booking['paymentStatus'] ?? 'pending';

    // SIMPLIFIED: Use a column instead of row to avoid overflow
    if (status == 'pending' && paymentStatus == 'pending') {
      return Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _cancelBooking(bookingId),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Cancel Booking'),
            ),
          ),
        ],
      );
    } else if (status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _viewTournamentDetails(booking),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6f42c1),
            foregroundColor: Colors.white,
          ),
          child: const Text('View Tournament Details'),
        ),
      );
    } else if (status == 'cancelled') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _deleteBooking(bookingId),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey,
            side: const BorderSide(color: Colors.grey),
          ),
          child: const Text('Removed from List'),
        ),
      );
    } else if (paymentStatus == 'paid' && status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Awaiting Organizer Confirmation'),
        ),
      );
    }

    return const SizedBox(); // Fallback
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _makePayment(Map<String, dynamic> booking, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tournament: ${booking['tournamentName']}'),
            const SizedBox(height: 8),
            Text('Amount: ₹${booking['entryFee'] ?? 0}'),
            const SizedBox(height: 16),
            const Text(
              'Payment gateway integration would go here.\n\nFor demo purposes, this will mark the payment as completed.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('bookings').doc(bookingId).update({
                  'paymentStatus': 'paid',
                  'paymentDate': Timestamp.now(),
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment marked as completed!')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment failed: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simulate Payment'),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('bookings').doc(bookingId).update({
                  'status': 'cancelled',
                  'cancelledAt': Timestamp.now(),
                });
                
                // Decrement tournament participants count
                var bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
                var bookingData = bookingDoc.data() as Map<String, dynamic>;
                String tournamentId = bookingData['tournamentId'];
                
                await _firestore.collection('tournaments').doc(tournamentId).update({
                  'currentParticipants': FieldValue.increment(-1),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking cancelled successfully!')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cancellation failed: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewTournamentDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(booking['tournamentName'] ?? 'Tournament Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Team: ${booking['teamName']}'),
              const SizedBox(height: 8),
              Text('Captain: ${booking['captainName']}'),
              const SizedBox(height: 8),
              Text('Players: ${booking['playerCount']}'),
              const SizedBox(height: 8),
              Text('Status: ${booking['status']}'),
              const SizedBox(height: 8),
              Text('Payment: ${booking['paymentStatus']}'),
            ],
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

  void _deleteBooking(String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Booking'),
        content: const Text('This action cannot be undone. Remove this booking from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('bookings').doc(bookingId).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking removed!')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Removal failed: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}