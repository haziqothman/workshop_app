import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> _userFromFirebase(User? user) async {
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser?> registerWithRole({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return await _userFromFirebase(cred.user);
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  Future<AppUser?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await _userFromFirebase(_auth.currentUser);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
