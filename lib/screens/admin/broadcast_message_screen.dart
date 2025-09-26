import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';
import 'dart:async';

class BroadcastMessageScreen extends StatefulWidget {
  final User? adminUser;

  const BroadcastMessageScreen({Key? key, this.adminUser}) : super(key: key);

  @override
  State<BroadcastMessageScreen> createState() => _BroadcastMessageScreenState();
}

class _BroadcastMessageScreenState extends State<BroadcastMessageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controller for the message form
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Target audience selection
  final List<String> _targetOptions = [
    'All Users',
    'Tournament Players',
    'Admin Team',
    'Custom Selection',
  ];
  String _selectedTarget = 'All Users';

  // Priority selection
  final List<String> _priorityOptions = ['Normal', 'High', 'Urgent'];
  String _selectedPriority = 'Normal';

  // Scheduling options
  bool _scheduleForLater = false;
  DateTime _scheduledDateTime = DateTime.now().add(const Duration(hours: 1));

  // Selected users when using custom selection
  final List<User> _allUsers = User.getSampleUsers();
  final List<String> _selectedUserIds = [];

  // Animation controllers
  late AnimationController _sendAnimationController;
  late Animation<double> _sendProgressAnimation;
  bool _isSending = false;
  bool _showSuccess = false;

  // Broadcast history
  final List<BroadcastMessage> _broadcastHistory = [
    BroadcastMessage(
      id: 'msg1',
      title: 'Tournament Schedule Change',
      message:
          'Please note that the Chess Championship scheduled for this weekend has been postponed to next week due to venue unavailability.',
      target: 'Tournament Players',
      priority: 'High',
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'Delivered',
      deliveryStats: DeliveryStats(sent: 128, delivered: 124, read: 98),
      senderId: 'admin1',
    ),
    BroadcastMessage(
      id: 'msg2',
      title: 'New Feature Announcement',
      message:
          'We are excited to announce our new team chat feature! You can now communicate with your team members directly within the app.',
      target: 'All Users',
      priority: 'Normal',
      sentAt: DateTime.now().subtract(const Duration(days: 5)),
      status: 'Delivered',
      deliveryStats: DeliveryStats(sent: 1458, delivered: 1423, read: 1056),
      senderId: 'admin1',
    ),
    BroadcastMessage(
      id: 'msg3',
      title: 'System Maintenance',
      message:
          'The app will be unavailable for maintenance on Sunday, 2 AM to 4 AM. We apologize for any inconvenience caused.',
      target: 'All Users',
      priority: 'Urgent',
      sentAt: DateTime.now().subtract(const Duration(days: 10)),
      status: 'Delivered',
      deliveryStats: DeliveryStats(sent: 1420, delivered: 1395, read: 1102),
      senderId: 'admin1',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize the animation controller
    _sendAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _sendProgressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _sendAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _sendAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSending = false;
          _showSuccess = true;
        });

        // Reset after showing success
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _showSuccess = false;
              _titleController.clear();
              _messageController.clear();
              _selectedTarget = 'All Users';
              _selectedPriority = 'Normal';
              _scheduleForLater = false;
              _scheduledDateTime = DateTime.now().add(const Duration(hours: 1));
              _selectedUserIds.clear();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _tabController.dispose();
    _sendAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Messages'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMediumColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Compose'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildComposeTab(), _buildHistoryTab()],
      ),
    );
  }

  Widget _buildComposeTab() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message title
              _buildSectionHeader('Message Title'),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter a clear and concise title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 24),

              // Message content
              _buildSectionHeader('Message Content'),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type your broadcast message here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                maxLength: 1000,
              ),
              const SizedBox(height: 24),

              // Target audience
              _buildSectionHeader('Target Audience'),
              Card(
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedTarget,
                        decoration: const InputDecoration(
                          labelText: 'Select Target',
                          border: OutlineInputBorder(),
                        ),
                        items: _targetOptions.map((target) {
                          return DropdownMenuItem<String>(
                            value: target,
                            child: Text(target),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTarget = value!;

                            // Clear selected users if not using custom selection
                            if (_selectedTarget != 'Custom Selection') {
                              _selectedUserIds.clear();
                            }
                          });
                        },
                      ),

                      if (_selectedTarget == 'Custom Selection') ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Select Users:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._buildUserSelectionList(),
                        const SizedBox(height: 8),
                        Text(
                          '${_selectedUserIds.length} users selected',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textMediumColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Priority & Scheduling
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Priority'),
                        Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: _priorityOptions.map((priority) {
                                final isSelected =
                                    _selectedPriority == priority;
                                Color cardColor;
                                IconData icon;

                                switch (priority) {
                                  case 'Urgent':
                                    cardColor = Colors.red.shade100;
                                    icon = Icons.priority_high;
                                    break;
                                  case 'High':
                                    cardColor = Colors.orange.shade100;
                                    icon = Icons.arrow_upward;
                                    break;
                                  default:
                                    cardColor = Colors.green.shade100;
                                    icon = Icons.check_circle_outline;
                                }

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedPriority = priority;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? cardColor
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? cardColor.withOpacity(0.8)
                                            : Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          icon,
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : Colors.grey,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          priority,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Scheduling
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Scheduling'),
                        Card(
                          elevation: 0,
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Schedule toggle
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Schedule for later'),
                                  value: _scheduleForLater,
                                  onChanged: (value) {
                                    setState(() {
                                      _scheduleForLater = value;
                                    });
                                  },
                                ),

                                // DateTime picker
                                if (_scheduleForLater) ...[
                                  const SizedBox(height: 8),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text('Date & Time'),
                                    subtitle: Text(
                                      '${_scheduledDateTime.day}/${_scheduledDateTime.month}/${_scheduledDateTime.year} at ${_scheduledDateTime.hour}:${_scheduledDateTime.minute.toString().padLeft(2, '0')}',
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _scheduledDateTime,
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365),
                                        ),
                                      );

                                      if (date != null) {
                                        // ignore: use_build_context_synchronously
                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(
                                            _scheduledDateTime,
                                          ),
                                        );

                                        if (time != null) {
                                          setState(() {
                                            _scheduledDateTime = DateTime(
                                              date.year,
                                              date.month,
                                              date.day,
                                              time.hour,
                                              time.minute,
                                            );
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Preview message card
              _buildPreviewCard(),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSending || _showSuccess
                      ? null
                      : _handleSendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send Broadcast Message',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),

        // Sending overlay
        if (_isSending) _buildSendingOverlay(),

        // Success overlay
        if (_showSuccess) _buildSuccessOverlay(),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _broadcastHistory.length,
      itemBuilder: (context, index) {
        final message = _broadcastHistory[index];

        // Determine priority color
        Color priorityColor;
        switch (message.priority) {
          case 'Urgent':
            priorityColor = Colors.red;
            break;
          case 'High':
            priorityColor = Colors.orange;
            break;
          default:
            priorityColor = Colors.green;
        }

        // Calculate read percentage
        final readPercentage =
            message.deliveryStats.read / message.deliveryStats.sent * 100;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title and timestamp
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatDateTime(message.sentAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                // Priority and target
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message.priority,
                        style: TextStyle(
                          fontSize: 12,
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        message.target,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                // Message content
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    message.message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Divider(),

                // Delivery stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivered to ${message.deliveryStats.delivered} / ${message.deliveryStats.sent} users',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Read by ${readPercentage.round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress indicator for read status
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: readPercentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Show detailed analytics
                        _showMessageAnalytics(message);
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 16),
                      label: const Text('Analytics'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textMediumColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        // Resend message
                        _showResendConfirmation(message);
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Resend'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  List<Widget> _buildUserSelectionList() {
    return [
      Container(
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _allUsers.length,
          itemBuilder: (context, index) {
            final user = _allUsers[index];
            final isSelected = _selectedUserIds.contains(user.id);

            return CheckboxListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedUserIds.add(user.id);
                  } else {
                    _selectedUserIds.remove(user.id);
                  }
                });
              },
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        ),
      ),
    ];
  }

  Widget _buildPreviewCard() {
    // Skip preview if title and message are empty
    if (_titleController.text.isEmpty && _messageController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    Color priorityColor;
    switch (_selectedPriority) {
      case 'Urgent':
        priorityColor = Colors.red;
        break;
      case 'High':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Message Preview'),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.campaign,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _titleController.text.isNotEmpty
                            ? _titleController.text
                            : '[No title]',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _selectedPriority,
                        style: TextStyle(
                          fontSize: 12,
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _selectedTarget == 'Custom Selection'
                            ? '${_selectedUserIds.length} users'
                            : _selectedTarget,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (_scheduleForLater) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 12,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Scheduled',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _messageController.text.isNotEmpty
                      ? _messageController.text
                      : '[No message content]',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (_scheduleForLater)
                  Text(
                    'Will be sent on: ${_scheduledDateTime.day}/${_scheduledDateTime.month}/${_scheduledDateTime.year} at ${_scheduledDateTime.hour}:${_scheduledDateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.7),
      child: Center(
        child: AnimatedBuilder(
          animation: _sendProgressAnimation,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: _sendProgressAnimation.value,
                    color: AppTheme.primaryColor,
                    strokeWidth: 8,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _sendProgressAnimation.value < 1
                      ? 'Sending message...'
                      : 'Processing...',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Message Sent Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _scheduleForLater
                  ? 'Your message has been scheduled.'
                  : 'Your message is being delivered to recipients.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendMessage() {
    // Validate inputs
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a message title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter message content'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedTarget == 'Custom Selection' && _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one user'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Start sending animation
    setState(() {
      _isSending = true;
    });

    // Simulate sending with animation
    _sendAnimationController.forward();

    // Add to broadcast history (would normally be done through a service)
    final newMessage = BroadcastMessage(
      id: 'msg${_broadcastHistory.length + 1}',
      title: _titleController.text,
      message: _messageController.text,
      target: _selectedTarget,
      priority: _selectedPriority,
      sentAt: _scheduleForLater ? _scheduledDateTime : DateTime.now(),
      status: _scheduleForLater ? 'Scheduled' : 'Sending',
      deliveryStats: DeliveryStats(
        sent: _selectedTarget == 'All Users'
            ? 1458
            : (_selectedTarget == 'Custom Selection'
                  ? _selectedUserIds.length
                  : 128),
        delivered: 0,
        read: 0,
      ),
      senderId: widget.adminUser?.id ?? 'admin1',
    );

    // Only add to history if not scheduled for later
    if (!_scheduleForLater) {
      _broadcastHistory.insert(0, newMessage);
    }
  }

  void _showMessageAnalytics(BroadcastMessage message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Message Analytics',
                      style: TextStyle(
                        fontSize: 20,
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

              // Message details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sent on ${_formatDateTime(message.sentAt)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),

                      // Delivery stats
                      _buildAnalyticsCard(
                        title: 'Delivery Performance',
                        child: Column(
                          children: [
                            // Sent stats
                            _buildAnalyticsRow(
                              'Sent',
                              message.deliveryStats.sent.toString(),
                              message.deliveryStats.sent /
                                  message.deliveryStats.sent *
                                  100,
                              Colors.blue,
                            ),
                            const SizedBox(height: 12),

                            // Delivered stats
                            _buildAnalyticsRow(
                              'Delivered',
                              message.deliveryStats.delivered.toString(),
                              message.deliveryStats.delivered /
                                  message.deliveryStats.sent *
                                  100,
                              Colors.green,
                            ),
                            const SizedBox(height: 12),

                            // Read stats
                            _buildAnalyticsRow(
                              'Read',
                              message.deliveryStats.read.toString(),
                              message.deliveryStats.read /
                                  message.deliveryStats.sent *
                                  100,
                              AppTheme.primaryColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Device breakdown
                      _buildAnalyticsCard(
                        title: 'Device Breakdown',
                        child: Column(
                          children: [
                            _buildDeviceRow('Android', 62, Colors.green),
                            const SizedBox(height: 12),
                            _buildDeviceRow('iOS', 35, Colors.blue),
                            const SizedBox(height: 12),
                            _buildDeviceRow('Web', 3, Colors.orange),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Read time chart
                      _buildAnalyticsCard(
                        title: 'Read Time Distribution',
                        child: Center(
                          child: Image.network(
                            'https://quickchart.io/chart?c={type:%27line%27,data:{labels:[%270h%27,%271h%27,%272h%27,%273h%27,%276h%27,%2712h%27,%2724h%27],datasets:[{label:%27Read%20Percentage%27,data:[5,35,20,15,10,10,5],fill:true,backgroundColor:%27rgba(111,66,193,0.2)%27,borderColor:%27%236f42c1%27}]}}',
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
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

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Download analytics report
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Downloading analytics report...',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Export Report'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Resend to undelivered
                                Navigator.pop(context);
                                _showResendConfirmation(message);
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Resend'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
        );
      },
    );
  }

  Widget _buildAnalyticsCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsRow(
    String label,
    String value,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '$value (${percentage.round()}%)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceRow(String device, int percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(device),
        const Spacer(),
        Text(
          '$percentage%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showResendConfirmation(BroadcastMessage message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resend Message'),
          content: Text(
            'Would you like to resend "${message.title}" to all recipients or only to those who haven\'t received it yet?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resending to undelivered recipients...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
              ),
              child: const Text('Undelivered Only'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resending to all recipients...'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('All Recipients'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class BroadcastMessage {
  final String id;
  final String title;
  final String message;
  final String target;
  final String priority;
  final DateTime sentAt;
  final String status;
  final DeliveryStats deliveryStats;
  final String senderId;

  const BroadcastMessage({
    required this.id,
    required this.title,
    required this.message,
    required this.target,
    required this.priority,
    required this.sentAt,
    required this.status,
    required this.deliveryStats,
    required this.senderId,
  });
}

class DeliveryStats {
  final int sent;
  final int delivered;
  final int read;

  const DeliveryStats({
    required this.sent,
    required this.delivered,
    required this.read,
  });
}
