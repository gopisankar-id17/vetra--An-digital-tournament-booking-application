import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vetra/screens/users/search_page.dart';
import 'package:vetra/screens/users/tournament_videos_page.dart';
class DashboardContentPage extends StatefulWidget {
  final Function(String sport) onSportSelected;
  final Function({String? sport, String? status})? onNavigateToSearch;
  const DashboardContentPage({
    super.key, 
    required this.onSportSelected,
    this.onNavigateToSearch,
  });

  @override
  State<DashboardContentPage> createState() => _DashboardContentPageState();
}

class _DashboardContentPageState extends State<DashboardContentPage> {
  // Carousel Controllers and Indices
  final carousel.CarouselSliderController _upcomingCarouselController = carousel.CarouselSliderController();
  final carousel.CarouselSliderController _ongoingCarouselController = carousel.CarouselSliderController();
  final carousel.CarouselSliderController _trendingCarouselController = carousel.CarouselSliderController();
  int _upcomingCurrentIndex = 0;
  int _ongoingCurrentIndex = 0;
  int _trendingCurrentIndex = 0;
  
  // Track expanded tournament cards
  Set<String> _expandedCards = <String>{};

  // State for the Calendar
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Map to hold tournaments grouped by date for the calendar
  LinkedHashMap<DateTime, List<Map<String, dynamic>>> _events = LinkedHashMap();

  // Firestore and Date Formatting
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  // Data Lists
  List<Map<String, dynamic>> _allTournaments = [];
  List<Map<String, dynamic>> _upcomingTournaments = [];
  List<Map<String, dynamic>> _ongoingTournaments = [];
  List<Map<String, dynamic>> _trendingTournaments = [];
  bool _isLoading = true;

  // Booking form controllers for calendar booking
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _captainNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _playerCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _emailController.text = _auth.currentUser?.email ?? '';
    _loadTournaments();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _teamNameController.dispose();
    _captainNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _playerCountController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  Future<void> _loadTournaments() async {
    if (!mounted) return;
    try {
      DateTime now = DateTime.now();
      QuerySnapshot snapshot =
          await _firestore.collection('tournaments').orderBy('startDate').get();

      _allTournaments = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      _categorizeTournaments(_allTournaments, now);
      _populateEvents(_allTournaments);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error loading tournaments: $e');
    }
  }

  void _categorizeTournaments(
      List<Map<String, dynamic>> tournaments, DateTime now) {
    _upcomingTournaments.clear();
    _ongoingTournaments.clear();
    _trendingTournaments.clear();

    for (var tournament in tournaments) {
      Timestamp startDate = tournament['startDate'] as Timestamp;
      Timestamp endDate = tournament['endDate'] as Timestamp;
      DateTime startDateTime = startDate.toDate();
      DateTime endDateTime = endDate.toDate();

      if (startDateTime.isAfter(now)) {
        _upcomingTournaments.add(tournament);
      } else if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
        _ongoingTournaments.add(tournament);
      }

      int currentParticipants = tournament['currentParticipants'] ?? 0;
      int maxParticipants = tournament['maxParticipants'] ?? 1;
      if (maxParticipants > 0) {
        double participationRatio = currentParticipants / maxParticipants;
        if (participationRatio > 0.7) {
          _trendingTournaments.add(tournament);
        }
      }
    }

