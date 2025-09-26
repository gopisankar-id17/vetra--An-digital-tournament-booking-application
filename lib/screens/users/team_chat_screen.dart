import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String? authorImageUrl;
  final DateTime timestamp;
  final List<String> attachments;
  final int commentsCount;
  int likesCount;
  bool isLiked;
  final bool isPinned;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    this.authorImageUrl,
    required this.timestamp,
    this.attachments = const [],
    this.commentsCount = 0,
    this.likesCount = 0,
    this.isLiked = false,
    this.isPinned = false,
  });

  // Sample announcements
  static List<Announcement> getSampleAnnouncements() {
    return [
      Announcement(
        id: 'ann1',
        title: 'Tournament Schedule Update',
        content:
            'Due to unforeseen circumstances, the weekend matches for the Cricket Premier League have been rescheduled. The new schedule is now available on the tournament details page. Please check your match times and venues.',
        authorName: 'Admin',
        authorImageUrl:
            'https://ui-avatars.com/api/?name=Admin&background=6f42c1&color=fff',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        attachments: ['schedule.pdf', 'venue_map.jpg'],
        commentsCount: 5,
        likesCount: 12,
        isPinned: true,
      ),
      Announcement(
        id: 'ann2',
        title: 'New Registration Process',
        content:
            'We\'ve simplified the registration process for all upcoming tournaments. You can now register directly from the tournament page without any additional steps. If you encounter any issues, please contact our support team.',
        authorName: 'Tournament Director',
        authorImageUrl:
            'https://ui-avatars.com/api/?name=Tournament+Director&background=435fc9&color=fff',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        commentsCount: 2,
        likesCount: 8,
      ),
      Announcement(
        id: 'ann3',
        title: 'COVID-19 Safety Protocols',
        content:
            'For the safety of all participants, please adhere to the COVID-19 safety protocols in place at all tournament venues. Masks are required in common areas, and sanitization stations will be available throughout the venue.',
        authorName: 'Safety Committee',
        authorImageUrl:
            'https://ui-avatars.com/api/?name=Safety+Committee&background=2a9d8f&color=fff',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        commentsCount: 7,
        likesCount: 23,
      ),
      Announcement(
        id: 'ann4',
        title: 'New eSports Tournament Added',
        content:
            'We\'re excited to announce a new eSports tournament: League of Legends Champion Cup! Registration opens next week. Limited spots available, so be sure to register early.',
        authorName: 'Gaming Division',
        authorImageUrl:
            'https://ui-avatars.com/api/?name=Gaming+Division&background=e76f51&color=fff',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        commentsCount: 15,
        likesCount: 42,
      ),
    ];
  }
}

class TeamChatScreen extends StatefulWidget {
  const TeamChatScreen({Key? key}) : super(key: key);

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final List<Announcement> _announcements =
      Announcement.getSampleAnnouncements();
  final TextEditingController _commentController = TextEditingController();
  String? _selectedAnnouncementId;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _announcements.length,
        itemBuilder: (context, index) {
          final announcement = _announcements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    final bool isExpanded = _selectedAnnouncementId == announcement.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: announcement.isPinned
            ? BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.5),
                width: 1.5,
              )
            : BorderSide.none,
      ),
      child: Column(
        children: [
          // Header with author info
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            leading: CircleAvatar(
              backgroundImage: announcement.authorImageUrl != null
                  ? NetworkImage(announcement.authorImageUrl!)
                  : null,
              child: announcement.authorImageUrl == null
                  ? Text(
                      announcement.authorName.substring(0, 1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.authorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  _formatTimestamp(announcement.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              announcement.isPinned ? 'Pinned announcement' : 'Announcement',
              style: TextStyle(
                fontSize: 12,
                color: announcement.isPinned
                    ? AppTheme.primaryColor
                    : Colors.grey.shade600,
              ),
            ),
            trailing: announcement.isPinned
                ? const Icon(
                    Icons.push_pin,
                    size: 16,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),

          // Announcement title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Announcement content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              announcement.content,
              style: const TextStyle(fontSize: 14),
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          // Read more button
          if (announcement.content.split('\n').length > 3 ||
              announcement.content.length > 200)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedAnnouncementId == announcement.id) {
                    _selectedAnnouncementId = null;
                  } else {
                    _selectedAnnouncementId = announcement.id;
                  }
                });
              },
              child: Text(
                isExpanded ? 'Show less' : 'Read more',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          // Attachments
          if (announcement.attachments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: announcement.attachments.map((attachment) {
                  IconData iconData = Icons.insert_drive_file;
                  if (attachment.endsWith('.pdf')) {
                    iconData = Icons.picture_as_pdf;
                  } else if (attachment.endsWith('.jpg') ||
                      attachment.endsWith('.png') ||
                      attachment.endsWith('.jpeg')) {
                    iconData = Icons.image;
                  } else if (attachment.endsWith('.doc') ||
                      attachment.endsWith('.docx')) {
                    iconData = Icons.description;
                  } else if (attachment.endsWith('.xls') ||
                      attachment.endsWith('.xlsx')) {
                    iconData = Icons.table_chart;
                  }

                  return InkWell(
                    onTap: () {
                      // Handle attachment click
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading $attachment'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Chip(
                      avatar: Icon(
                        iconData,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      label: Text(attachment),
                      backgroundColor: Colors.grey.shade100,
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),

          // Actions row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Comments button
                InkWell(
                  onTap: () => _showCommentsSheet(announcement),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        size: 18,
                        color: AppTheme.textMediumColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.commentsCount.toString(),
                        style: const TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Like button
                InkWell(
                  onTap: () {
                    setState(() {
                      announcement.isLiked = !announcement.isLiked;
                      announcement.isLiked
                          ? announcement.likesCount += 1
                          : announcement.likesCount -= 1;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        announcement.isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 18,
                        color: announcement.isLiked
                            ? AppTheme.primaryColor
                            : AppTheme.textMediumColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        announcement.likesCount.toString(),
                        style: TextStyle(
                          color: announcement.isLiked
                              ? AppTheme.primaryColor
                              : AppTheme.textMediumColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Share button
                InkWell(
                  onTap: () {
                    // Handle share
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sharing coming soon'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.share_outlined,
                        size: 18,
                        color: AppTheme.textMediumColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: AppTheme.textMediumColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  void _showCommentsSheet(Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comments (${announcement.commentsCount})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: announcement.commentsCount,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    // This is a mock implementation
                    final isCurrentUser = index % 3 == 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          isCurrentUser
                              ? 'https://ui-avatars.com/api/?name=John+Doe&background=94c142&color=fff'
                              : 'https://ui-avatars.com/api/?name=User+${index + 1}&background=random&color=fff',
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            isCurrentUser ? 'John Doe' : 'User ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(announcement.commentsCount - index) * 10} min ago',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        'This is comment #${index + 1} for the announcement. Thanks for the information!',
                      ),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
              const Divider(),
              // Comment input field (read-only for users)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://ui-avatars.com/api/?name=John+Doe&background=94c142&color=fff',
                      ),
                      radius: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        enabled: false, // Read-only for users
                        decoration: InputDecoration(
                          hintText: 'Only admins can post comments',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: null, // Disabled for users
                      icon: const Icon(Icons.send),
                      color: Colors.grey,
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
}
