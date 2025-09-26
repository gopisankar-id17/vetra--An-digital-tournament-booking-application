import 'package:flutter/material.dart';
import 'package:vetra/models/tournament.dart';
import '../utils/app_theme.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;
  final bool showActions;

  const TournamentCard({
    super.key,
    required this.tournament,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Image with Status Overlay
            Stack(
              children: [
                // Tournament image
                SizedBox(
                  height: 150,
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
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: tournament.statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tournament.status.name.toUpperCase(),
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

            // Tournament details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tournament.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDarkColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location and date
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.textMediumColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tournament.location,
                          style: const TextStyle(
                            color: AppTheme.textMediumColor,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppTheme.textMediumColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatDate(tournament.startDate)} - ${_formatDate(tournament.endDate)}',
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Entry fee and availability
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLightColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹${tournament.entryFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.primaryDarkColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${tournament.currentParticipants}/${tournament.maxParticipants} Participants',
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress indicator
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tournament.categories.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: AppTheme.primaryColor.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (showActions) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.info_outline,
                          label: 'Details',
                          onTap: onTap,
                        ),
                        if (tournament.status == TournamentStatus.upcoming &&
                            tournament.availabilityPercentage < 1)
                          _buildActionButton(
                            context,
                            icon: Icons.app_registration,
                            label: 'Register',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Registration feature coming soon',
                                  ),
                                ),
                              );
                            },
                          ),
                        if (tournament.status == TournamentStatus.upcoming ||
                            tournament.status == TournamentStatus.ongoing)
                          _buildActionButton(
                            context,
                            icon: Icons.share,
                            label: 'Share',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Share feature coming soon'),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
