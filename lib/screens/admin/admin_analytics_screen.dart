import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../models/tournament.dart';
import '../../models/booking.dart';
import '../../models/user.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This month';

  // Sample analytics data
  int _totalUsers = 1458;
  int _activeUsers = 842;
  int _newUsers = 127;
  double _userGrowth = 12.4;

  int _totalTournaments = 28;
  int _activeTournaments = 8;
  int _upcomingTournaments = 14;
  int _completedTournaments = 6;

  int _totalBookings = 635;
  int _totalRevenue = 127000;
  double _revenueGrowth = 8.7;

  // Sample period options
  final List<String> _periodOptions = [
    'Today',
    'This week',
    'This month',
    'Last 3 months',
    'This year',
    'All time',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Just pop back to previous screen
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMediumColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Tournaments'),
            Tab(text: 'Users'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Select time period',
            onSelected: (String value) {
              setState(() {
                _selectedPeriod = value;
                // In a real app, you'd fetch new data for the selected period
              });
            },
            itemBuilder: (BuildContext context) => _periodOptions
                .map(
                  (String period) =>
                      PopupMenuItem<String>(value: period, child: Text(period)),
                )
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export data',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting analytics data...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildTournamentsTab(),
            _buildUsersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(),
          const SizedBox(height: 16),

          // Summary cards - top row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Users',
                  _totalUsers.toString(),
                  Icons.people,
                  Colors.blue,
                  '+$_newUsers this month',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Revenue',
                  '₹${_formatNumber(_totalRevenue)}',
                  Icons.currency_rupee,
                  Colors.green,
                  '+${_revenueGrowth.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary cards - bottom row
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Active Tournaments',
                  _activeTournaments.toString(),
                  Icons.emoji_events,
                  Colors.amber,
                  '$_upcomingTournaments upcoming',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Bookings',
                  _totalBookings.toString(),
                  Icons.confirmation_number,
                  Colors.purple,
                  'This month',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Registration trend chart
          _buildChartCard(
            title: 'User Registration Trend',
            height: 200,
            child: Center(
              child: Image.network(
                'https://quickchart.io/chart?c={type:%27line%27,data:{labels:[%27Jan%27,%27Feb%27,%27Mar%27,%27Apr%27,%27May%27,%27Jun%27,%27Jul%27,%27Aug%27,%27Sep%27],datasets:[{label:%27New%20Users%27,data:[65,59,80,81,56,55,72,60,95],fill:false,borderColor:%27%236f42c1%27}]}}',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Revenue chart
          _buildChartCard(
            title: 'Revenue by Tournament Type',
            height: 200,
            child: Center(
              child: Image.network(
                'https://quickchart.io/chart?c={type:%27doughnut%27,data:{labels:[%27Cricket%27,%27Football%27,%27eSports%27,%27Basketball%27,%27Others%27],datasets:[{data:[35,25,15,15,10],backgroundColor:[%27%236f42c1%27,%27%2328a745%27,%27%23ffc107%27,%27%23007bff%27,%27%23dc3545%27]}]}}',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Most active tournaments
          _buildSectionHeader('Most Active Tournaments'),
          const SizedBox(height: 12),
          _buildMostActiveTournaments(),
          const SizedBox(height: 24),

          // Most active users
          _buildSectionHeader('Most Active Users'),
          const SizedBox(height: 12),
          _buildMostActiveUsers(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTournamentsTab() {
    final List<Tournament> tournaments = Tournament.getSampleTournaments();

    // Group tournaments by status
    final upcomingTournaments = tournaments
        .where((t) => t.status == TournamentStatus.upcoming)
        .toList();
    final ongoingTournaments = tournaments
        .where((t) => t.status == TournamentStatus.ongoing)
        .toList();
    final completedTournaments = tournaments
        .where((t) => t.status == TournamentStatus.completed)
        .toList();

    // Calculate tournament statistics
    final Map<String, int> categoryCount = {};
    for (var tournament in tournaments) {
      for (var category in tournament.categories) {
        categoryCount[category] = (categoryCount[category] ?? 0) + 1;
      }
    }

    final List<MapEntry<String, int>> topCategories =
        categoryCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(),
          const SizedBox(height: 16),

          // Tournament status summary
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Upcoming',
                  upcomingTournaments.length.toString(),
                  Icons.event,
                  Colors.blue,
                  '${(upcomingTournaments.length / tournaments.length * 100).toStringAsFixed(0)}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Ongoing',
                  ongoingTournaments.length.toString(),
                  Icons.play_circle,
                  Colors.green,
                  '${(ongoingTournaments.length / tournaments.length * 100).toStringAsFixed(0)}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Completed',
                  completedTournaments.length.toString(),
                  Icons.check_circle,
                  Colors.grey,
                  '${(completedTournaments.length / tournaments.length * 100).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tournament categories chart
          _buildChartCard(
            title: 'Tournament Categories',
            height: 200,
            child: Center(
              child: Image.network(
                'https://quickchart.io/chart?c={type:%27bar%27,data:{labels:${_formatLabelsForChart(topCategories.take(5).map((e) => e.key).toList())},datasets:[{label:%27Number%20of%20Tournaments%27,data:[${topCategories.take(5).map((e) => e.value).join(',')}],backgroundColor:%27%236f42c1%27}]}}',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Registration fill rate
          _buildChartCard(
            title: 'Tournament Registration Fill Rate',
            height: 200,
            child: Center(
              child: Image.network(
                'https://quickchart.io/chart?c={type:%27horizontalBar%27,data:{labels:${_formatLabelsForChart(tournaments.take(5).map((t) => t.name).toList())},datasets:[{label:%27Fill%20Rate%20(%25)%27,data:[${tournaments.take(5).map((t) => (t.currentParticipants / t.maxParticipants * 100).round()).join(',')}],backgroundColor:%27%2328a745%27}]},options:{scales:{xAxes:[{ticks:{max:100}}]}}}',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Most popular tournaments
          _buildSectionHeader('Most Popular Tournaments'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              final tournament = tournaments[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryLightColor,
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  tournament.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${tournament.currentParticipants}/${tournament.maxParticipants} participants • ${tournament.categories.join(', ')}',
                ),
                trailing: Text(
                  '${(tournament.currentParticipants / tournament.maxParticipants * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    // User demographics data
    final Map<String, double> genderDistribution = {
      'Male': 62.5,
      'Female': 35.2,
      'Other': 2.3,
    };

    final Map<String, double> ageDistribution = {
      '18-24': 28.4,
      '25-34': 42.6,
      '35-44': 18.3,
      '45-54': 7.8,
      '55+': 2.9,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodHeader(),
          const SizedBox(height: 16),

          // User stats summary
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Users',
                  _formatNumber(_totalUsers),
                  Icons.people,
                  Colors.blue,
                  '+$_newUsers this month',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Active Users',
                  _formatNumber(_activeUsers),
                  Icons.person_outline,
                  Colors.green,
                  '${(_activeUsers / _totalUsers * 100).toStringAsFixed(0)}% of total',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'New Users',
                  _formatNumber(_newUsers),
                  Icons.person_add,
                  Colors.amber,
                  '+${_userGrowth.toStringAsFixed(1)}% growth',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Avg. Bookings',
                  (_totalBookings / _activeUsers).toStringAsFixed(1),
                  Icons.confirmation_number,
                  Colors.purple,
                  'Per active user',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User growth chart
          _buildChartCard(
            title: 'User Growth Trend',
            height: 200,
            child: Center(
              child: Image.network(
                'https://quickchart.io/chart?c={type:%27line%27,data:{labels:[%27Jan%27,%27Feb%27,%27Mar%27,%27Apr%27,%27May%27,%27Jun%27,%27Jul%27,%27Aug%27,%27Sep%27],datasets:[{label:%27Total%20Users%27,data:[1024,1125,1210,1310,1350,1390,1412,1436,1458],fill:false,borderColor:%27%236f42c1%27},{label:%27Active%20Users%27,data:[720,742,765,780,795,810,825,832,842],fill:false,borderColor:%27%2328a745%27}]}}',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Gender distribution
          _buildChartCard(
            title: 'Gender Distribution',
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Image.network(
                    'https://quickchart.io/chart?c={type:%27pie%27,data:{labels:${_formatLabelsForChart(genderDistribution.keys.toList())},datasets:[{data:[${genderDistribution.values.join(',')}],backgroundColor:[%27%236f42c1%27,%27%2328a745%27,%27%23ffc107%27]}]}}',
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: genderDistribution.entries.map((entry) {
                      Color color;
                      if (entry.key == 'Male') {
                        color = AppTheme.primaryColor;
                      } else if (entry.key == 'Female') {
                        color = Colors.green;
                      } else {
                        color = Colors.amber;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Add Flexible to prevent text overflow
                            Flexible(
                              child: Text(
                                entry.key,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Use fixed spacing instead of Spacer
                            Text(
                              '${entry.value.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Age distribution
          _buildChartCard(
            title: 'Age Distribution',
            height: 200,
            child: Center(
              child: Image.network(
                'https://quickchart.io/chart?c={type:%27bar%27,data:{labels:${_formatLabelsForChart(ageDistribution.keys.toList())},datasets:[{label:%27Percentage%20of%20Users%27,data:[${ageDistribution.values.join(',')}],backgroundColor:%27%236f42c1%27}]}}',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Top active users
          _buildSectionHeader('Most Active Users'),
          const SizedBox(height: 12),
          _buildMostActiveUsers(),
        ],
      ),
    );
  }

  Widget _buildPeriodHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Analytics for $_selectedPeriod',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            // Refresh data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Refreshing data...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh'),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                // Wrap the indicator in a flexible widget with overflow protection
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          subtitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required double height,
    required Widget child,
  }) {
    // Use reduced height for mobile display to prevent overflow
    final adjustedHeight = MediaQuery.of(context).size.width < 600
        ? height * 0.7
        : height;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Show chart options
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: adjustedHeight, child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () {
            // View all
          },
          child: const Text('View All'),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
    );
  }

  Widget _buildMostActiveTournaments() {
    // Sample data for most active tournaments
    final List<Tournament> tournaments = Tournament.getSampleTournaments();
    tournaments.sort(
      (a, b) => b.currentParticipants.compareTo(a.currentParticipants),
    );

    return Column(
      children: tournaments.take(3).map((tournament) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Tournament image or icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: tournament.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tournament.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.emoji_events,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.emoji_events,
                          color: AppTheme.primaryColor,
                        ),
                ),
                const SizedBox(width: 12),

                // Tournament details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${tournament.currentParticipants}/${tournament.maxParticipants} participants',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Fill rate indicator
                Container(
                  width: 70, // Fixed width to avoid overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(tournament.currentParticipants / tournament.maxParticipants * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Fill rate',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMediumColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMostActiveUsers() {
    // Sample data for most active users
    final List<User> users = [
      User(
        id: 'u1',
        name: 'Alex Johnson',
        email: 'alex@example.com',
        phone: '+91 98765 43210',
        address: 'Mumbai',
        photoUrl: 'https://ui-avatars.com/api/?name=Alex+J&background=random',
        isAdmin: false,
      ),
      User(
        id: 'u2',
        name: 'Priya Sharma',
        email: 'priya@example.com',
        phone: '+91 87654 32109',
        address: 'Delhi',
        photoUrl: 'https://ui-avatars.com/api/?name=Priya+S&background=random',
        isAdmin: false,
      ),
      User(
        id: 'u3',
        name: 'Raj Kumar',
        email: 'raj@example.com',
        phone: '+91 76543 21098',
        address: 'Bangalore',
        photoUrl:
            'https://ui-avatars.com/api/?name=Raj+Kumar&background=random',
        isAdmin: false,
      ),
    ];

    // Sample booking counts
    final Map<String, int> bookingCounts = {'u1': 12, 'u2': 9, 'u3': 7};

    return Column(
      children: users.map((user) {
        final bookingCount = bookingCounts[user.id] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    user.photoUrl ??
                        'https://ui-avatars.com/api/?name=${user.name}',
                  ),
                ),
                const SizedBox(width: 12),

                // User details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Booking count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$bookingCount bookings',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  String _formatLabelsForChart(List<String> labels) {
    return '[${labels.map((label) => "'$label'").join(',')}]';
  }
}
