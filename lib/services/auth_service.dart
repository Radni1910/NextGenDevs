import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Method to check if user is signed in
  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  // Method to sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Method to get user role from Firestore
  static Future<String?> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          return data?['role'];
        }
      } catch (e) {
        print('Error getting user role: $e');
      }
    }
    return null;
  }

  // Method to save user role to Firestore
  static Future<void> saveUserRole(
      String uid,
      String role,
      Map<String, dynamic> userData,
      ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        ...userData,
      });
    } catch (e) {
      print('Error saving user role: $e');
    }
  }

  // Method to check if user account is approved (for management accounts)
  static Future<bool> isAccountApproved() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          return data?['approved'] ??
              true; // Students are auto-approved, management needs approval
        }
      } catch (e) {
        print('Error checking account approval: $e');
      }
    }
    return false;
  }
}
