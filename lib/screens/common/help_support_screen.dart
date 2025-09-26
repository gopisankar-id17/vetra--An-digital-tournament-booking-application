import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'dart:math' as math;
import 'dart:async';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with TickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  
  // Animation controllers for FAQ items
  final Map<int, AnimationController> _faqAnimationControllers = {};
  final Map<int, Animation<double>> _faqRotationAnimations = {};
  final Map<int, Animation<double>> _faqHeightFactorAnimations = {};
  
  // Track expanded FAQ items
  final Set<int> _expandedFaqs = {};
  
  // Track if a support ticket is being submitted
  bool _isSubmittingTicket = false;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  // Category selection
  final List<String> _supportCategories = [
    'General Inquiry',
    'Account Issues',
    'Tournament Problems',
    'Booking Problems',
    'Payment Issues',
    'Technical Support',
    'Feature Request',
    'Other',
  ];
  String _selectedCategory = 'General Inquiry';
  
  // Priority selection
  final List<String> _priorityLevels = ['Low', 'Medium', 'High', 'Urgent'];
  String _selectedPriority = 'Medium';
  
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Support ticket success animation
  bool _showTicketSuccess = false;
  
  // Live chat simulation
  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _chatMessageController = TextEditingController();
  bool _isTyping = false;
  Timer? _typingTimer;
  
  // FAQ data
  final List<Map<String, dynamic>> _faqData = [
    {
      'question': 'How do I register for a tournament?',
      'answer': 'To register for a tournament, navigate to the "Tournaments" tab in the app, select the tournament you wish to join, and tap the "Register" button. Follow the on-screen instructions to complete your registration and payment (if required).',
      'tags': ['tournament', 'registration', 'booking'],
    },
    {
      'question': 'Can I cancel my tournament registration?',
      'answer': 'Yes, you can cancel your tournament registration by going to "My Bookings" section and selecting the tournament you wish to cancel. Tap the "Cancel Registration" button and follow the prompts. Please note that cancellation policies vary by tournament - some may offer full refunds up to a certain date, while others may have non-refundable fees.',
      'tags': ['tournament', 'cancellation', 'refund'],
    },
    {
      'question': 'How do I update my profile information?',
      'answer': 'You can update your profile information by navigating to the Profile section from the main menu. Tap on "Edit Profile" and you will be able to modify your personal information, change your profile picture, and update your preferences.',
      'tags': ['profile', 'account', 'settings'],
    },
    {
      'question': 'I forgot my password. How can I reset it?',
      'answer': 'To reset your password, go to the login screen and tap on "Forgot Password". Enter the email address associated with your account, and we will send you a link to reset your password. Follow the instructions in the email to create a new password.',
      'tags': ['password', 'login', 'account'],
    },
    {
      'question': 'How do I contact the tournament organizer?',
      'answer': 'You can contact the tournament organizer directly through the tournament details page. Navigate to the specific tournament, scroll down to the "Organizer" section, and tap on the "Contact" button. This will allow you to send a message directly to the organizer.',
      'tags': ['tournament', 'contact', 'organizer'],
    },
    {
      'question': 'How are tournament results published?',
      'answer': 'Tournament results are published in the "Results" section of each tournament page. Once the tournament is complete, the organizer will update the standings and results. You will receive a notification when results for your tournaments are available.',
      'tags': ['tournament', 'results', 'standings'],
    },
    {
      'question': 'Can I participate in multiple tournaments at the same time?',
      'answer': 'Yes, you can register for multiple tournaments as long as they don\'t have conflicting schedules. Be sure to check the dates and times carefully before registering to avoid scheduling conflicts.',
      'tags': ['tournament', 'scheduling', 'registration'],
    },
    {
      'question': 'What payment methods are accepted?',
      'answer': 'We accept various payment methods including credit/debit cards, UPI, net banking, and select mobile wallets. The available payment options will be shown during the checkout process when you register for a tournament.',
      'tags': ['payment', 'billing', 'registration'],
    },
    {
      'question': 'How do team registrations work?',
      'answer': 'For team tournaments, the team captain should register first and create a team. The captain will receive a team code that can be shared with team members. Other players can join the team using this code when they register for the same tournament.',
      'tags': ['team', 'tournament', 'registration'],
    },
    {
      'question': 'How can I get notifications about upcoming tournaments?',
      'answer': 'To receive notifications about upcoming tournaments, make sure you have notifications enabled in your app settings. You can also follow specific tournament categories or organizers to get alerts when new events are posted.',
      'tags': ['notifications', 'settings', 'tournaments'],
    },
  ];
  
  // Filtered FAQ data based on search
  List<Map<String, dynamic>> _filteredFaqData = [];
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize filtered FAQ data
    _filteredFaqData = List.from(_faqData);
    
    // Set up search listener
    _searchController.addListener(_filterFaqs);
    
    // Initialize FAQ animations
    for (int i = 0; i < _faqData.length; i++) {
      _faqAnimationControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      
      _faqRotationAnimations[i] = Tween<double>(begin: 0, end: 0.5).animate(
        CurvedAnimation(
          parent: _faqAnimationControllers[i]!,
          curve: Curves.easeInOut,
        ),
      );
      
      _faqHeightFactorAnimations[i] = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _faqAnimationControllers[i]!,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _chatMessageController.dispose();
    
    // Dispose animation controllers
    for (final controller in _faqAnimationControllers.values) {
      controller.dispose();
    }
    
    // Cancel typing timer
    _typingTimer?.cancel();
    
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredFaqData = List.from(_faqData);
      } else {
        _filteredFaqData = _faqData.where((faq) {
          final questionMatch = faq['question'].toString().toLowerCase().contains(query);
          final answerMatch = faq['answer'].toString().toLowerCase().contains(query);
          final tagMatch = (faq['tags'] as List).any(
            (tag) => tag.toString().toLowerCase().contains(query),
          );
          
          return questionMatch || answerMatch || tagMatch;
        }).toList();
      }
    });
  }

  void _toggleFaqExpansion(int index) {
    setState(() {
      if (_expandedFaqs.contains(index)) {
        _expandedFaqs.remove(index);
        _faqAnimationControllers[index]?.reverse();
      } else {
        _expandedFaqs.add(index);
        _faqAnimationControllers[index]?.forward();
      }
    });
  }

  void _simulateAgentTyping() {
    setState(() {
      _isTyping = true;
    });
    
    // Cancel any existing timer
    _typingTimer?.cancel();
    
    // Set a random typing duration
    final typingDuration = Duration(
      milliseconds: 1000 + math.Random().nextInt(2000),
    );
    
    _typingTimer = Timer(typingDuration, () {
      if (!mounted) return;
      
      setState(() {
        _isTyping = false;
      });
      
      // Add agent response
      _addAgentResponse();
    });
  }

  void _addAgentResponse() {
    final List<String> responses = [
      'Thank you for reaching out! How can I assist you with your tournament registration today?',
      'I understand you\'re having an issue. Could you please provide more details about the problem you\'re experiencing?',
      'Let me check that for you. It appears that your booking was successfully processed.',
      'I\'m sorry to hear you\'re having trouble. Have you tried refreshing the app and trying again?',
      'The tournament you\'re asking about is scheduled for next Saturday at 10 AM. Registration closes 24 hours before the event.',
      'For refund requests, please note that our policy allows full refunds up to 48 hours before the event starts.',
      'Is there anything else I can help you with today?',
    ];
    
    final response = responses[math.Random().nextInt(responses.length)];
    
    setState(() {
      _chatMessages.add(
        ChatMessage(
          message: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _handleSendChatMessage() {
    final message = _chatMessageController.text.trim();
    
    if (message.isEmpty) return;
    
    setState(() {
      _chatMessages.add(
        ChatMessage(
          message: message,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _chatMessageController.clear();
    });
    
    // Simulate agent typing response
    _simulateAgentTyping();
  }

  void _handleSubmitTicket() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmittingTicket = true;
    });
    
    // Simulate submission delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      setState(() {
        _isSubmittingTicket = false;
        _showTicketSuccess = true;
      });
      
      // Reset form after showing success
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        
        setState(() {
          _showTicketSuccess = false;
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
          _selectedCategory = 'General Inquiry';
          _selectedPriority = 'Medium';
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textMediumColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Contact Us'),
            Tab(text: 'Live Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqTab(),
          _buildContactTab(),
          _buildLiveChatTab(),
        ],
      ),
    );
  }

  Widget _buildFaqTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for help topics...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
            ),
          ),
        ),
        
        // Category chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildCategoryChip('All', isSelected: true),
              _buildCategoryChip('Tournaments'),
              _buildCategoryChip('Bookings'),
              _buildCategoryChip('Account'),
              _buildCategoryChip('Payments'),
              _buildCategoryChip('Teams'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // FAQ list
        Expanded(
          child: _filteredFaqData.isEmpty
              ? _buildNoResultsFound()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _filteredFaqData.length,
                  itemBuilder: (context, index) {
                    return _buildFaqItem(
                      _filteredFaqData[index],
                      _faqData.indexOf(_filteredFaqData[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // Filter FAQs by category (not implemented in this demo)
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppTheme.primaryLightColor,
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term or browse categories',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppTheme.primaryColor),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text('Clear search'),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq, int originalIndex) {
    final isExpanded = _expandedFaqs.contains(originalIndex);
    
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: isExpanded ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Question header (always visible)
          InkWell(
            onTap: () => _toggleFaqExpansion(originalIndex),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq['question'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _faqRotationAnimations[originalIndex]!,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _faqRotationAnimations[originalIndex]!.value * math.pi * 2,
                        child: const Icon(Icons.keyboard_arrow_down),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Answer content (expandable)
          AnimatedBuilder(
            animation: _faqHeightFactorAnimations[originalIndex]!,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _faqHeightFactorAnimations[originalIndex]!.value,
                  child: child,
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq['answer'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (faq['tags'] as List).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Feedback buttons
                      Row(
                        children: [
                          const Text(
                            'Was this helpful?',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          _buildFeedbackButton(
                            icon: Icons.thumb_up_outlined,
                            label: 'Yes',
                          ),
                          const SizedBox(width: 8),
                          _buildFeedbackButton(
                            icon: Icons.thumb_down_outlined,
                            label: 'No',
                          ),
                        ],
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

  Widget _buildFeedbackButton({
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your feedback!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey.shade700,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildContactTab() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact info card
              _buildContactInfoCard(),
              const SizedBox(height: 24),
              
              // Support ticket form
              const Text(
                'Submit a Support Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Support Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _supportCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Priority selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Priority Level',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPrioritySelector(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Subject field
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subject),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Message field
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        if (value.length < 20) {
                          return 'Please provide more details (at least 20 characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Attachment option
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('File attachment feature coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attach a file'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmittingTicket ? null : _handleSubmitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmittingTicket
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Submit Ticket',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Success overlay
        if (_showTicketSuccess)
          _buildSuccessOverlay(),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.contact_support,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'We\'re here to help!',
                        style: TextStyle(
                          color: AppTheme.textMediumColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildContactMethod(
              icon: Icons.email_outlined,
              title: 'Email',
              content: 'support@vetra-tournaments.com',
              onTap: () {},
            ),
            _buildContactMethod(
              icon: Icons.phone_outlined,
              title: 'Phone',
              content: '+91 98765 43210',
              onTap: () {},
            ),
            _buildContactMethod(
              icon: Icons.schedule,
              title: 'Hours',
              content: 'Mon-Fri: 9:00 AM - 6:00 PM',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(Icons.facebook, Colors.blue),
                _buildSocialButton(Icons.chat_bubble, Colors.lightBlue),
                _buildSocialButton(Icons.camera_alt, Colors.purple),
                _buildSocialButton(Icons.messenger, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: color,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: _priorityLevels.map((priority) {
        Color color;
        switch (priority) {
          case 'Urgent':
            color = Colors.red;
            break;
          case 'High':
            color = Colors.orange;
            break;
          case 'Medium':
            color = Colors.blue;
            break;
          default:
            color = Colors.green;
        }
        
        final isSelected = _selectedPriority == priority;
        
        return Expanded(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPriority = priority;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    _getPriorityIcon(priority),
                    color: isSelected ? color : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priority,
                    style: TextStyle(
                      color: isSelected ? color : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'Urgent':
        return Icons.priority_high;
      case 'High':
        return Icons.arrow_upward;
      case 'Medium':
        return Icons.remove;
      default:
        return Icons.arrow_downward;
    }
  }

  Widget _buildLiveChatTab() {
    return Column(
      children: [
        // Chat status bar
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Support Agent',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(online)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Show chat options
                },
              ),
            ],
          ),
        ),
        
        // Chat messages
        Expanded(
          child: _chatMessages.isEmpty
              ? _buildEmptyChatState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show typing indicator at the top of the reversed list
                    if (_isTyping && index == 0) {
                      return _buildTypingIndicator();
                    }
                    
                    // Adjust index for the reversed list
                    final messageIndex = _isTyping
                        ? _chatMessages.length - index
                        : _chatMessages.length - index - 1;
                    
                    return _buildChatMessageBubble(_chatMessages[messageIndex]);
                  },
                ),
        ),
        
        // Chat input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () {
                  // Attachment functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attachment feature coming soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _chatMessageController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSendChatMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: _handleSendChatMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChatState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        const Text(
          'Welcome to Live Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How can we help you today?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _chatMessageController.text = 'Hi, I need help with my tournament registration.';
              _handleSendChatMessage();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text('Start a conversation'),
        ),
      ],
    );
  }

  Widget _buildChatMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : null,
            bottomLeft: !isUser ? const Radius.circular(0) : null,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatChatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isUser ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPulsingDot(delay: 0),
            _buildPulsingDot(delay: 300),
            _buildPulsingDot(delay: 600),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingDot({required int delay}) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.5, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: value,
              child: child,
            ),
          );
        },
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
              'Ticket Submitted Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll get back to you as soon as possible.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ticket ID: #${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}