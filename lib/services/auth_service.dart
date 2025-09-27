import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/admin_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory storage for demo purposes (since Firestore might not be set up)
  static final List<UserModel> _users = [];
  static final List<AdminModel> _admins = [
    // Pre-populated admin for testing (matching Firestore data)
    AdminModel(
      id: 'admin1',
      email: 'admin@gmail.com',
      phoneNumber: '8989898989',
      password: 'admin', // Simple password
      fullName: 'admin',
      createdAt: DateTime.now(),
    ),
  ];

  // Admin Authentication (checks Firestore first, then in-memory)
  Future<AdminModel?> authenticateAdmin(
    String emailOrPhone,
    String password,
  ) async {
    try {
      // First, try to authenticate from Firestore
      try {
        // Query by email first
        QuerySnapshot emailQuery = await _firestore
            .collection('admins')
            .where('email', isEqualTo: emailOrPhone)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();

        if (emailQuery.docs.isNotEmpty) {
          print('Admin found in Firestore by email');
          return AdminModel.fromMap(
            emailQuery.docs.first.data() as Map<String, dynamic>,
          );
        }

        // If not found by email, try phone number
        QuerySnapshot phoneQuery = await _firestore
            .collection('admins')
            .where('phoneNumber', isEqualTo: emailOrPhone)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();

        if (phoneQuery.docs.isNotEmpty) {
          print('Admin found in Firestore by phone');
          return AdminModel.fromMap(
            phoneQuery.docs.first.data() as Map<String, dynamic>,
          );
        }

        print('Admin not found in Firestore, checking in-memory data');
      } catch (firestoreError) {
        print('Firestore error: $firestoreError, checking in-memory data');
      }

      // If not found in Firestore, check in-memory admins
      for (AdminModel admin in _admins) {
        if ((admin.email == emailOrPhone || admin.phoneNumber == emailOrPhone) &&
            admin.password == password) {
          print('Admin found in in-memory data');
          return admin;
        }
      }

      print('Admin not found in either Firestore or in-memory data');
      return null; // Admin not found or invalid credentials
    } catch (e) {
      print('Error authenticating admin: $e');
      return null;
    }
  }

  // User Authentication (simplified for demo)
  Future<UserModel?> authenticateUser(
    String phoneNumber,
    String password,
  ) async {
    try {
      // Check in-memory users first
      for (UserModel user in _users) {
        if (user.phoneNumber == phoneNumber && user.password == password) {
          return user;
        }
      }

      // If not found in memory, try Firestore (if configured)
      try {
        QuerySnapshot query = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          return UserModel.fromMap(
            query.docs.first.data() as Map<String, dynamic>,
          );
        }
      } catch (firestoreError) {
        print('Firestore not configured, using in-memory data only');
      }

      return null; // User not found or invalid credentials
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  // Register User
  Future<UserModel?> registerUser({
    required String phoneNumber,
    required String password,
    String? email,
    String? fullName,
  }) async {
    try {
      // Check if phone number already exists in memory
      for (UserModel user in _users) {
        if (user.phoneNumber == phoneNumber) {
          throw Exception('Phone number already registered');
        }
        if (email != null && email.isNotEmpty && user.email == email) {
          throw Exception('Email already registered');
        }
      }

      // Also check Firestore if available
      try {
        QuerySnapshot existingUser = await _firestore
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .limit(1)
            .get();

        if (existingUser.docs.isNotEmpty) {
          throw Exception('User with this phone number already exists');
        }

        // Check if email is already used (if provided)
        if (email != null && email.isNotEmpty) {
          QuerySnapshot existingEmail = await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          if (existingEmail.docs.isNotEmpty) {
            throw Exception('User with this email already exists');
          }
        }
      } catch (firestoreError) {
        print('Firestore not configured, checking in-memory data only');
      }

      final now = DateTime.now();
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      final user = UserModel(
        id: userId,
        phoneNumber: phoneNumber,
        password: password, // Simple password, no hashing
        email: email,
        fullName: fullName,
        createdAt: now,
      );

      // Add to in-memory storage
      _users.add(user);

      // Try to save to Firestore (if configured)
      try {
        DocumentReference userRef = _firestore.collection('users').doc(userId);
        await userRef.set(user.toMap());
      } catch (firestoreError) {
        print('Firestore not configured, user saved in memory only');
      }

      return user;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // Create Admin (for initial setup)
  Future<AdminModel?> createAdmin({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      // Check if admin already exists
      QuerySnapshot existingAdmin = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingAdmin.docs.isNotEmpty) {
        throw Exception('Admin with this email already exists');
      }

      final now = DateTime.now();
      final adminId = 'admin_${DateTime.now().millisecondsSinceEpoch}';

      final admin = AdminModel(
        id: adminId,
        email: email,
        phoneNumber: phoneNumber,
        password: password, // Simple password, no hashing
        fullName: fullName,
        createdAt: now,
      );

      // Add to in-memory storage
      _admins.add(admin);

      // Try to save to Firestore (if configured)
      try {
        DocumentReference adminRef = _firestore.collection('admins').doc(adminId);
        await adminRef.set(admin.toMap());
      } catch (firestoreError) {
        print('Firestore not configured, admin saved in memory only');
      }

      return admin;
    } catch (e) {
      print('Error creating admin: $e');
      rethrow;
    }
  }

  // Check if phone number exists
  Future<bool> phoneNumberExists(String phoneNumber) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      QuerySnapshot adminQuery = await _firestore
          .collection('admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return userQuery.docs.isNotEmpty || adminQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}
