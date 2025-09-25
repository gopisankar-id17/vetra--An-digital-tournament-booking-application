import 'package:flutter/material.dart';
import '../models/notification.dart' as model;
import '../utils/app_theme.dart';

class NotificationCard extends StatelessWidget {
  final model.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead
          ? Colors.white
          : AppTheme.primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getTypeColor().withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 24),
                ),
              ),

              const SizedBox(width: 16),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: AppTheme.textDarkColor,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Message
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMediumColor,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Timestamp and type
                    Row(
                      children: [
                        // Timestamp
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textLightColor,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.type.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getTypeColor(),
                            ),
                          ),
                        ),

                        // Read/unread indicator
                        if (!notification.isRead && onMarkAsRead != null) ...[
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: onMarkAsRead,
                            tooltip: 'Mark as read',
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case model.NotificationType.booking:
        return AppTheme.infoColor;
      case model.NotificationType.reminder:
        return AppTheme.warningColor;
      case model.NotificationType.announcement:
        return AppTheme.secondaryColor;
      case model.NotificationType.admin:
        return AppTheme.primaryColor;
      case model.NotificationType.system:
        return AppTheme.textMediumColor;
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case model.NotificationType.booking:
        return Icons.calendar_today;
      case model.NotificationType.reminder:
        return Icons.alarm;
      case model.NotificationType.announcement:
        return Icons.campaign;
      case model.NotificationType.admin:
        return Icons.admin_panel_settings;
      case model.NotificationType.system:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
