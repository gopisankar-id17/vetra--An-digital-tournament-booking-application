// Booking model representing a tournament booking
class Booking {
  final String id;
  final String tournamentId;
  final String tournamentName;
  final String userId;
  final String userName;
  final DateTime bookingDate;
  final BookingStatus status;
  final double amountPaid;
  final String? notes;
  final String? receiptId;

  // Additional properties needed
  final int numberOfParticipants;
  final double discount;

  Booking({
    required this.id,
    required this.tournamentId,
    required this.tournamentName,
    required this.userId,
    required this.userName,
    required this.bookingDate,
    required this.status,
    required this.amountPaid,
    this.notes,
    this.receiptId,
    int? numberOfParticipants,
    double? discount,
  }) : this.numberOfParticipants = numberOfParticipants ?? 1,
       this.discount = discount ?? 0.0;

  // Sample bookings for demonstration
  static List<Booking> getSampleBookings() {
    return [
      Booking(
        id: 'b1',
        tournamentId: '1',
        tournamentName: 'Summer Chess Championship',
        userId: '2',
        userName: 'John Doe',
        bookingDate: DateTime.now().subtract(const Duration(days: 5)),
        status: BookingStatus.confirmed,
        amountPaid: 2500.0,
        receiptId: 'RCPT-001',
      ),
      Booking(
        id: 'b2',
        tournamentId: '3',
        tournamentName: 'eSports League - League of Legends',
        userId: '2',
        userName: 'John Doe',
        bookingDate: DateTime.now().subtract(const Duration(days: 10)),
        status: BookingStatus.active,
        amountPaid: 5000.0,
        receiptId: 'RCPT-002',
      ),
      Booking(
        id: 'b3',
        tournamentId: '4',
        tournamentName: 'Tennis Open 2025',
        userId: '2',
        userName: 'John Doe',
        bookingDate: DateTime.now().subtract(const Duration(days: 35)),
        status: BookingStatus.completed,
        amountPaid: 7500.0,
        receiptId: 'RCPT-003',
        notes: 'Reached quarterfinals',
      ),
    ];
  }
}

// Enum representing the status of a booking
enum BookingStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
  refunded,
}
