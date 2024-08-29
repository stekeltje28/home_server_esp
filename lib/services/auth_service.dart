import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_chat_app/models/user_profile.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserProfile? _userProfile;

  User? get user => _user;
  UserProfile? get userProfile => _userProfile;

  AuthService() {
    _firebaseAuth.authStateChanges().listen(_authStateChangesStreamListener);
  }

  void _authStateChangesStreamListener(User? user) async {
    if (user != null) {
      _user = user;
      await _fetchUserProfile(user.uid);
    } else {
      _user = null;
      _userProfile = null;
    }
    notifyListeners(); // Update de UI
  }

  Future<UserProfile?> _fetchUserProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _userProfile = UserProfile.fromJson(data);
          notifyListeners(); // Update de UI
          return _userProfile;
        }
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    print('Probeer in te loggen met email: $email');
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Inloggen geslaagd: ${credential.user}');
      if (credential.user != null) {
        _user = credential.user;
        await _fetchUserProfile(_user!.uid);
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  Future<bool> signup(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        _user = credential.user;
        await _firestore.collection('users').doc(_user!.uid).set({
          'uid': _user!.uid,
          'email': _user!.email,
          'access': true,
          'pfpURL': 'https://example.com/default-profile-pic.png',
          'name': '',
        });
        await _fetchUserProfile(_user!.uid);
        return true;
      }
    } catch (e) {
      print('Signup error: $e');
    }
    return false;
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null;
      _userProfile = null;
      notifyListeners(); // Update de UI
      return true;
    } catch (e) {
      print('Error during logout: $e');
    }
    return false;
  }
}
