import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> _users = [];
  String _searchQuery = '';
  String _selectedFilter = 'All Users';
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    // In a real app, this would fetch from a database or API
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _users = User.getSampleUsers();
          // Add more sample users for demonstration
          _users.addAll([
            User(
              id: '5',
              name: 'Maria Rodriguez',
              email: 'maria@example.com',
              photoUrl:
                  'https://ui-avatars.com/api/?name=Maria+Rodriguez&background=94c142&color=fff',
              isAdmin: false,
              role: 'organizer',
              registrationDate: DateTime.now().subtract(
                const Duration(days: 75),
              ),
            ),
            User(
              id: '6',
              name: 'David Wilson',
              email: 'david@example.com',
              photoUrl:
                  'https://ui-avatars.com/api/?name=David+Wilson&background=94c142&color=fff',
              isAdmin: false,
              role: 'user',
              registrationDate: DateTime.now().subtract(
                const Duration(days: 10),
              ),
            ),
            User(
              id: '7',
              name: 'Sarah Thompson',
              email: 'sarah@example.com',
              photoUrl:
                  'https://ui-avatars.com/api/?name=Sarah+Thompson&background=94c142&color=fff',
              isAdmin: false,
              role: 'premium',
              registrationDate: DateTime.now().subtract(
                const Duration(days: 200),
              ),
            ),
          ]);
          _isLoading = false;
        });
      }
    });
  }

  List<User> _getFilteredUsers() {
    List<User> filteredUsers = _users;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredUsers = filteredUsers.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.role.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply role/status filter
    if (_selectedFilter != 'All Users') {
      if (_selectedFilter == 'Administrators') {
        filteredUsers = filteredUsers.where((user) => user.isAdmin).toList();
      } else if (_selectedFilter == 'Standard Users') {
        filteredUsers = filteredUsers
            .where((user) => user.role == 'user')
            .toList();
      } else if (_selectedFilter == 'Premium Users') {
        filteredUsers = filteredUsers
            .where((user) => user.role == 'premium')
            .toList();
      } else if (_selectedFilter == 'Organizers') {
        filteredUsers = filteredUsers
            .where((user) => user.role == 'organizer')
            .toList();
      }
    }

    return filteredUsers;
  }

  void _showAddUserDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String selectedRole = 'user';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('Standard User'),
                    ),
                    DropdownMenuItem(
                      value: 'premium',
                      child: Text('Premium User'),
                    ),
                    DropdownMenuItem(
                      value: 'organizer',
                      child: Text('Tournament Organizer'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrator'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedRole = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would add the user to the database
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  final newUser = User(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    email: emailController.text,
                    isAdmin: selectedRole == 'admin',
                    role: selectedRole,
                    photoUrl:
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nameController.text)}&background=94c142&color=fff',
                  );

                  setState(() {
                    _users.add(newUser);
                  });

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'User ${nameController.text} added successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add User'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(User user) {
    final TextEditingController nameController = TextEditingController(
      text: user.name,
    );
    final TextEditingController emailController = TextEditingController(
      text: user.email,
    );
    final TextEditingController phoneController = TextEditingController(
      text: user.phone ?? '',
    );
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User: ${user.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(
                      value: 'user',
                      child: Text('Standard User'),
                    ),
                    DropdownMenuItem(
                      value: 'premium',
                      child: Text('Premium User'),
                    ),
                    DropdownMenuItem(
                      value: 'organizer',
                      child: Text('Tournament Organizer'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrator'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedRole = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would update the user in the database
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  final updatedUser = user.copyWith(
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text.isEmpty
                        ? null
                        : phoneController.text,
                    isAdmin: selectedRole == 'admin',
                    role: selectedRole,
                  );

                  setState(() {
                    final index = _users.indexWhere((u) => u.id == user.id);
                    if (index != -1) {
                      _users[index] = updatedUser;
                    }
                  });

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'User ${nameController.text} updated successfully',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteUser(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete user ${user.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a real app, this would delete the user from the database
                setState(() {
                  _users.removeWhere((u) => u.id == user.id);
                });

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User ${user.name} deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _viewUserProfile(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user.name),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user.photoUrl ??
                          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileDetail('Email', user.email),
                _buildProfileDetail('Role', user.getRoleDisplayName()),
                _buildProfileDetail(
                  'Joined',
                  '${user.registrationDate.day}/${user.registrationDate.month}/${user.registrationDate.year}',
                ),
                if (user.phone != null)
                  _buildProfileDetail('Phone', user.phone!),
                if (user.address != null)
                  _buildProfileDetail('Address', user.address!),
                if (user.bio != null) _buildProfileDetail('Bio', user.bio!),
                const SizedBox(height: 10),
                if (user.stats != null) ...[
                  const Divider(),
                  const Text(
                    'Statistics',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Tournaments', user.stats!['tournaments']),
                      _buildStatItem('Wins', user.stats!['wins']),
                      _buildStatItem('Bookings', user.stats!['bookings']),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditUserDialog(user);
              },
              child: const Text('Edit User'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadUsers();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedFilter,
                        icon: const Icon(Icons.filter_list),
                        items: const [
                          DropdownMenuItem(
                            value: 'All Users',
                            child: Text('All Users'),
                          ),
                          DropdownMenuItem(
                            value: 'Administrators',
                            child: Text('Administrators'),
                          ),
                          DropdownMenuItem(
                            value: 'Standard Users',
                            child: Text('Standard Users'),
                          ),
                          DropdownMenuItem(
                            value: 'Premium Users',
                            child: Text('Premium Users'),
                          ),
                          DropdownMenuItem(
                            value: 'Organizers',
                            child: Text('Organizers'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedFilter = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User statistics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: _buildUserStatCard(
                      'Total',
                      _users.length.toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: _buildUserStatCard(
                      'Admins',
                      _users.where((user) => user.isAdmin).length.toString(),
                      Icons.admin_panel_settings,
                      Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: _buildUserStatCard(
                      'New',
                      _users
                          .where(
                            (user) => user.registrationDate.isAfter(
                              DateTime.now().subtract(const Duration(days: 30)),
                            ),
                          )
                          .length
                          .toString(),
                      Icons.person_add,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                ? const Center(child: Text('No users found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ), // Reduced padding
                          leading: Hero(
                            tag: 'user-avatar-${user.id}',
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                user.photoUrl ??
                                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.name)}',
                              ),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: user.isAdmin
                                          ? Colors.purple
                                          : AppTheme.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user.getRoleDisplayName(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11, // Reduced font size
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Joined ${_getRelativeTime(user.registrationDate)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'view') {
                                _viewUserProfile(user);
                              } else if (value == 'edit') {
                                _showEditUserDialog(user);
                              } else if (value == 'delete') {
                                _confirmDeleteUser(user);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('View Profile'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit User'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete User',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _viewUserProfile(user),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildUserStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10), // Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Use minimum size needed
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16), // Smaller icon
              const SizedBox(width: 4), // Reduced spacing
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontSize: 11, // Smaller font size
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // Reduced spacing
          Text(
            value,
            style: TextStyle(
              fontSize: 18, // Smaller font size
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
