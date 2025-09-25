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
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: PageController(
              viewportFraction: tournaments.length == 1 ? 1.0 : 0.85,
            ),
            itemCount: tournaments.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDarkColor,
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
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => onTournamentTap?.call(tournament),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Image with Status Overlay
              Stack(
                children: [
                  // Tournament image
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: tournament.imageUrl != null
                        ? Image.network(
                            tournament.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppTheme.primaryColor.withOpacity(0.2),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: AppTheme.primaryColor,
                                      size: 40,
                                    ),
                                  ),
                                ),
                          )
                        : Container(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                Icons.emoji_events,
                                color: AppTheme.primaryColor,
                                size: 40,
                              ),
                            ),
                          ),
                  ),

                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tournament.statusColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tournament.status.name.toUpperCase(),
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

              // Tournament details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        tournament.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDarkColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppTheme.textMediumColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tournament.location,
                              style: const TextStyle(
                                color: AppTheme.textMediumColor,
                                fontSize: 11,
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
                            size: 12,
                            color: AppTheme.textMediumColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(tournament.startDate),
                            style: const TextStyle(
                              color: AppTheme.textMediumColor,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      const Spacer(),

                      // Entry fee and availability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightColor.withOpacity(
                                0.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '₹${tournament.entryFee.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppTheme.primaryDarkColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            '${tournament.currentParticipants}/${tournament.maxParticipants}',
                            style: const TextStyle(
                              color: AppTheme.textMediumColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Progress indicator
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
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
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
