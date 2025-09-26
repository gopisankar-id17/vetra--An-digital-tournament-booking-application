import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _showSuccessMessage = false;

  // Form controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // FAQ state
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // List of FAQs
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I register for a tournament?',
      'answer':
          'To register for a tournament, navigate to the tournament details page by clicking on any tournament card. On the details page, you\'ll find a "Register Now" button if the tournament is open for registration. Follow the guided steps to complete your registration and payment.',
    },
    {
      'question': 'Can I cancel my tournament registration?',
      'answer':
          'Yes, you can cancel your tournament registration up to 48 hours before the event starts. Go to "My Bookings" in your profile, find the tournament you want to cancel, and click on the "Cancel" button. Please note that refund policies may vary depending on the tournament organizer.',
    },
    {
      'question': 'How do I create and manage my team?',
      'answer':
          'To create a team, go to the "Teams" section in your profile and click on "Create New Team". You can then add team members by sending invitations via email or username. As a team admin, you can manage team members, update team information, and register for team tournaments.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer':
          'We accept various payment methods including credit/debit cards, net banking, UPI, mobile wallets, and more. All payments are processed securely through our payment gateway partners.',
    },
    {
      'question': 'How are tournament rankings calculated?',
      'answer':
          'Tournament rankings are calculated based on your performance in tournaments, including matches won, total points scored, and the difficulty level of the tournament. Each game category may have specific ranking algorithms. You can check your current ranking in the "Leaderboard" section.',
    },
    {
      'question': 'Can I organize my own tournament on Vetra?',
      'answer':
          'Yes! To organize a tournament, you need to register as an organizer. Go to your profile settings and choose the "Become an Organizer" option. After verification, you\'ll have access to tournament creation tools where you can set up, manage, and promote your tournaments.',
    },
    {
      'question':
          'I\'m having technical issues with the app. What should I do?',
      'answer':
          'For technical issues, first try restarting the app or refreshing the page. If the problem persists, go to the "Help & Support" section and submit a detailed report of the issue. Our technical team will assist you as soon as possible. You can also check our system status page to see if there are any known outages.',
    },
    {
      'question': 'How do I update my profile information?',
      'answer':
          'To update your profile information, go to your profile page and click on the "Edit Profile" button. You can update your personal details, change your profile picture, update your preferences, and manage your notification settings from there.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'FAQs'),
            Tab(text: 'Contact Us'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFAQsTab(), _buildContactUsTab()],
      ),
    );
  }

  Widget _buildFAQsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search FAQs',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                  onChanged: (value) {
                    // Search functionality would be implemented here
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('All', true),
              _buildCategoryChip('Registration', false),
              _buildCategoryChip('Payment', false),
              _buildCategoryChip('Technical', false),
              _buildCategoryChip('Tournament', false),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // FAQ List
        ...List.generate(
          _faqs.length,
          (index) => _buildFAQItem(
            _faqs[index]['question'],
            _faqs[index]['answer'],
            index,
          ),
        ),

        const SizedBox(height: 24),

        // Can't find answer section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Can\'t find what you\'re looking for?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Our support team is ready to assist you with any questions or issues you may have.',
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                ),
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[800],
        ),
        onSelected: (selected) {
          // Category filtering would be implemented here
        },
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, int index) {
    bool isExpanded = _expandedIndex == index;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              question,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppTheme.primary,
            ),
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(answer, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Was this helpful?',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              // Feedback functionality would be implemented here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Thank you for your feedback!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.thumb_up_alt_outlined,
                              size: 16,
                            ),
                            label: const Text('Yes'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Feedback functionality would be implemented here
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'We\'ll improve this answer. Thank you!',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.thumb_down_alt_outlined,
                              size: 16,
                            ),
                            label: const Text('No'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildContactUsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Support channels
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'We\'re here to help!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Our support team is available 24/7 to assist you.',
                        style: TextStyle(color: Colors.grey[700], height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Support channels
          const Text(
            'Support Channels',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Email support
          _buildSupportChannelItem(
            icon: Icons.email,
            title: 'Email Support',
            description: 'support@vetra-tournaments.com',
            onTap: () {
              // Email functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening email client...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // Phone support
          _buildSupportChannelItem(
            icon: Icons.phone,
            title: 'Phone Support',
            description: '+91 9876543210 (Mon-Fri, 9 AM - 6 PM)',
            onTap: () {
              // Phone functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening phone dialer...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          // Live chat
          _buildSupportChannelItem(
            icon: Icons.chat_bubble,
            title: 'Live Chat',
            description: 'Chat with our support team in real-time',
            onTap: () {
              // Live chat functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening live chat...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Contact form
          const Text(
            'Send us a message',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill out the form below and we\'ll get back to you as soon as possible.',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),

          if (_showSuccessMessage)
            _buildSuccessMessage()
          else
            _buildContactForm(),
        ],
      ),
    );
  }

  Widget _buildSupportChannelItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          _buildTextField(
            label: 'Subject',
            controller: _subjectController,
            hint: 'Enter the subject of your inquiry',
          ),
          const SizedBox(height: 16),

          // Message
          _buildTextField(
            label: 'Message',
            controller: _messageController,
            hint: 'Please describe your issue or question in detail',
            maxLines: 5,
          ),
          const SizedBox(height: 16),

          // Attachment
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Attach a file (optional)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // File attachment functionality would be implemented here
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                  ),
                  child: const Text('Browse'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primary, width: 2),
            ),
          ),
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.green[700], size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Message Sent!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for contacting us. We\'ve received your message and will get back to you within 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showSuccessMessage = false;
                  _subjectController.clear();
                  _messageController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              child: const Text('Send Another Message'),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate form submission
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showSuccessMessage = true;
        });
      }
    });
  }
}
