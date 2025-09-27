import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';
import 'dart:math' as math;

class ProfileCustomizationScreen extends StatefulWidget {
  const ProfileCustomizationScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCustomizationScreen> createState() =>
      _ProfileCustomizationScreenState();
}

class _ProfileCustomizationScreenState extends State<ProfileCustomizationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late User _user;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _showSuccessAnimation = false;

  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize with sample user data
    _user = User.sampleUser();

    // Initialize controllers
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
    _phoneController = TextEditingController(text: _user.phone);
    _addressController = TextEditingController(text: _user.address);
    _bioController = TextEditingController(text: _user.bio);

    // Initialize animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Update user data
    _user = _user.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      bio: _bioController.text,
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
      _showSuccessAnimation = true;
    });

    // Show success animation
    _animationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showSuccessAnimation = false;
          });
          _animationController.reset();
        }
      });
    });
  }

  Future<void> _pickImage() async {
    // Show bottom sheet for image options
    await showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              // Camera functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Camera access not implemented in this demo'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              // Gallery functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gallery access not implemented in this demo'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Customization'),
        actions: [
          _isEditing
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleEdit,
                )
              : IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _toggleEdit,
                ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildProfileForm(),
                  const SizedBox(height: 32),
                  _buildPreferredCategories(),
                  const SizedBox(height: 32),
                  _buildSocialProfiles(),
                  const SizedBox(height: 32),
                  _buildTournamentStats(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
          ),
          if (_isEditing) _buildBottomSaveButton(),
          if (_showSuccessAnimation) _buildSuccessAnimation(),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    _user.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _user.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _user.getRoleColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _user.getRoleDisplayName(),
              style: TextStyle(
                color: _user.getRoleColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Member since ${_formatDate(_user.registrationDate)}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Full Name',
            controller: _nameController,
            prefixIcon: Icons.person,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Email Address',
            controller: _emailController,
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Phone Number',
            controller: _phoneController,
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Location',
            controller: _addressController,
            prefixIcon: Icons.location_on,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Bio',
            controller: _bioController,
            prefixIcon: Icons.info_outline,
            maxLines: 3,
            enabled: _isEditing,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildPreferredCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preferred Categories',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_isEditing)
              TextButton(
                onPressed: () {
                  // Edit categories
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (_user.preferredCategories ?? []).map((category) {
            return Chip(
              label: Text(category),
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(color: AppTheme.primary),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialProfiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Social Profiles',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (_isEditing)
              TextButton(
                onPressed: () {
                  // Edit social profiles
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_user.socialProfiles != null && _user.socialProfiles!.isNotEmpty)
          ..._user.socialProfiles!.entries.map(
            (entry) => ListTile(
              leading: _getSocialIcon(entry.key),
              title: Text(entry.key.capitalize()),
              subtitle: Text('@${entry.value}'),
              contentPadding: EdgeInsets.zero,
            ),
          )
        else
          Text(
            'No social profiles linked',
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildTournamentStats() {
    if (_user.stats == null || _user.stats!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tournament Statistics',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Tournaments',
                _user.stats!['tournaments'].toString(),
                Icons.emoji_events,
              ),
              _buildStatItem(
                'Wins',
                _user.stats!['wins'].toString(),
                Icons.military_tech,
              ),
              _buildStatItem(
                'Bookings',
                _user.stats!['bookings'].toString(),
                Icons.calendar_today,
              ),
              _buildStatItem(
                'Rating',
                _user.stats!['rating'].toString(),
                Icons.star,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomSaveButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Save Profile'),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green[500],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _getSocialIcon(String platform) {
    IconData iconData;

    switch (platform.toLowerCase()) {
      case 'instagram':
        iconData = Icons.camera_alt;
        break;
      case 'facebook':
        iconData = Icons.facebook;
        break;
      case 'twitter':
        iconData = Icons.forum;
        break;
      case 'linkedin':
        iconData = Icons.business;
        break;
      default:
        iconData = Icons.link;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: AppTheme.primary, size: 20),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
