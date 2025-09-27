import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Note: No other pages are imported here.

class SearchPage extends StatefulWidget {
  final String? initialSportFilter;
  const SearchPage({super.key, this.initialSportFilter});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Filter states
  String _selectedStatus = 'All';
  String _selectedFormat = 'All';
  String _selectedMode = 'All';
  String _selectedSport = 'All';
  double _maxEntryFee = 10000;
  bool _showFilters = false;

  // Sports list for the filter dropdown, loaded dynamically
  List<String> _sportsFilterOptions = ['All'];

  // Booking form controllers
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _captainNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _playerCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = _auth.currentUser?.email ?? '';
    _loadSportFilterOptions();

    if (widget.initialSportFilter != null) {
      _selectedSport = widget.initialSportFilter!;
      _showFilters = true;
    }
  }

  // Dynamically load sports categories from Firestore
  Future<void> _loadSportFilterOptions() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('tournaments').get();
      Set<String> sports = {'All'}; // Use a Set to avoid duplicates
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('categories') && data['categories'] is List) {
          for (var category in data['categories']) {
            sports.add(category.toString());
          }
        }
      }
      if (mounted) {
        setState(() {
          _sportsFilterOptions = sports.toList()..sort();
        });
      }
    } catch (e) {
      print("Error loading sport filters: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _teamNameController.dispose();
    _captainNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _playerCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilters(),
          Expanded(
            child: _buildTournamentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tournaments...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  icon:
                      Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
                  label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6f42c1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildFilterDropdown(
            'Sport',
            _sportsFilterOptions,
            _selectedSport,
            (value) => setState(() => _selectedSport = value!),
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Status',
            ['All', 'upcoming', 'ongoing', 'completed'],
            _selectedStatus,
            (value) => setState(() => _selectedStatus = value!),
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Format',
            ['All', 'singleElimination', 'doubleElimination', 'roundRobin', 'swiss'],
            _selectedFormat,
            (value) => setState(() => _selectedFormat = value!),
          ),
          const SizedBox(height: 12),
          _buildFilterDropdown(
            'Mode',
            ['All', 'offline', 'online'],
            _selectedMode,
            (value) => setState(() => _selectedMode = value!),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Max Entry Fee: ₹${_maxEntryFee.toInt()}'),
              Slider(
                value: _maxEntryFee,
                min: 0,
                max: 10000,
                divisions: 20,
                onChanged: (value) => setState(() => _maxEntryFee = value),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedSport = 'All';
                _selectedStatus = 'All';
                _selectedFormat = 'All';
                _selectedMode = 'All';
                _maxEntryFee = 10000;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> options,
      String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label:'),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: options.contains(value) ? value : 'All',
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option == 'All'
                  ? 'All'
                  : option.replaceAll(RegExp('([A-Z])'), ' \$1').trim()),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tournaments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tournaments found'));
        }
        var tournaments = _applyFilters(snapshot.data!.docs);
        if (tournaments.isEmpty) {
          return const Center(child: Text('No tournaments match your filters'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tournaments.length,
          itemBuilder: (context, index) {
            var tournament =
                tournaments[index].data() as Map<String, dynamic>;
            return _buildTournamentCard(tournament, tournaments[index].id);
          },
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _applyFilters(
      List<QueryDocumentSnapshot> tournaments) {
    String searchTerm = _searchController.text.toLowerCase();

    return tournaments.where((doc) {
      var tournament = doc.data() as Map<String, dynamic>;

      String name = tournament['name']?.toString().toLowerCase() ?? '';
      String description =
          tournament['description']?.toString().toLowerCase() ?? '';
      String location = tournament['location']?.toString().toLowerCase() ?? '';
      
      List<String> categories =
          (tournament['categories'] as List<dynamic>? ?? [])
              .map((c) => c.toString().toLowerCase())
              .toList();
      String status = tournament['status']?.toString().toLowerCase() ?? '';
      String format = tournament['format']?.toString().toLowerCase() ?? '';
      String mode = tournament['mode']?.toString().toLowerCase() ?? '';
      double entryFee = (tournament['entryFee'] as num?)?.toDouble() ?? 0;

      if (searchTerm.isNotEmpty &&
          !name.contains(searchTerm) &&
          !description.contains(searchTerm) &&
          !location.contains(searchTerm)) {
        return false;
      }
      
      if (_selectedSport != 'All' && !categories.contains(_selectedSport.toLowerCase())) {
        return false;
      }

      if (_selectedStatus != 'All' && status != _selectedStatus.toLowerCase()) {
        return false;
      }

      if (_selectedFormat != 'All' && format != _selectedFormat.toLowerCase()) {
        return false;
      }

      if (_selectedMode != 'All' && mode != _selectedMode.toLowerCase()) {
        return false;
      }

      if (entryFee > _maxEntryFee) {
        return false;
      }

      return true;
    }).toList();
  }

  // --- The rest of the file (buildTournamentCard, dialogs, etc.) is unchanged ---
  // [Full code omitted for brevity as it was correct in the previous step]
  Widget _buildTournamentCard(Map<String, dynamic> tournament, String tournamentId) {
    Timestamp startDate = tournament['startDate'] as Timestamp;
    Timestamp endDate = tournament['endDate'] as Timestamp;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tournament['imageUrl'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                tournament['imageUrl'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.sports_esports, size: 50, color: Colors.grey),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        tournament['name'] ?? 'Unnamed Tournament',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        _getStatusText(tournament['status'] ?? ''),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      backgroundColor: _getStatusColor(tournament['status'] ?? ''),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                _buildDetailRow(Icons.calendar_today, 
                  '${DateFormat.yMMMd().format(startDate.toDate())} - ${DateFormat.yMMMd().format(endDate.toDate())}'),
                _buildDetailRow(Icons.location_on, tournament['location'] ?? 'Location not specified'),
                _buildDetailRow(Icons.people, 
                  '${tournament['currentParticipants'] ?? 0}/${tournament['maxParticipants'] ?? 0} participants'),
                _buildDetailRow(Icons.attach_money, 'Entry Fee: ₹${tournament['entryFee'] ?? 0}'),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Chip(
                      label: Text(tournament['organizer'] ?? 'Unknown'),
                      backgroundColor: Colors.blue[50],
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(_formatTournamentFormat(tournament['format'] ?? '')),
                      backgroundColor: Colors.green[50],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showTournamentDetails(tournament, tournamentId);
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showBookingDialog(tournament, tournamentId);
                        },
                        icon: const Icon(Icons.book_online),
                        label: const Text('Book Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6f42c1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'upcoming': return 'UPCOMING';
      case 'ongoing': return 'LIVE';
      case 'completed': return 'COMPLETED';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming': return Colors.blue;
      case 'ongoing': return Colors.green;
      case 'completed': return Colors.grey;
      default: return Colors.orange;
    }
  }

  String _formatTournamentFormat(String format) {
    if (format.isEmpty) return 'N/A';
    return format.replaceAll(RegExp('([A-Z])'), ' \$1').trim();
  }

  void _showTournamentDetails(Map<String, dynamic> tournament, String tournamentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tournament['name'] ?? 'Tournament Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: ${tournament['description'] ?? 'No description'}'),
              const SizedBox(height: 8),
              Text('Rules: ${tournament['rules'] ?? 'No rules specified'}'),
              const SizedBox(height: 8),
              Text('Prizes: ${tournament['prizes'] ?? 'No prize information'}'),
              const SizedBox(height: 8),
              Text('Contact: ${tournament['contactInfo'] ?? 'No contact information'}'),
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

  void _showBookingDialog(Map<String, dynamic> tournament, String tournamentId) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Book Tournament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tournament['name'] ?? 'Tournament',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _captainNameController,
                  decoration: const InputDecoration(
                    labelText: 'Captain Name*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _playerCountController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Players*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Text(
                  'Entry Fee: ₹${tournament['entryFee'] ?? 0}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _bookTournament(tournament, tournamentId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6f42c1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookTournament(Map<String, dynamic> tournament, String tournamentId) async {
    try {
      if (_teamNameController.text.isEmpty ||
          _captainNameController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _playerCountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

      await _firestore.collection('bookings').add({
        'tournamentId': tournamentId,
        'tournamentName': tournament['name'],
        'userId': _auth.currentUser?.uid,
        'userEmail': _auth.currentUser?.email,
        'teamName': _teamNameController.text,
        'captainName': _captainNameController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
        'playerCount': int.tryParse(_playerCountController.text) ?? 0,
        'entryFee': tournament['entryFee'],
        'bookingDate': Timestamp.now(),
        'status': 'pending',
        'paymentStatus': 'pending',
      });

      await _firestore.collection('tournaments').doc(tournamentId).update({
        'currentParticipants': FieldValue.increment(1),
      });

      _teamNameController.clear();
      _captainNameController.clear();
      _phoneController.clear();
      _playerCountController.clear();
      _emailController.text = _auth.currentUser?.email ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }
}