import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../utils/app_theme.dart';
import '../../widgets/tournament_card.dart';

class TournamentSearchScreen extends StatefulWidget {
  const TournamentSearchScreen({Key? key}) : super(key: key);

  @override
  State<TournamentSearchScreen> createState() => _TournamentSearchScreenState();
}

class _TournamentSearchScreenState extends State<TournamentSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Tournament> _tournaments = [];
  List<Tournament> _filteredTournaments = [];

  // Filter states
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _selectedLocation;
  String? _selectedType;
  bool _showFilters = false;

  final List<String> _availableLocations = [];
  final List<String> _tournamentTypes = [];

  @override
  void initState() {
    super.initState();
    _initData();
    _searchController.addListener(_filterTournaments);
  }

  void _initData() {
    // Get all tournaments
    _tournaments = Tournament.getSampleTournaments();
    _filteredTournaments = List.from(_tournaments);

    // Extract unique locations and types for filters
    Set<String> locationSet = {};
    Set<String> typeSet = {};

    for (var tournament in _tournaments) {
      locationSet.add(tournament.location);
      for (var category in tournament.categories) {
        typeSet.add(category);
      }
    }

    _availableLocations.addAll(locationSet);
    _tournamentTypes.addAll(typeSet);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTournaments() {
    final String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredTournaments = _tournaments.where((tournament) {
        // Text search filter
        final nameMatches = tournament.name.toLowerCase().contains(query);
        final locationMatches = tournament.location.toLowerCase().contains(
          query,
        );
        final descriptionMatches = tournament.description
            .toLowerCase()
            .contains(query);
        final categoryMatches = tournament.categories.any(
          (cat) => cat.toLowerCase().contains(query),
        );

        bool matches =
            nameMatches ||
            locationMatches ||
            descriptionMatches ||
            categoryMatches;

        // Date filters
        if (_startDateFilter != null) {
          matches = matches && tournament.startDate.isAfter(_startDateFilter!);
        }
        if (_endDateFilter != null) {
          matches = matches && tournament.endDate.isBefore(_endDateFilter!);
        }

        // Location filter
        if (_selectedLocation != null && _selectedLocation!.isNotEmpty) {
          matches = matches && tournament.location == _selectedLocation;
        }

        // Type filter
        if (_selectedType != null && _selectedType!.isNotEmpty) {
          matches = matches && tournament.categories.contains(_selectedType);
        }

        return matches;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _startDateFilter = null;
      _endDateFilter = null;
      _selectedLocation = null;
      _selectedType = null;
      _showFilters = false;
    });
    _filterTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Tournaments'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tournaments...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Filter panel
          if (_showFilters) _buildFilterPanel(),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredTournaments.length} tournaments found',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMediumColor,
                  ),
                ),
                if (_startDateFilter != null ||
                    _endDateFilter != null ||
                    _selectedLocation != null ||
                    _selectedType != null)
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear filters'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),

          // Tournament list
          Expanded(
            child: _filteredTournaments.isEmpty
                ? const Center(
                    child: Text(
                      'No tournaments found',
                      style: TextStyle(
                        color: AppTheme.textMediumColor,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTournaments.length,
                    itemBuilder: (context, index) {
                      return TournamentCard(
                        tournament: _filteredTournaments[index],
                        onTap: () {
                          // View tournament details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Viewing ${_filteredTournaments[index].name}',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Tournaments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Date range filter
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _startDateFilter ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDateFilter = picked;
                          });
                          _filterTournaments();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              _startDateFilter != null
                                  ? '${_startDateFilter!.day}/${_startDateFilter!.month}/${_startDateFilter!.year}'
                                  : 'Select',
                              style: TextStyle(
                                color: _startDateFilter != null
                                    ? AppTheme.textDarkColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Date'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _endDateFilter ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDateFilter = picked;
                          });
                          _filterTournaments();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              _endDateFilter != null
                                  ? '${_endDateFilter!.day}/${_endDateFilter!.month}/${_endDateFilter!.year}'
                                  : 'Select',
                              style: TextStyle(
                                color: _endDateFilter != null
                                    ? AppTheme.textDarkColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Location filter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Location'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                hint: const Text('Any location'),
                isExpanded: true,
                items: _availableLocations
                    .map(
                      (location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                  _filterTournaments();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tournament type filter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tournament Type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                hint: const Text('Any type'),
                isExpanded: true,
                items: _tournamentTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                  _filterTournaments();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