    _upcomingTournaments = _upcomingTournaments.take(5).toList();
    _ongoingTournaments = _ongoingTournaments.take(5).toList();
    _trendingTournaments = _trendingTournaments.take(5).toList();
  }

  void _populateEvents(List<Map<String, dynamic>> tournaments) {
    _events = LinkedHashMap<DateTime, List<Map<String, dynamic>>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );
    for (var tournament in tournaments) {
      final startDate = (tournament['startDate'] as Timestamp).toDate();
      final normalizedDate =
          DateTime.utc(startDate.year, startDate.month, startDate.day);
      if (_events[normalizedDate] == null) {
        _events[normalizedDate] = [];
      }
      _events[normalizedDate]!.add(tournament);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _showEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF8F9FA), Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MODIFIED: Welcome text is now first
                    const Text(
                      'Welcome back! 👋',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready to join some tournaments?',
                      style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
                    ),
                    const SizedBox(height: 30),

                    // MODIFIED: Stats section moved after welcome text
                    _buildTournamentStatsSection(),
                    const SizedBox(height: 30),

                    // --- CAROUSELS SECTION ---
                    if (_upcomingTournaments.isNotEmpty) ...[
                      _buildSectionHeader(
                          context, 'Upcoming Tournaments 🗓️', () {
                        _navigateToSearch(context, status: 'upcoming');
                      }),
                      const SizedBox(height: 15),
                      carousel.CarouselSlider(
                        carouselController: _upcomingCarouselController,
                        options: carousel.CarouselOptions(
                          height: 220.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.8,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _upcomingCurrentIndex = index;
                            });
                          },
                        ),
                        items: _upcomingTournaments.map((tournament) {
                          return _buildUpcomingTournamentPhotoCard(
                              context, tournament);
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      _buildPageIndicator(_upcomingTournaments.length,
                          _upcomingCurrentIndex, _upcomingCarouselController, const Color(0xFF6f42c1)),
                      const SizedBox(height: 30),
                    ],
                    if (_ongoingTournaments.isNotEmpty) ...[
                      _buildSectionHeader(
                          context, 'Ongoing Tournaments 🥇', () {
                        _navigateToSearch(context, status: 'ongoing');
                      }),
                      const SizedBox(height: 15),
                      carousel.CarouselSlider(
                        carouselController: _ongoingCarouselController,
                        options: carousel.CarouselOptions(
                          height: 220.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.8,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _ongoingCurrentIndex = index;
                            });
                          },
                        ),
                        items: _ongoingTournaments.map((tournament) {
                          return _buildOngoingTournamentPhotoCard(
                              context, tournament);
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      _buildPageIndicator(_ongoingTournaments.length,
                          _ongoingCurrentIndex, _ongoingCarouselController, const Color(0xFF8a63d2)),
                      const SizedBox(height: 30),
                    ],
                    if (_trendingTournaments.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Trending Now 🔥', () {
                        _navigateToSearch(context);
                      }),
                      const SizedBox(height: 15),
                      carousel.CarouselSlider(
                        carouselController: _trendingCarouselController,
                        options: carousel.CarouselOptions(
                          height: 220.0,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 0.8,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _trendingCurrentIndex = index;
                            });
                          },
                        ),
                        items: _trendingTournaments.map((tournament) {
                          return _buildTrendingTournamentCard(
                              context, tournament);
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      _buildPageIndicator(_trendingTournaments.length,
                          _trendingCurrentIndex, _trendingCarouselController, const Color(0xFF6f42c1)),
                      const SizedBox(height: 30),
                    ],

                    // --- CALENDAR SECTION ---
                     _buildSectionHeader(context, 'Tournament Calendar 📅', () {
                       _navigateToSearch(context);
                     }),
                    const SizedBox(height: 15),
                    _buildTournamentCalendar(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
  }

  // --- All helper methods and build methods for cards/dialogs go below ---
  
  Widget _buildTournamentCalendar() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TableCalendar<Map<String, dynamic>>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          eventLoader: _getEventsForDay,
          onDaySelected: _onDaySelected,
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            markerDecoration: BoxDecoration(
              color: Color(0xFF8a63d2),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0xFF6f42c1),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFFc0aada),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
      ),
    );
  }
  
  void _showEventsForDay(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No tournaments on ${_dateFormat.format(day)}'))
        );
        return;
    }
    
    final Map<String, int> sportCounts = {};
    for (var event in events) {
      final categories = event['categories'] as List<dynamic>? ?? [];
      for (var category in categories) {
          final sportName = category.toString();
          sportCounts[sportName] = (sportCounts[sportName] ?? 0) + 1;
      }
    }

    showDialog(
        context: context,
        builder: (context) {
            return AlertDialog(
                title: Text('Tournaments on ${_dateFormat.format(day)}'),
                content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categories & No. of Tournaments',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        ListView(
                          shrinkWrap: true,
                          children: sportCounts.entries.map((entry) {
                            final sport = entry.key;
                            final count = entry.value;
                            return ListTile(
                              title: Text(sport),
                              trailing: Text('$count ${count > 1 ? "events" : "event"}'),
                              onTap: () {
                                  Navigator.pop(context); // Close the dialog
                                  widget.onSportSelected(sport);
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
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

  // Navigate to search page with filters
  void _navigateToSearch(BuildContext context, {String? status, String? sport}) {
    // Try to use the callback to navigate within the tab structure
    if (widget.onNavigateToSearch != null) {
      widget.onNavigateToSearch!(sport: sport, status: status);
    } else {
      // Fallback to the old push navigation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchPage(
            initialSportFilter: sport,
            initialStatusFilter: status,
          ),
        ),
      );
    }
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }

  Widget _buildPageIndicator(int length, int currentIndex,
      carousel.CarouselSliderController controller, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return GestureDetector(
          onTap: () => controller.animateToPage(index),
          child: Container(
            width: currentIndex == index ? 12.0 : 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color:
                  currentIndex == index ? color : Colors.grey.withOpacity(0.4),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'View All',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6f42c1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingTournamentCard(
      BuildContext context, Map<String, dynamic> tournament) {
    String title = tournament['name'] ?? 'Unknown Tournament';
    String imageUrl = tournament['imageUrl'] ?? '';
    String tournamentId = tournament['id'] ?? '';
    int currentParticipants = tournament['currentParticipants'] ?? 0;
    int maxParticipants = tournament['maxParticipants'] ?? 1;
    double participationRate =
        (maxParticipants > 0) ? (currentParticipants / maxParticipants) * 100 : 0;

    String status;
    Color tagColor;

    if (participationRate >= 90) {
      status = 'HIGH DEMAND';
      tagColor = Colors.red;
    } else if (participationRate >= 70) {
      status = 'POPULAR';
      tagColor = Colors.orange;
    } else {
      status = 'TRENDING';
      tagColor = const Color(0xFF6f42c1);
    }

    bool isExpanded = _expandedCards.contains(tournamentId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCards.remove(tournamentId);
          } else {
            _expandedCards.add(tournamentId);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackImage(title, tagColor))
                  : _buildFallbackImage(title, tagColor),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.7)
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentParticipants/$maxParticipants participants (${participationRate.toStringAsFixed(0)}% full)',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    
                    // Show buttons when expanded
                    if (isExpanded) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.visibility, size: 14),
                              label: const Text('View', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _showFullTournamentDetails(context, tournament);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.how_to_reg, size: 14),
                              label: const Text('Register', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _showBookingDialog(tournament, tournamentId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6f42c1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text(status,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                  backgroundColor: tagColor,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTournamentPhotoCard(
      BuildContext context, Map<String, dynamic> tournament) {
    String title = tournament['name'] ?? 'Unknown Tournament';
    String imageUrl = tournament['imageUrl'] ?? '';
    String tournamentId = tournament['id'] ?? '';
    Timestamp startDate = tournament['startDate'] as Timestamp;
    String date = _dateFormat.format(startDate.toDate());
    
    bool isExpanded = _expandedCards.contains(tournamentId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCards.remove(tournamentId);
          } else {
            _expandedCards.add(tournamentId);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackImage(title, const Color(0xFF6f42c1)))
                  : _buildFallbackImage(title, const Color(0xFF6f42c1)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6)
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 10,
                right: 10,
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    
                    // Show buttons when expanded
                    if (isExpanded) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.visibility, size: 14),
                              label: const Text('View', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _showFullTournamentDetails(context, tournament);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.how_to_reg, size: 14),
                              label: const Text('Register', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _showBookingDialog(tournament, tournamentId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6f42c1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text('UPCOMING',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                  backgroundColor: Color(0xFF6f42c1),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOngoingTournamentPhotoCard(
      BuildContext context, Map<String, dynamic> tournament) {
    String title = tournament['name'] ?? 'Unknown Tournament';
    String imageUrl = tournament['imageUrl'] ?? '';
    String tournamentId = tournament['id'] ?? '';
    
    bool isExpanded = _expandedCards.contains(tournamentId);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedCards.remove(tournamentId);
          } else {
            _expandedCards.add(tournamentId);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? Image.network(imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackImage(title, const Color(0xFF8a63d2)))
                  : _buildFallbackImage(title, const Color(0xFF8a63d2)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.6)
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Show buttons when expanded
                    if (isExpanded) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.visibility, size: 14),
                              label: const Text('View', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _showFullTournamentDetails(context, tournament);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.how_to_reg, size: 14),
                              label: const Text('Register', style: TextStyle(fontSize: 12)),
                              onPressed: () {
                                _showBookingDialog(tournament, tournamentId);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6f42c1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Chip(
                  label: Text('LIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10)),
                  backgroundColor: Color(0xFF8a63d2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentStatsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('bookings').where('userId', isEqualTo: _auth.currentUser?.uid).snapshots(),
      builder: (context, snapshot) {
        int totalBookings = 0;
        if (snapshot.hasData) {
          totalBookings = snapshot.data!.docs.length;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6f42c1),
                Color(0xFF8a63d2),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6f42c1).withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Tournament Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('Tournaments\nJoined', totalBookings.toString(),
                      Icons.sports_soccer),
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3)),
                  _buildStatCard('Wins', '0', Icons.emoji_events), // Placeholder
                  Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3)),
                  _buildStatCard('Rank', '#--', Icons.trending_up), // Placeholder
                ],
              ),
              const SizedBox(height: 15),
 
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackImage(String title, Color color) {
    return Container(
      color: color.withOpacity(0.2),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
  
  void _showTournamentDetails(
      BuildContext context, Map<String, dynamic> tournament) {
    String title = tournament['name'] ?? 'Unknown Tournament';
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Tournament title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 30),
              
              // Two buttons
              Row(
                children: [
                  // View Button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                      onPressed: () {
                        Navigator.pop(context);
                        _showFullTournamentDetails(context, tournament);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 15),
                  
                  // Register Button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Register'),
                      onPressed: () {
                        Navigator.pop(context);
                        _showBookingDialog(tournament, tournament['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6f42c1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFullTournamentDetails(
      BuildContext context, Map<String, dynamic> tournament) {
    print('DEBUG: _showFullTournamentDetails called');
    print('Tournament data: ${tournament.keys.join(', ')}');
    
    // Simple test dialog first
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tournament Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${tournament['name'] ?? 'Unknown'}'),
            Text('Organizer: ${tournament['organizer'] ?? 'Unknown'}'),
            Text('Location: ${tournament['location'] ?? 'Unknown'}'),
            Text('Entry Fee: ₹${tournament['entryFee'] ?? 0}'),
            Text('Participants: ${tournament['currentParticipants'] ?? 0}/${tournament['maxParticipants'] ?? 0}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
    return;
    
    // Original detailed implementation below (disabled for testing)
    print('Showing tournament details for: ${tournament['name']}');
    
    String title = tournament['name'] ?? 'Unknown Tournament';
    String description = tournament['description'] ?? 'No description available';
    String organizer = tournament['organizer'] ?? 'Unknown Organizer';
    String location = tournament['location'] ?? 'Location not specified';
    int entryFee = tournament['entryFee'] ?? 0;
    int currentParticipants = tournament['currentParticipants'] ?? 0;
    int maxParticipants = tournament['maxParticipants'] ?? 0;
    String rules = tournament['rules'] ?? 'No rules specified';
    String prizes = tournament['prizes'] ?? 'No prize information';
    String contactInfo = tournament['contactInfo'] ?? 'No contact information';

    // Handle dates safely with null checks
    String startDateStr = 'Not specified';
    String endDateStr = 'Not specified';
    String regDeadlineStr = 'Not specified';
    
    try {
      if (tournament['startDate'] != null) {
        Timestamp startDate = tournament['startDate'] as Timestamp;
        startDateStr = _dateFormat.format(startDate.toDate());
      }
      if (tournament['endDate'] != null) {
        Timestamp endDate = tournament['endDate'] as Timestamp;
        endDateStr = _dateFormat.format(endDate.toDate());
      }
      if (tournament['registrationDeadline'] != null) {
        Timestamp regDeadline = tournament['registrationDeadline'] as Timestamp;
        regDeadlineStr = _dateFormat.format(regDeadline.toDate());
      }
    } catch (e) {
      print('Error parsing tournament dates: $e');
      // Use default values if there's an error
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.person, 'Organizer', organizer),
              _buildDetailRow(Icons.location_on, 'Location', location),
              _buildDetailRow(Icons.attach_money, 'Entry Fee', '₹$entryFee'),
              _buildDetailRow(Icons.people, 'Participants',
                  '$currentParticipants/$maxParticipants'),
              _buildDetailRow(
                  Icons.calendar_today, 'Starts', startDateStr),
              _buildDetailRow(
                  Icons.event, 'Ends', endDateStr),
              _buildDetailRow(Icons.alarm, 'Registration Deadline',
                  regDeadlineStr),
              const SizedBox(height: 20),
              const Text(
                'Rules:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(rules),
              const SizedBox(height: 15),
              const Text(
                'Prizes:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(prizes),
              const SizedBox(height: 15),
              const Text(
                'Contact:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(contactInfo),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.how_to_reg),
                      label: const Text('Register Now'),
                      onPressed: () {
                        Navigator.pop(context);
                        _showBookingDialog(tournament, tournament['id']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6f42c1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
   return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6f42c1)),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF7F8C8D),
              ),
            ),
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
   String _formatTournamentFormat(String format) {
    if (format.isEmpty) return 'N/A';
    return format.replaceAll(RegExp('([A-Z])'), ' \$1').trim();
  }
}