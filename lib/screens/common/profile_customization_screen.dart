import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';
import '../../services/session_service.dart';
import 'dart:math' as math;
import 'dart:async';

class ProfileCustomizationScreen extends StatefulWidget {
  final User user;

  const ProfileCustomizationScreen({Key? key, required this.user})
    : super(key: key);

  @override
  State<ProfileCustomizationScreen> createState() =>
      _ProfileCustomizationScreenState();
}

class _ProfileCustomizationScreenState extends State<ProfileCustomizationScreen>
    with SingleTickerProviderStateMixin {
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;

  // Social media controllers
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _facebookController;

  // User preferences
  late List<String> _selectedPreferredCategories;
  late bool _notificationsEnabled;
  late List<String> _notificationPreferences;

  // Avatar state
  String? _selectedAvatarUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Animation controller for avatar selection
  late AnimationController _avatarAnimationController;
  int _currentAvatarIndex = 0;

  // Sample avatars for selection
  final List<String> _sampleAvatars = [
    'https://ui-avatars.com/api/?name=Player&background=random',
    'https://ui-avatars.com/api/?name=Gamer&background=6f42c1&color=fff',
    'https://ui-avatars.com/api/?name=Champion&background=28a745&color=fff',
    'https://ui-avatars.com/api/?name=Pro&background=ffc107&color=000',
    'https://ui-avatars.com/api/?name=MVP&background=dc3545&color=fff',
    'https://ui-avatars.com/api/?name=Winner&background=007bff&color=fff',
  ];

  // Available categories
  final List<String> _allCategories = [
    'Chess',
    'Board Games',
    'Card Games',
    'Outdoor',
    'Indoor',
    'Physical',
    'Mental',
    'Team',
    'Individual',
    'Strategy',
    'eSports',
    'Racing',
    'Cricket',
    'Football',
    'Basketball',
  ];

  // Available notification preferences
  final List<String> _allNotificationTypes = [
    'Tournament updates',
    'Booking confirmations',
    'Reminders',
    'Results',
    'Special offers',
    'Admin announcements',
  ];

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Save state
  bool _isSaving = false;
  bool _hasChanges = false;

  // Whether we're in edit mode
  bool _isEditMode = true;

  @override
  void initState() {
    super.initState();
    _initializeWithSessionData();
  }

  Future<void> _initializeWithSessionData() async {
    final userData = await SessionService.getUserSession();
    final profileData = await SessionService.getUserProfileData(); // We'll add this

    // Initialize controllers with session data if available, otherwise use defaults
    _nameController = TextEditingController(text: userData['name'] ?? widget.user.name);
    _bioController = TextEditingController(
      text: profileData['bio'] ?? widget.user.bio ?? 'Tell others about yourself...',
    );
    _locationController = TextEditingController(text: profileData['address'] ?? widget.user.address ?? '');
    _phoneController = TextEditingController(text: userData['phone'] ?? widget.user.phone ?? '');

    // Initialize social media controllers
    _instagramController = TextEditingController(text: profileData['instagram'] ?? '');
    _twitterController = TextEditingController(text: profileData['twitter'] ?? '');
    _facebookController = TextEditingController(text: profileData['facebook'] ?? '');

    // Initialize user preferences
    List<String> preferredCats = [];
    String? catsString = profileData['preferredCategories'];
    if (catsString?.isNotEmpty == true) {
      preferredCats = catsString!.split(',');
    } else {
      preferredCats = widget.user.preferredCategories ?? ['Chess', 'Board Games'];
    }
    _selectedPreferredCategories = preferredCats;

    _notificationsEnabled = profileData['notificationsEnabled'] == 'true';
    
    List<String> notifPrefs = [];
    String? notifsString = profileData['notificationPreferences'];
    if (notifsString?.isNotEmpty == true) {
      notifPrefs = notifsString!.split(',');
    } else {
      notifPrefs = [
        'Tournament updates',
        'Booking confirmations',
        'Results',
      ];
    }
    _notificationPreferences = notifPrefs;

    // Set initial avatar
    _selectedAvatarUrl = profileData['photoUrl'] ?? widget.user.photoUrl;

    // Initialize animation controller for avatar selection
    _avatarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Trigger a rebuild to show the loaded data
    if (mounted) {
      setState(() {});
    }

    // Listen to changes
    _nameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _locationController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _instagramController.addListener(_onFieldChanged);
    _twitterController.addListener(_onFieldChanged);
    _facebookController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _avatarAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            if (_isEditMode)
              TextButton(
                onPressed: _hasChanges ? _handleSave : null,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
          ],
        ),
        body: _isEditMode ? _buildEditForm() : _buildProfileView(),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile avatar section
            _buildProfileAvatarSection(),
            const SizedBox(height: 24),

            // Basic info section
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            _buildBasicInfoSection(),
            const SizedBox(height: 24),

            // Social media section
            _buildSectionHeader('Social Media'),
            const SizedBox(height: 16),
            _buildSocialMediaSection(),
            const SizedBox(height: 24),

            // Preferences section
            _buildSectionHeader('Preferences'),
            const SizedBox(height: 16),
            _buildPreferencesSection(),
            const SizedBox(height: 24),

            // Privacy section
            _buildSectionHeader('Privacy & Notifications'),
            const SizedBox(height: 16),
            _buildPrivacySection(),
            const SizedBox(height: 32),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hasChanges ? _handleSave : null,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: _isSaving 
                    ? const Text('Saving...') 
                    : const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Preview profile button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isEditMode = false;
                  });
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Preview Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover photo and avatar
              _buildProfileHeader(),

              // Profile info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and bio
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bioController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location and contact
                    _buildInfoRow(Icons.location_on, _locationController.text),
                    _buildInfoRow(Icons.phone, _phoneController.text),
                    const SizedBox(height: 8),

                    // Social media
                    if (_instagramController.text.isNotEmpty)
                      _buildInfoRow(
                        Icons.camera_alt,
                        '@${_instagramController.text}',
                      ),
                    if (_twitterController.text.isNotEmpty)
                      _buildInfoRow(
                        Icons.chat_bubble_outline,
                        '@${_twitterController.text}',
                      ),
                    if (_facebookController.text.isNotEmpty)
                      _buildInfoRow(Icons.facebook, _facebookController.text),

                    const Divider(height: 32),

                    // Preferred categories
                    const Text(
                      'Preferred Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedPreferredCategories.map((category) {
                        return Chip(
                          label: Text(category),
                          backgroundColor: AppTheme.primaryLightColor,
                          labelStyle: const TextStyle(
                            color: AppTheme.primaryColor,
                          ),
                        );
                      }).toList(),
                    ),

                    const Divider(height: 32),

                    // Statistics
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticsGrid(),

                    const Divider(height: 32),

                    // Recent activity
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentActivityList(),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Return to edit button
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _isEditMode = true;
              });
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover photo
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.7),
                Colors.blue.shade500,
              ],
            ),
          ),
        ),

        // Profile avatar
        Positioned(
          bottom: -60,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                _selectedAvatarUrl ??
                    'https://ui-avatars.com/api/?name=${_nameController.text}',
              ),
            ),
          ),
        ),

        // Cover photo edit button
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.photo_camera),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cover photo upload not implemented in demo'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              tooltip: 'Change cover photo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('Tournaments', '12', Icons.emoji_events),
        _buildStatCard('Wins', '5', Icons.military_tech),
        _buildStatCard('Bookings', '28', Icons.confirmation_number),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Booked a Chess Tournament',
        'description': 'Secured a spot in the weekend championship',
        'time': '2 days ago',
        'icon': Icons.emoji_events,
      },
      {
        'title': 'Updated Profile',
        'description': 'Changed profile picture and bio',
        'time': '1 week ago',
        'icon': Icons.person,
      },
      {
        'title': 'Won 2nd Place',
        'description': 'In the Junior Chess Championship',
        'time': '2 weeks ago',
        'icon': Icons.military_tech,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryLightColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(activity['icon'], color: AppTheme.primaryColor),
          ),
          title: Text(
            activity['title'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(activity['description']),
          trailing: Text(
            activity['time'],
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatarSection() {
    return Center(
      child: Column(
        children: [
          // Profile picture
          Stack(
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryLightColor,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    _selectedAvatarUrl ??
                        'https://ui-avatars.com/api/?name=${_nameController.text}',
                  ),
                ),
              ),

              // Upload progress indicator
              if (_isUploading)
                Positioned.fill(
                  child: CircularProgressIndicator(
                    value: _uploadProgress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    color: AppTheme.primaryColor,
                  ),
                ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: _showAvatarOptions,
                    tooltip: 'Change profile picture',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to change profile picture',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Change Profile Picture',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Avatar options
                  Center(
                    child: SizedBox(
                      height: 100,
                      child: PageView.builder(
                        controller: PageController(
                          viewportFraction: 0.3,
                          initialPage: _currentAvatarIndex,
                        ),
                        onPageChanged: (index) {
                          setState(() {
                            _currentAvatarIndex = index;
                          });
                        },
                        itemCount: _sampleAvatars.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == _currentAvatarIndex;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: isSelected ? 0 : 10,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: CircleAvatar(
                              radius: isSelected ? 50 : 40,
                              backgroundImage: NetworkImage(
                                _sampleAvatars[index],
                              ),
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
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Upload from gallery
                            _simulateAvatarUpload(context);
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Upload'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Apply selected avatar
                            setState(() {
                              this._selectedAvatarUrl =
                                  _sampleAvatars[_currentAvatarIndex];
                            });

                            // Update state in parent widget
                            this.setState(() {
                              _hasChanges = true;
                            });

                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Use this'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _simulateAvatarUpload(BuildContext modalContext) {
    Navigator.pop(modalContext); // Close the bottom sheet

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Simulate upload progress
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _uploadProgress += 0.05;

        if (_uploadProgress >= 1.0) {
          _isUploading = false;
          _uploadProgress = 0.0;
          _selectedAvatarUrl =
              'https://ui-avatars.com/api/?name=${_nameController.text}&background=${_getRandomColor()}';
          _hasChanges = true;
          timer.cancel();
        }
      });
    });
  }

  String _getRandomColor() {
    final List<String> colors = [
      '6f42c1',
      '28a745',
      'ffc107',
      'dc3545',
      '007bff',
      '17a2b8',
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  Widget _buildBasicInfoSection() {
    return Column(
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

        // Bio field
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            hintText: 'Tell us about yourself...',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Location field
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        const SizedBox(height: 16),

        // Phone field
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    return Column(
      children: [
        // Instagram field
        TextFormField(
          controller: _instagramController,
          decoration: InputDecoration(
            labelText: 'Instagram',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.camera_alt),
            prefixText: '@',
            hintText: 'username',
            suffixIcon: _instagramController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _instagramController.clear();
                      });
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Twitter field
        TextFormField(
          controller: _twitterController,
          decoration: InputDecoration(
            labelText: 'Twitter',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.chat_bubble_outline),
            prefixText: '@',
            hintText: 'username',
            suffixIcon: _twitterController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _twitterController.clear();
                      });
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Facebook field
        TextFormField(
          controller: _facebookController,
          decoration: InputDecoration(
            labelText: 'Facebook',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.facebook),
            hintText: 'username or profile URL',
            suffixIcon: _facebookController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _facebookController.clear();
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Tournament Categories',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Category chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allCategories.map((category) {
            final isSelected = _selectedPreferredCategories.contains(category);

            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPreferredCategories.add(category);
                  } else {
                    _selectedPreferredCategories.remove(category);
                  }
                  _hasChanges = true;
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: AppTheme.primaryLightColor,
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notifications toggle
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive updates and alerts'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              _hasChanges = true;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),

        if (_notificationsEnabled) ...[
          const SizedBox(height: 16),
          const Text(
            'Notification Preferences',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          // Notification preferences
          ...List.generate(_allNotificationTypes.length, (index) {
            final notificationType = _allNotificationTypes[index];
            final isSelected = _notificationPreferences.contains(
              notificationType,
            );

            return CheckboxListTile(
              title: Text(notificationType),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _notificationPreferences.add(notificationType);
                  } else {
                    _notificationPreferences.remove(notificationType);
                  }
                  _hasChanges = true;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            );
          }),
        ],

        const SizedBox(height: 24),
        const Text(
          'Privacy Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // Privacy settings
        SwitchListTile(
          title: const Text('Public Profile'),
          subtitle: const Text('Allow others to view your profile'),
          value: true,
          onChanged: (value) {
            setState(() {
              _hasChanges = true;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Show Statistics'),
          subtitle: const Text('Display your tournament statistics'),
          value: true,
          onChanged: (value) {
            setState(() {
              _hasChanges = true;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Allow Friend Requests'),
          subtitle: const Text('Let other users send you friend requests'),
          value: true,
          onChanged: (value) {
            setState(() {
              _hasChanges = true;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider()),
      ],
    );
  }

  Future<bool> _handleBackPress() async {
    if (!_hasChanges || !_isEditMode) {
      return true;
    }

    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
              ),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save all profile data to SessionService
      await SessionService.saveUserProfileData(
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        address: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        photoUrl: _selectedAvatarUrl,
        instagram: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
        twitter: _twitterController.text.trim().isEmpty ? null : _twitterController.text.trim(),
        facebook: _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
        preferredCategories: _selectedPreferredCategories,
        notificationsEnabled: _notificationsEnabled,
        notificationPreferences: _notificationPreferences,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Optionally navigate back
        // Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
