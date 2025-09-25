// Notification model for user notifications
class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionLink;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.isRead,
    this.actionLink,
  });

  // Sample notifications for demonstration
  static List<Notification> getSampleNotifications() {
    return [
      Notification(
        id: 'n1',
        userId: '2',
        title: 'Tournament Starting Soon',
        message:
            'Your registered tournament "Summer Chess Championship" will begin in 2 days.',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.reminder,
        isRead: false,
        actionLink: '/tournaments/1',
      ),
      Notification(
        id: 'n2',
        userId: '2',
        title: 'Booking Confirmed',
        message:
            'Your booking for "eSports League - League of Legends" has been confirmed.',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.booking,
        isRead: true,
        actionLink: '/bookings/b2',
      ),
      Notification(
        id: 'n3',
        userId: '2',
        title: 'New Tournament Available',
        message:
            'A new chess tournament "Winter Chess Challenge" is now open for registration.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.announcement,
        isRead: false,
      ),
      Notification(
        id: 'n4',
        userId: '1',
        title: 'New Booking Received',
        message: 'A new booking has been made for "Summer Chess Championship".',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        type: NotificationType.admin,
        isRead: false,
        actionLink: '/admin/bookings',
      ),
    ];
  }
}

// Enum representing the type of notification
enum NotificationType { booking, reminder, announcement, admin, system }
