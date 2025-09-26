import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';
import 'dart:math' as math;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late List<Animation<double>> _progressAnimations;
  final ScrollController _scrollController = ScrollController();

  // Sample leaderboard data
  final List<Map<String, dynamic>> _monthlyLeaderboard = [];
  final List<Map<String, dynamic>> _allTimeLeaderboard = [];
  final List<Map<String, dynamic>> _categoryLeaderboard = [];

  // Categories for filtering
  final List<String> _categories = [
    'All',
    'Chess',
    'Board Games',
    'eSports',
    'Cricket',
    'Football',
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _generateLeaderboardData();

    // Create progress animations for each leaderboard item
    _progressAnimations = List.generate(
      _allTimeLeaderboard.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.1 * index / _allTimeLeaderboard.length,
            0.1 + 0.9 * index / _allTimeLeaderboard.length,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    _animationController.forward();

    // Listen for tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _generateLeaderboardData() {
    // Get sample users and assign random scores
    final users = User.getSampleUsers();
    final random = math.Random();

    for (int i = 0; i < users.length; i++) {
      final user = users[i];

      // Generate monthly stats
      final monthlyStats = {
        'user': user,
        'rank': i + 1,
        'score': 500 + random.nextInt(1500),
        'tournaments': random.nextInt(5) + 1,
        'wins': random.nextInt(3),
      };

      // Generate all-time stats
      final allTimeStats = {
        'user': user,
        'rank': i + 1,
        'score': 1000 + random.nextInt(3000),
        'tournaments': 5 + random.nextInt(20),
        'wins': 1 + random.nextInt(15),
      };

      // Generate category stats
      final categoryStats = {
        'user': user,
        'rank': i + 1,
        'score': 800 + random.nextInt(2000),
        'tournaments': 3 + random.nextInt(10),
        'wins': 1 + random.nextInt(8),
        'category': user.preferredCategories?.isNotEmpty == true
            ? user.preferredCategories![0]
            : 'Chess',
      };

      _monthlyLeaderboard.add(monthlyStats);
      _allTimeLeaderboard.add(allTimeStats);
      _categoryLeaderboard.add(categoryStats);
    }

    // Sort by score
    _monthlyLeaderboard.sort(
      (a, b) => (b['score'] as int).compareTo(a['score'] as int),
    );
    _allTimeLeaderboard.sort(
      (a, b) => (b['score'] as int).compareTo(a['score'] as int),
    );
    _categoryLeaderboard.sort(
      (a, b) => (b['score'] as int).compareTo(a['score'] as int),
    );

    // Update ranks after sorting
    for (int i = 0; i < _monthlyLeaderboard.length; i++) {
      _monthlyLeaderboard[i]['rank'] = i + 1;
    }
    for (int i = 0; i < _allTimeLeaderboard.length; i++) {
      _allTimeLeaderboard[i]['rank'] = i + 1;
    }
    for (int i = 0; i < _categoryLeaderboard.length; i++) {
      _categoryLeaderboard[i]['rank'] = i + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Tournament Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image or gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    // Trophy icons
                    Positioned(
                      right: -50,
                      bottom: -20,
                      child: Icon(
                        Icons.emoji_events,
                        size: 200,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Monthly'),
                  Tab(text: 'All Time'),
                ],
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Category filter chips
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                          _animationController.reset();
                          _animationController.forward();
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Top 3 users
            Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _buildTop3Users(),
            ),

            // Rest of the leaderboard
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardList(_monthlyLeaderboard),
                  _buildLeaderboardList(_allTimeLeaderboard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop3Users() {
    final leaderboard = _tabController.index == 0
        ? _monthlyLeaderboard
        : _allTimeLeaderboard;

    // Filter by category if selected
    final filteredLeaderboard = _selectedCategory == 'All'
        ? leaderboard
        : leaderboard.where((item) {
            final user = item['user'] as User;
            return user.preferredCategories?.contains(_selectedCategory) ??
                false;
          }).toList();

    if (filteredLeaderboard.isEmpty) {
      return const Center(child: Text('No data available for this category'));
    }

    // Get top 3 users or fewer if less than 3 users
    final top3 = filteredLeaderboard.take(3).toList();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Second place
            if (top3.length > 1)
              _buildTopUserItem(
                top3[1],
                2,
                Colors.grey[400]!,
                _animationController.value * 0.8,
                140,
              ),

            // First place
            if (top3.isNotEmpty)
              _buildTopUserItem(
                top3[0],
                1,
                Colors.amber,
                _animationController.value,
                180,
              ),

            // Third place
            if (top3.length > 2)
              _buildTopUserItem(
                top3[2],
                3,
                Colors.brown[300]!,
                _animationController.value * 0.6,
                120,
              ),
          ],
        );
      },
    );
  }

  Widget _buildTopUserItem(
    Map<String, dynamic> userStats,
    int position,
    Color color,
    double animationValue,
    double maxHeight,
  ) {
    final user = userStats['user'] as User;
    final score = userStats['score'] as int;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(user.photoUrl!),
                  onBackgroundImageError: (_, __) =>
                      Container(color: Colors.grey[300]),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '#$position',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.name.split(' ')[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$score pts',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: animationValue * maxHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> leaderboard) {
    // Filter by category if selected
    final filteredLeaderboard = _selectedCategory == 'All'
        ? leaderboard
        : leaderboard.where((item) {
            final user = item['user'] as User;
            return user.preferredCategories?.contains(_selectedCategory) ??
                false;
          }).toList();

    if (filteredLeaderboard.isEmpty) {
      return const Center(child: Text('No data available for this category'));
    }

    // Skip top 3 users
    final remainingUsers = filteredLeaderboard.length > 3
        ? filteredLeaderboard.sublist(3)
        : <Map<String, dynamic>>[];

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: remainingUsers.length,
      itemBuilder: (context, index) {
        final userStats = remainingUsers[index];
        final user = userStats['user'] as User;
        final rank = userStats['rank'] as int;
        final score = userStats['score'] as int;
        final tournaments = userStats['tournaments'] as int;
        final wins = userStats['wins'] as int;

        // Get animation for this item
        final animation =
            _progressAnimations[index % _progressAnimations.length];

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - animation.value)),
              child: Opacity(
                opacity: animation.value,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.photoUrl!),
                          onBackgroundImageError: (_, __) =>
                              Container(color: Colors.grey[300]),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              '#$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 14,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text('$wins wins in $tournaments tournaments'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$score pts',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Show user profile or details
                      _showUserDetailsDialog(userStats);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> userStats) {
    final user = userStats['user'] as User;
    final rank = userStats['rank'] as int;
    final score = userStats['score'] as int;
    final tournaments = userStats['tournaments'] as int;
    final wins = userStats['wins'] as int;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 38,
                            backgroundImage: NetworkImage(user.photoUrl!),
                            onBackgroundImageError: (_, __) =>
                                Container(color: Colors.grey[300]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rank #$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$score pts',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildUserStatItem(
                          'Tournaments',
                          tournaments.toString(),
                        ),
                        _buildUserStatItem('Wins', wins.toString()),
                        _buildUserStatItem(
                          'Win Rate',
                          '${(wins / tournaments * 100).round()}%',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (user.preferredCategories?.isNotEmpty == true) ...[
                      const Text(
                        'Preferred Categories',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: user.preferredCategories!
                            .map(
                              (category) => Chip(
                                label: Text(category),
                                backgroundColor: AppTheme.primary.withOpacity(
                                  0.1,
                                ),
                                labelStyle: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 12,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      child: const Text('View Full Profile'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
