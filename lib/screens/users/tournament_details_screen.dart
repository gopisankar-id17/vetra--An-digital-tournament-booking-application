import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/user.dart';
import '../../models/booking.dart';
import '../../utils/app_theme.dart';
import 'booking_success_screen.dart';
import 'dart:math' as math;

class TournamentDetailsScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentDetailsScreen({Key? key, required this.tournament})
    : super(key: key);

  @override
  State<TournamentDetailsScreen> createState() =>
      _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  int _selectedParticipants = 1;
  bool _agreeToTerms = false;
  String? _selectedTicketType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();

    // Set default selected ticket type
    if (widget.tournament.ticketTypes.isNotEmpty) {
      _selectedTicketType = widget.tournament.ticketTypes.keys.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTournamentHeader(),
                      _buildTabBar(),
                      _buildTabView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'tournament-${widget.tournament.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.tournament.imageUrl ??
                    'https://via.placeholder.com/800x400?text=Tournament+Image',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.tournament.status
                                  .toString()
                                  .split('.')
                                  .last,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sharing tournament details...')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {
            // Bookmark functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tournament saved to bookmarks')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTournamentHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: Text(
              widget.tournament.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          SlideTransition(
            position: _slideAnimation,
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(widget.tournament.startDate)} - ${_formatDate(widget.tournament.endDate)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SlideTransition(
            position: _slideAnimation,
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  widget.tournament.location,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SlideTransition(
            position: _slideAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.people,
                  title: 'Participants',
                  value:
                      '${widget.tournament.participantsCount}/${widget.tournament.maxParticipants}',
                ),
                _buildInfoItem(
                  icon: Icons.emoji_events,
                  title: 'Prize Pool',
                  value: 'Rs. ${widget.tournament.prizePool}',
                ),
                _buildInfoItem(
                  icon: Icons.app_registration,
                  title: 'Entry Fee',
                  value: 'Rs. ${widget.tournament.entryFee}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.primary,
        labelColor: AppTheme.primary,
        unselectedLabelColor: Colors.grey[600],
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Schedule'),
          Tab(text: 'Participants'),
          Tab(text: 'Rules'),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return SizedBox(
      height: 500, // You can adjust this height based on your content
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildScheduleTab(),
          _buildParticipantsTab(),
          _buildRulesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this Tournament',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 100,
            child: Text(
              widget.tournament.description,
              style: TextStyle(color: Colors.grey[800], height: 1.5),
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.fade,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'Read less' : 'Read more',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Categories',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.tournament.categories
                .map(
                  (category) => Chip(
                    label: Text(category),
                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Organizer',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.tournament.organizerPhotoUrl,
              ),
              onBackgroundImageError: (exception, stackTrace) =>
                  Container(color: Colors.grey[300]),
            ),
            title: Text(
              widget.tournament.organizerName ?? widget.tournament.organizer,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Organized ${widget.tournament.organizerPastTournaments} tournaments',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // Contact organizer functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contacting organizer...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black87,
              ),
              child: const Text('Contact'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    // Demo schedule data
    final schedules = [
      {
        'date': 'Day 1 - ${_formatDate(widget.tournament.startDate)}',
        'events': [
          {
            'time': '09:00 AM',
            'title': 'Registration and Check-in',
            'location': 'Main Entrance',
          },
          {
            'time': '10:00 AM',
            'title': 'Opening Ceremony',
            'location': 'Main Arena',
          },
          {
            'time': '11:00 AM',
            'title': 'Preliminary Rounds Begin',
            'location': 'Multiple Venues',
          },
          {
            'time': '01:00 PM',
            'title': 'Lunch Break',
            'location': 'Food Court',
          },
          {
            'time': '02:00 PM',
            'title': 'Preliminary Rounds Continue',
            'location': 'Multiple Venues',
          },
          {'time': '06:00 PM', 'title': 'End of Day 1', 'location': ''},
        ],
      },
      {
        'date':
            'Day 2 - ${_formatDate(widget.tournament.startDate.add(const Duration(days: 1)))}',
        'events': [
          {
            'time': '09:30 AM',
            'title': 'Quarter Finals',
            'location': 'Main Arena',
          },
          {
            'time': '12:30 PM',
            'title': 'Lunch Break',
            'location': 'Food Court',
          },
          {
            'time': '01:30 PM',
            'title': 'Semi Finals',
            'location': 'Main Arena',
          },
          {
            'time': '04:00 PM',
            'title': 'Final Match',
            'location': 'Main Arena',
          },
          {
            'time': '06:00 PM',
            'title': 'Award Ceremony',
            'location': 'Main Stage',
          },
        ],
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, dayIndex) {
        final schedule = schedules[dayIndex];
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule['date'] as String,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (schedule['events'] as List).length,
                itemBuilder: (context, eventIndex) {
                  final event =
                      (schedule['events'] as List)[eventIndex]
                          as Map<String, dynamic>;
                  return _buildScheduleItem(
                    time: event['time'] as String,
                    title: event['title'] as String,
                    location: event['location'] as String,
                    isLastItem:
                        eventIndex == (schedule['events'] as List).length - 1,
                  );
                },
              ),
              if (dayIndex < schedules.length - 1) const Divider(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScheduleItem({
    required String time,
    required String title,
    required String location,
    required bool isLastItem,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Column(
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
            ),
            if (!isLastItem)
              Container(
                width: 2,
                height: 50,
                color: AppTheme.primary.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      location,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsTab() {
    // Sample participants data
    final participants = List.generate(
      widget.tournament.participantsCount,
      (index) => {
        'name': 'Participant ${index + 1}',
        'avatar':
            'https://ui-avatars.com/api/?name=P${index + 1}&background=random',
        'rating': math.Random().nextInt(500) + 1000,
        'matches': math.Random().nextInt(50) + 10,
        'wins': math.Random().nextInt(30) + 5,
      },
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Participants',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${widget.tournament.participantsCount}/${widget.tournament.maxParticipants}',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[200],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor:
                  widget.tournament.participantsCount /
                  widget.tournament.maxParticipants,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length > 10 ? 10 : participants.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final participant = participants[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      participant['avatar'] as String,
                    ),
                  ),
                  title: Text(participant['name'] as String),
                  subtitle: Text(
                    'Rating: ${participant['rating']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    '${participant['wins']}/${participant['matches']} wins',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    // Sample rules data
    final rules = [
      'All participants must arrive at least 30 minutes before their scheduled match time.',
      'Valid ID proof is mandatory for all participants.',
      'Participants are responsible for bringing their own equipment as specified in the tournament guidelines.',
      'The organizer\'s decision is final in case of disputes.',
      'Unsportsmanlike conduct will result in immediate disqualification.',
      'Match formats and rules will be explained before the start of each round.',
      'Prize distribution will be done at the end of the tournament after verification.',
      'Participants under 18 years must be accompanied by a guardian.',
      'The tournament schedule may be subject to change due to unforeseen circumstances.',
      'Registration fees are non-refundable after confirmation.',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tournament Rules',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rules.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.1),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rules[index],
                          style: TextStyle(
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.tournament.status == 'Completed'
                  ? _buildCompletedButtons()
                  : _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedButtons() {
    return ElevatedButton.icon(
      onPressed: () {
        // View results functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing tournament results...')),
        );
      },
      icon: const Icon(Icons.emoji_events),
      label: const Text('View Results'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.tournament.status == 'Open for Registration' ||
        widget.tournament.status == 'Registration Closing Soon') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => _buildRegisterBottomSheet(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Register Now'),
            ),
          ),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
        child: Text(
          widget.tournament.status == 'Upcoming'
              ? 'Registration Opens Soon'
              : 'Registration Closed',
        ),
      );
    }
  }

  Widget _buildRegisterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tournament Registration',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tournament Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.tournament.imageUrl ??
                                    'https://via.placeholder.com/80x80?text=Tournament',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.tournament.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_formatDate(widget.tournament.startDate)} - ${_formatDate(widget.tournament.endDate)}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.tournament.location,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Ticket Selection
                      if (widget.tournament.ticketTypes.isNotEmpty) ...[
                        Text(
                          'Select Ticket Type',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...widget.tournament.ticketTypes.entries.map((entry) {
                          return _buildTicketTypeItem(entry.key, entry.value);
                        }).toList(),
                        const SizedBox(height: 24),
                      ],

                      // Number of Participants
                      Text(
                        'Number of Participants',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _selectedParticipants > 1
                                  ? () =>
                                        setState(() => _selectedParticipants--)
                                  : null,
                              icon: const Icon(Icons.remove),
                              color: _selectedParticipants > 1
                                  ? AppTheme.primary
                                  : Colors.grey,
                            ),
                            Text(
                              _selectedParticipants.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _selectedParticipants < 5
                                  ? () =>
                                        setState(() => _selectedParticipants++)
                                  : null,
                              icon: const Icon(Icons.add),
                              color: _selectedParticipants < 5
                                  ? AppTheme.primary
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Maximum 5 participants per registration',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),

                      const SizedBox(height: 24),

                      // Terms and Conditions
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() => _agreeToTerms = value!);
                            },
                            activeColor: AppTheme.primary,
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(color: Colors.grey[800]),
                                children: [
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Payment Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Summary',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildPaymentRow(
                              'Entry Fee',
                              'Rs. ${widget.tournament.entryFee}',
                            ),
                            const SizedBox(height: 8),
                            _buildPaymentRow(
                              'Number of Participants',
                              '${_selectedParticipants}',
                            ),
                            if (_selectedTicketType != null &&
                                widget.tournament.ticketTypes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildPaymentRow(
                                'Ticket Type',
                                _selectedTicketType!,
                              ),
                            ],
                            const SizedBox(height: 8),
                            const Divider(),
                            const SizedBox(height: 8),
                            _buildPaymentRow(
                              'Total Amount',
                              'Rs. ${_calculateTotal()}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _agreeToTerms ? _handleRegistration : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 50),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
                child: const Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTypeItem(String type, double price) {
    final isSelected = _selectedTicketType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTicketType = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (type == 'Standard') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Basic tournament entry',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ] else if (type == 'Premium') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Includes priority registration, merchandise, and refreshments',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ] else if (type == 'VIP') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Includes all Premium benefits plus exclusive seating and after-party access',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              'Rs. $price',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _calculateTotal() {
    double basePrice = widget.tournament.entryFee * _selectedParticipants;

    // Add ticket type price if selected
    if (_selectedTicketType != null &&
        widget.tournament.ticketTypes.isNotEmpty) {
      double ticketPrice =
          widget.tournament.ticketTypes[_selectedTicketType] ?? 0;
      basePrice += ticketPrice * _selectedParticipants;
    }

    return basePrice;
  }

  void _handleRegistration() {
    // Create a sample booking object using the correct Booking constructor
    final booking = Booking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      userId: '2', // Current logged in user ID
      userName: 'John Doe',
      tournamentId: widget.tournament.id,
      tournamentName: widget.tournament.name,
      bookingDate: DateTime.now(),
      status: BookingStatus.confirmed,
      amountPaid: _calculateTotal(),
      numberOfParticipants: _selectedParticipants,
      discount: 0.0,
      notes: _selectedTicketType != null
          ? 'Ticket type: $_selectedTicketType'
          : null,
    );

    // Close the bottom sheet
    Navigator.pop(context);

    // Show a success animation or loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('Processing your payment...'),
              ],
            ),
          ),
        );
      },
    );

    // Simulate payment processing delay
    Future.delayed(const Duration(seconds: 2), () {
      // Close the loading dialog
      Navigator.pop(context);

      // Navigate to the success screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(
            tournament: widget.tournament,
            booking: booking,
          ),
        ),
      );
    });
  }
}
