import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  
  // Sample booking data - in a real app, this would come from Firestore
  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 'book_001',
      'tournamentName': 'ZERO-0',
      'tournamentId': 'tourn_001',
      'teamName': 'Thunder Bolts',
      'status': 'confirmed',
      'bookingDate': DateTime.now().subtract(const Duration(days: 2)),
      'tournamentDate': DateTime.now().add(const Duration(days: 5)),
      'location': 'Sports Complex A',
      'entryFee': 1,
      'sport': 'Football',
      'format': 'Single Elimination',
      'participants': '9/15',
      'paymentStatus': 'paid',
      'bookingReference': 'VET2025001',
    },
    {
      'id': 'book_002',
      'tournamentName': 'Champions League 2025',
      'tournamentId': 'tourn_002',
      'teamName': 'Lightning Strikers',
      'status': 'pending',
      'bookingDate': DateTime.now().subtract(const Duration(days: 1)),
      'tournamentDate': DateTime.now().add(const Duration(days: 12)),
      'location': 'Metro Stadium',
      'entryFee': 500,
      'sport': 'Cricket',
      'format': 'Round Robin',
      'participants': '12/16',
      'paymentStatus': 'pending',
      'bookingReference': 'VET2025002',
    },
    {
      'id': 'book_003',
      'tournamentName': 'Basketball Pro League',
      'tournamentId': 'tourn_003',
      'teamName': 'Slam Dunkers',
      'status': 'cancelled',
      'bookingDate': DateTime.now().subtract(const Duration(days: 7)),
      'tournamentDate': DateTime.now().subtract(const Duration(days: 3)),
      'location': 'Indoor Arena B',
      'entryFee': 750,
      'sport': 'Basketball',
      'format': 'Double Elimination',
      'participants': '8/12',
      'paymentStatus': 'refunded',
      'bookingReference': 'VET2025003',
    },
    {
      'id': 'book_004',
      'tournamentName': 'Tennis Masters Open',
      'tournamentId': 'tourn_004',
      'teamName': 'Ace Smashers',
      'status': 'completed',
      'bookingDate': DateTime.now().subtract(const Duration(days: 20)),
      'tournamentDate': DateTime.now().subtract(const Duration(days: 10)),
      'location': 'Tennis Club Elite',
      'entryFee': 300,
      'sport': 'Tennis',
      'format': 'Swiss System',
      'participants': '16/16',
      'paymentStatus': 'paid',
      'bookingReference': 'VET2025004',
      'result': 'Runner-up',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Confirmed', 'Pending', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildBookingsList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Tournament Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: const Color(0xFF6f42c1).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF6f42c1),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF6f42c1) : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    final filteredBookings = _getFilteredBookings();
    
    if (filteredBookings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(filteredBookings[index]);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredBookings() {
    if (_selectedFilter == 'All') {
      return _bookings;
    }
    return _bookings.where((booking) {
      return booking['status'].toString().toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filter or book a tournament',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingHeader(booking),
            const SizedBox(height: 12),
            _buildTournamentInfo(booking),
            const SizedBox(height: 12),
            _buildBookingDetails(booking),
            const SizedBox(height: 16),
            _buildActionButtons(booking),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingHeader(Map<String, dynamic> booking) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking['tournamentName'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Team: ${booking['teamName']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusChip(booking['status']),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        icon = Icons.schedule;
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        break;
      case 'completed':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue[700]!;
        icon = Icons.task_alt;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTournamentInfo(Map<String, dynamic> booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.event, 'Tournament Date', 
              _dateFormat.format(booking['tournamentDate'])),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Location', booking['location']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.sports, 'Sport', booking['sport']),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.format_list_numbered, 'Format', booking['format']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetails(Map<String, dynamic> booking) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Ref: ${booking['bookingReference']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Booked: ${_dateFormat.format(booking['bookingDate'])}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${booking['entryFee']}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6f42c1),
              ),
            ),
            const SizedBox(height: 4),
            _buildPaymentStatusChip(booking['paymentStatus']),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentStatusChip(String paymentStatus) {
    Color backgroundColor;
    Color textColor;

    switch (paymentStatus.toLowerCase()) {
      case 'paid':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        break;
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        break;
      case 'refunded':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue[700]!;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        paymentStatus.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> booking) {
    String status = booking['status'].toLowerCase();
    
    return Row(
      children: [
        if (status == 'confirmed' || status == 'pending') ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showBookingDetails(booking),
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6f42c1),
                side: const BorderSide(color: Color(0xFF6f42c1)),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (status == 'pending') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _cancelBooking(booking),
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ] else if (status == 'confirmed') ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _viewTournament(booking),
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View Tournament'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6f42c1),
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ] else if (status == 'completed') ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showBookingDetails(booking),
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6f42c1),
                side: const BorderSide(color: Color(0xFF6f42c1)),
              ),
            ),
          ),
        ] else if (status == 'cancelled') ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showBookingDetails(booking),
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(booking['tournamentName']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Team Name', booking['teamName']),
              _buildDetailRow('Booking Reference', booking['bookingReference']),
              _buildDetailRow('Tournament Date', _dateFormat.format(booking['tournamentDate'])),
              _buildDetailRow('Location', booking['location']),
              _buildDetailRow('Sport', booking['sport']),
              _buildDetailRow('Format', booking['format']),
              _buildDetailRow('Entry Fee', '₹${booking['entryFee']}'),
              _buildDetailRow('Payment Status', booking['paymentStatus'].toString().toUpperCase()),
              _buildDetailRow('Booking Status', booking['status'].toString().toUpperCase()),
              if (booking.containsKey('result'))
                _buildDetailRow('Result', booking['result']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel your booking for "${booking['tournamentName']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Actually cancel the booking by updating its status
                setState(() {
                  booking['status'] = 'cancelled';
                  booking['paymentStatus'] = 'refunded';
                });
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking for "${booking['tournamentName']}" has been cancelled successfully'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _viewTournament(Map<String, dynamic> booking) {
    _showComingSoonDialog('View Tournament Details');
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Coming Soon'),
          content: Text('$feature feature will be available soon!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}