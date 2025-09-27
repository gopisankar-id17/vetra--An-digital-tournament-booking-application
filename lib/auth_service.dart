import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/session_service.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory storage for users (for demo without Firebase)
  static final List<Map<String, dynamic>> _users = [];

  // Admin login - check credentials in admins collection
  Future<Map<String, dynamic>> loginAdmin(String emailOrPhone, String password) async {
    try {
      print('AuthService: Checking admin credentials for: $emailOrPhone');
      
      // Try to find admin in Firestore admins collection
      QuerySnapshot adminQuery;
      
      // Check if input is email or phone
      if (emailOrPhone.contains('@')) {
        adminQuery = await _firestore
            .collection('admins')
            .where('email', isEqualTo: emailOrPhone)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();
      } else {
        adminQuery = await _firestore
            .collection('admins')
            .where('phone', isEqualTo: emailOrPhone)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();
      }

      if (adminQuery.docs.isNotEmpty) {
        print('AuthService: Admin found in Firestore');
        final adminData = adminQuery.docs.first.data() as Map<String, dynamic>;
        
        // Create admin session
        await SessionService.createAdminSession(
          adminId: adminQuery.docs.first.id,
          email: adminData['email'] ?? emailOrPhone,
          name: adminData['name'] ?? adminData['fullName'] ?? 'Admin',
        );
        
        return {
          'success': true,
          'message': 'Login successful',
          'data': adminData,
        };
      } else {
        print('AuthService: Admin not found in Firestore');
        return {
          'success': false,
          'message': 'Invalid email/phone or password',
        };
      }
    } catch (e) {
      print('AuthService: Error checking admin credentials: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // User login - check credentials in users collection or in-memory
  Future<Map<String, dynamic>> loginUser(String phoneNumber, String password) async {
    try {
      print('AuthService: Checking user credentials for: $phoneNumber');
      
      // First check in-memory users
      for (var user in _users) {
        if (user['phoneNumber'] == phoneNumber && user['password'] == password) {
          print('AuthService: User found in memory');
          
          // Create user session
          await SessionService.createUserSession(
            userId: user['id'],
            phoneNumber: user['phoneNumber'],
            name: user['fullName'] ?? user['name'] ?? 'User',
          );
          
          return {
            'success': true,
            'message': 'Login successful',
            'data': user,
          };
        }
      }
      
      // If not found in memory, try Firestore
      try {
        final userQuery = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          print('AuthService: User found in Firestore');
          final userData = userQuery.docs.first.data() as Map<String, dynamic>;
          
          // Create user session
          await SessionService.createUserSession(
            userId: userQuery.docs.first.id,
            phoneNumber: userData['phoneNumber'],
            name: userData['fullName'] ?? userData['name'] ?? 'User',
          );
          
          return {
            'success': true,
            'message': 'Login successful',
            'data': userData,
          };
        }
      } catch (firestoreError) {
        print('AuthService: Firestore error, using memory only: $firestoreError');
      }
      
      print('AuthService: User not found');
      return {
        'success': false,
        'message': 'Invalid phone number or password',
      };
    } catch (e) {
      print('AuthService: Error checking user credentials: $e');
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // User registration - simple in-memory storage
  Future<String?> registerUser({
    required String phoneNumber,
    required String password,
    String? email,
    String? fullName,
  }) async {
    try {
      print('AuthService: Registering user with phone: $phoneNumber');
      
      // Check if user already exists in memory
      for (var user in _users) {
        if (user['phoneNumber'] == phoneNumber) {
          return 'Phone number already registered';
        }
        if (email != null && email.isNotEmpty && user['email'] == email) {
          return 'Email already registered';
        }
      }
      
      // Check Firestore as well
      try {
        final existingUser = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .limit(1)
            .get();

        if (existingUser.docs.isNotEmpty) {
          return 'Phone number already registered';
        }
      } catch (firestoreError) {
        print('AuthService: Firestore error, using memory only: $firestoreError');
      }
      
      // Add user to in-memory storage
      final newUser = {
        'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
        'phoneNumber': phoneNumber,
        'password': password,
        'email': email,
        'fullName': fullName,
        'createdAt': DateTime.now().toIso8601String(),
      };
      
      _users.add(newUser);
      
      // Try to save to Firestore as well
      try {
        await _firestore.collection('users').add(newUser);
        print('AuthService: User saved to Firestore');
      } catch (firestoreError) {
        print('AuthService: Could not save to Firestore, saved in memory only');
      }
      
      print('AuthService: User registered successfully');
      return null; // Registration successful
    } catch (e) {
      print('AuthService: Error registering user: $e');
      return 'Registration failed. Please try again.';
    }
  }

  // Logout methods
  Future<void> logoutAdmin() async {
    await SessionService.clearAdminSession();
    print('AuthService: Admin logged out');
  }

  Future<void> logoutUser() async {
    await SessionService.clearUserSession();
    print('AuthService: User logged out');
  }

  Future<void> logoutAll() async {
    await SessionService.clearAllSessions();
    print('AuthService: All sessions cleared');
  }

  // Session check methods
  Future<bool> isAdminLoggedIn() async {
    return await SessionService.isAdminLoggedIn();
  }

  Future<bool> isUserLoggedIn() async {
    return await SessionService.isUserLoggedIn();
  }

  Future<Map<String, String?>> getCurrentAdminSession() async {
    return await SessionService.getAdminSession();
  }

  Future<Map<String, String?>> getCurrentUserSession() async {
    return await SessionService.getUserSession();
  }
}
