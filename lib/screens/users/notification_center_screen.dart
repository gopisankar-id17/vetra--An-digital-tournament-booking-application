import 'package:flutter/material.dart';
import '../../models/notification.dart' as model;
import '../../utils/app_theme.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({Key? key}) : super(key: key);

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<model.Notification> _notifications;
  late List<model.Notification> _importantNotifications;
  late List<model.Notification> _generalNotifications;
  late List<model.Notification> _resultNotifications;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  void _loadNotifications() {
    // Load sample notifications for the current user (ID: '2')
    _notifications = model.Notification.getSampleNotifications()
        .where((notification) => notification.userId == '2')
        .toList();

    // Filter by category
    _importantNotifications = _notifications
        .where(
          (notification) =>
              notification.type == model.NotificationType.alert ||
              notification.type == model.NotificationType.schedule,
        )
        .toList();

    _generalNotifications = _notifications
        .where(
          (notification) =>
              notification.type == model.NotificationType.announcement ||
              notification.type == model.NotificationType.reminder,
        )
        .toList();

    _resultNotifications = _notifications
        .where(
          (notification) => notification.type == model.NotificationType.result,
        )
        .toList();
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
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMediumColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Important'),
            Tab(text: 'General'),
            Tab(text: 'Results'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'markAllRead') {
                _markAllAsRead();
              } else if (value == 'settings') {
                _openNotificationSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'markAllRead',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text('Notification settings'),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_importantNotifications),
          _buildNotificationList(_generalNotifications),
          _buildNotificationList(_resultNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<model.Notification> notifications) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No notifications',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _loadNotifications();
        });
      },
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationItem(notification);
        },
      ),
    );
  }

  Widget _buildNotificationItem(model.Notification notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case model.NotificationType.alert:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.red;
        break;
      case model.NotificationType.schedule:
        iconData = Icons.event;
        iconColor = Colors.orange;
        break;
      case model.NotificationType.result:
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case model.NotificationType.announcement:
        iconData = Icons.campaign;
        iconColor = AppTheme.primaryColor;
        break;
      case model.NotificationType.reminder:
        iconData = Icons.notifications_active;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        // Handle dismiss (delete notification)
        setState(() {
          _notifications.remove(notification);
          _importantNotifications.remove(notification);
          _generalNotifications.remove(notification);
          _resultNotifications.remove(notification);
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(iconData, color: iconColor),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.body),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(notification.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () => _openNotificationDetail(notification),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor,
                  ),
                ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      // More than a week ago, show date
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      // Days ago
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      // Hours ago
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      // Just now
      return 'just now';
    }
  }

  void _openNotificationDetail(model.Notification notification) {
    // Mark as read
    if (!notification.isRead) {
      setState(() {
        notification.isRead = true;
      });
    }

    // Show notification detail
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getTypeIcon(notification.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _formatTimestamp(notification.timestamp),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Text(notification.body, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              if (notification.actionText != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle notification action
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Action: ${notification.actionText}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(notification.actionText!),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _getTypeIcon(model.NotificationType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case model.NotificationType.alert:
        iconData = Icons.warning_amber_rounded;
        iconColor = Colors.red;
        break;
      case model.NotificationType.schedule:
        iconData = Icons.event;
        iconColor = Colors.orange;
        break;
      case model.NotificationType.result:
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case model.NotificationType.announcement:
        iconData = Icons.campaign;
        iconColor = AppTheme.primaryColor;
        break;
      case model.NotificationType.reminder:
        iconData = Icons.notifications_active;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(iconData, color: iconColor),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openNotificationSettings() {
    // Navigate to notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
