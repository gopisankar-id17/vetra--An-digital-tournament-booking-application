import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../utils/app_theme.dart';
import 'package:flutter/scheduler.dart';

class TournamentCarousel extends StatefulWidget {
  final List<Tournament> tournaments;
  final String title;
  final VoidCallback? onViewAll;
  final Function(Tournament)? onTournamentTap;

  const TournamentCarousel({
    super.key,
    required this.tournaments,
    required this.title,
    this.onViewAll,
    this.onTournamentTap,
  });

  @override
  State<TournamentCarousel> createState() => _TournamentCarouselState();
}

class _TournamentCarouselState extends State<TournamentCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_pageController.page!.round() != _currentPage) {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tournaments.isEmpty) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No tournaments available',
                  style: TextStyle(
                    color: AppTheme.textMediumColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          SizedBox(
            height: 320, // Reduced height for better appearance
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.tournaments.length,
              itemBuilder: (context, index) {
                // Calculate the distance from the current page for the scale effect
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = (_pageController.page! - index).abs();
                      value = (1 - (value * 0.15).clamp(0.0, 1.0));
                    }
                    return Transform.scale(
                      scale: Curves.easeOutQuint.transform(value),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: _buildCarouselItem(
                      context,
                      widget.tournaments[index],
                      index == _currentPage,
                    ),
                  ),
                );
              },
            ),
          ),
          // Carousel indicators removed as per request
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDarkColor,
              ),
            ),
          ),
          if (widget.onViewAll != null)
            TextButton.icon(
              onPressed: widget.onViewAll,
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('View All'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(
    BuildContext context,
    Tournament tournament,
    bool isCurrentPage,
  ) {
    return Hero(
      tag: 'tournament_${tournament.id}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onTournamentTap?.call(tournament),
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tournament Image with Status Overlay
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Tournament image
                        SizedBox(
                          height: 120, // Reduced image height
                          width: double.infinity,
                          child: tournament.imageUrl != null
                              ? Image.network(
                                  tournament.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.1),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.emoji_events,
                                            color: AppTheme.primaryColor,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.emoji_events,
                                      color: AppTheme.primaryColor,
                                      size: 50,
                                    ),
                                  ),
                                ),
                        ),

                        // Status badge
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, // Reduced padding
                              vertical: 4, // Reduced padding
                            ),
                            decoration: BoxDecoration(
                              color: tournament.statusColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              tournament.status.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),

                        // Prize overlay
                        if (tournament.prizes != null)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6, // Reduced padding
                                horizontal: 10, // Reduced padding
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events_outlined,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Prize: ${tournament.prizes}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Tournament details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8), // Reduced padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            tournament.name,
                            style: const TextStyle(
                              fontSize: 14, // Reduced font size
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDarkColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4), // Reduced spacing
                          // Location
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  tournament.location,
                                  style: const TextStyle(
                                    color: AppTheme.textMediumColor,
                                    fontSize: 11, // Smaller font
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2), // Reduced spacing
                          // Date
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatDateRange(
                                    tournament.startDate,
                                    tournament.endDate,
                                  ),
                                  style: const TextStyle(
                                    color: AppTheme.textMediumColor,
                                    fontSize: 11, // Smaller font
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 6), // Reduced spacing
                          // Availability bar
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${tournament.currentParticipants}/${tournament.maxParticipants}',
                                      style: const TextStyle(
                                        color: AppTheme.textMediumColor,
                                        fontSize: 11, // Smaller font
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Entry fee with flexible width
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5, // Reduced padding
                                        vertical: 3, // Reduced padding
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        '₹${tournament.entryFee.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11, // Smaller font
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4), // Reduced spacing
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: tournament.availabilityPercentage,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    tournament.availabilityPercentage >= 1
                                        ? AppTheme.errorColor
                                        : tournament.availabilityPercentage >=
                                              0.8
                                        ? AppTheme.warningColor
                                        : AppTheme.successColor,
                                  ),
                                  minHeight: 4, // Reduced progress bar height
                                ),
                              ),
                              const SizedBox(height: 8), // Reduced spacing
                              // Register/View button
                              SizedBox(
                                width: double.infinity,
                                child:
                                    tournament.status ==
                                        TournamentStatus.upcoming
                                    ? ElevatedButton(
                                        onPressed:
                                            tournament.availabilityPercentage <
                                                1.0
                                            ? () => widget.onTournamentTap
                                                  ?.call(tournament)
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              tournament
                                                      .availabilityPercentage <
                                                  1.0
                                              ? AppTheme.primaryColor
                                              : Colors.grey,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4, // Reduced padding
                                          ),
                                          visualDensity: VisualDensity
                                              .compact, // More compact button
                                        ),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            tournament.availabilityPercentage <
                                                    1.0
                                                ? 'Register'
                                                : 'Fully Booked',
                                            style: const TextStyle(
                                              fontSize: 13, // Smaller font
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    : OutlinedButton(
                                        onPressed: () => widget.onTournamentTap
                                            ?.call(tournament),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              AppTheme.primaryColor,
                                          side: const BorderSide(
                                            color: AppTheme.primaryColor,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4, // Reduced padding
                                          ),
                                          visualDensity: VisualDensity
                                              .compact, // More compact button
                                        ),
                                        child: const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'View',
                                            style: TextStyle(
                                              fontSize: 13, // Smaller font
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method used in date formatting
  // This is kept for future use in case we need to format single dates

  String _formatDateRange(DateTime start, DateTime end) {
    // Use shorter format to prevent overflow
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}-${end.day} ${_getMonthName(start.month)}';
    } else if (start.year == end.year) {
      return '${start.day} ${_getMonthName(start.month)}-${end.day} ${_getMonthName(end.month)}';
    } else {
      return '${start.day}/${start.month}/${start.year.toString().substring(2)}-${end.day}/${end.month}/${end.year.toString().substring(2)}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
