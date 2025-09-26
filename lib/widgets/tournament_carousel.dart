import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../utils/app_theme.dart';

class TournamentCarousel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 12),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'No tournaments available',
                style: TextStyle(color: AppTheme.textMediumColor, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        SizedBox(
          height: 270, // Reduced height to prevent overflow
          child: PageView.builder(
            controller: PageController(
              viewportFraction: tournaments.length == 1
                  ? 0.92
                  : 0.85, // Reduced to prevent overflow
            ),
            padEnds: false,
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: _buildCarouselItem(context, tournaments[index]),
              );
            },
          ),
        ),
      ],
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
              title,
              style: const TextStyle(
                fontSize: 16, // Reduced font size
                fontWeight: FontWeight.bold,
                color: AppTheme.textDarkColor,
              ),
            ),
          ),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text('View All')),
        ],
      ),
    );
  }

  Widget _buildCarouselItem(BuildContext context, Tournament tournament) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ), // Add horizontal margin
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () => onTournamentTap?.call(tournament),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Image with Status Overlay
              Stack(
                children: [
                  // Tournament image
                  SizedBox(
                    height: 100, // Further reduced height to prevent overflow
                    width: double.infinity,
                    child: tournament.imageUrl != null
                        ? Image.network(
                            tournament.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        AppTheme.primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
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
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor.withOpacity(0.3),
                                  AppTheme.primaryColor.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                        horizontal: 10,
                        vertical: 6,
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
                ],
              ),

              // Tournament details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8), // Further reduced padding
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
                            size: 10, // Further reduced icon size
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 2), // Further reduced spacing
                          Expanded(
                            child: Text(
                              tournament.location,
                              style: const TextStyle(
                                color: AppTheme.textMediumColor,
                                fontSize: 11, // Reduced font size
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Date
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 10, // Further reduced icon size
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 2), // Further reduced spacing
                          Expanded(
                            child: Text(
                              _formatDate(tournament.startDate),
                              style: const TextStyle(
                                color: AppTheme.textMediumColor,
                                fontSize: 11, // Reduced font size
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3), // Reduced spacing

                      const Spacer(),

                      // Entry fee and Register button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Entry fee
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                '₹${tournament.entryFee.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10, // Reduced font size
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Register/View button
                          if (tournament.status == TournamentStatus.upcoming)
                            Flexible(
                              child: ElevatedButton(
                                onPressed:
                                    tournament.availabilityPercentage < 1.0
                                    ? () => onTournamentTap?.call(tournament)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      tournament.availabilityPercentage < 1.0
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6, // Further reduced padding
                                    vertical: 3, // Further reduced padding
                                  ),
                                  elevation: 1, // Reduced elevation
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  tournament.availabilityPercentage < 1.0
                                      ? 'Register'
                                      : 'Full',
                                  style: const TextStyle(
                                    fontSize: 10, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: OutlinedButton(
                                onPressed: () =>
                                    onTournamentTap?.call(tournament),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppTheme.primaryColor,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, // Reduced padding
                                    vertical: 4, // Reduced padding
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'View',
                                  style: const TextStyle(
                                    fontSize: 10, // Reduced font size
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4), // Reduced spacing
                      // Availability bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tournament.currentParticipants}/${tournament.maxParticipants} participants',
                            style: const TextStyle(
                              color: AppTheme.textMediumColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: tournament.availabilityPercentage,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                tournament.availabilityPercentage >= 1
                                    ? AppTheme.errorColor
                                    : tournament.availabilityPercentage >= 0.8
                                    ? AppTheme.warningColor
                                    : AppTheme.successColor,
                              ),
                              minHeight: 4,
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
        ), // Closing InkWell
      ), // Closing Card
    ); // Closing Container
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]}';
  }
}
