import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login a user by checking credentials in Firestore
  Future<String?> loginUser(String mobileNo, String password) async {
    try {
      // Debug: Print the mobile number being searched
      print('AuthService: Searching for user with mobile number: "$mobileNo"');
      
      // Find the user document where 'mobileNo' matches the input
      final usersSnapshot = await _firestore
          .collection('users')
          .where('mobileNo', isEqualTo: mobileNo)
          .limit(1)
          .get();

      print('AuthService: Found ${usersSnapshot.docs.length} users');

      if (usersSnapshot.docs.isEmpty) {
        return 'User not found.';
      }

      final userData = usersSnapshot.docs.first.data();
      final storedPassword = userData['password'];

      if (password == storedPassword) {
        return null; // Login successful
      } else {
        return 'Invalid mobile number or password.';
      }
    } on FirebaseException catch (e) {
      return 'An error occurred. Please try again.';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Register a new user and add them to the Firestore 'users' collection
  Future<String?> registerUser(String name, String mobileNo, String password) async {
    try {
      // Check if a user with this mobile number already exists
      final existingUser = await _firestore
          .collection('users')
          .where('mobileNo', isEqualTo: mobileNo)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return 'A user with this mobile number already exists.';
      }

      // Debug: Print the mobile number being stored
      print('AuthService: Registering user with mobile number: "$mobileNo"');
      
      // Add the new user to the 'users' collection
      await _firestore.collection('users').add({
        'name': name,
        'mobileNo': mobileNo,
        'password': password,
        'isAdmin': false,
      });

      print('AuthService: User registered successfully');
      return null; // Registration successful
    } on FirebaseException catch (e) {
      return 'Registration failed. Please try again.';
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  // Check if a user is an admin by querying their document
  Future<bool> isAdmin(String mobileNo) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('mobileNo', isEqualTo: mobileNo)
          .limit(1)
          .get();

      if (usersSnapshot.docs.isEmpty) {
        return false;
      }

      final userData = usersSnapshot.docs.first.data();
      return userData['isAdmin'] ?? false;
    } on FirebaseException {
      return false;
    }
  }

  // Simple admin login using a hardcoded check
  Future<String?> loginAdmin(String mobileNo, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (mobileNo == '9999999999' && password == 'admin123') {
      return null; // Login successful
    }
    return 'Invalid mobile number or password';
  }
}
