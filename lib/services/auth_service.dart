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

  // Constructor: Luistert naar wijzigingen in de authenticatiestatus
  AuthService() {
    _firebaseAuth.authStateChanges().listen(_authStateChangesStreamListener);
  }

  // Callback voor auth status veranderingen
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

  // Haal het gebruikersprofiel op uit Firestore
  Future<UserProfile?> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _userProfile = UserProfile.fromJson(doc.data()!);
        notifyListeners(); // Update de UI
        return _userProfile;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }

  // Inloggen met email en wachtwoord
  Future<bool> login(String email, String password) async {
    print('Probeer in te loggen met email: $email');
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user; // Sla de ingelogde gebruiker op
      if (_user != null) {
        await _fetchUserProfile(_user!.uid);
        print('Inloggen geslaagd: $_user');
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  // Registreren van een nieuwe gebruiker
  Future<bool> signup(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = credential.user;
        await _firestore.collection('users').doc(_user!.uid).set({
          'uid': _user!.uid,
          'email': _user!.email,
          'access': true,
          'pfpURL': 'https://example.com/default-profile-pic.png', // Standaard profielafbeelding
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

  // Afmelden van de gebruiker
  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();
      _user = null; // Reset de gebruiker
      _userProfile = null; // Reset het gebruikersprofiel
      notifyListeners(); // Update de UI
      return true;
    } catch (e) {
      print('Error during logout: $e');
    }
    return false;
  }

  // Verkrijg het toegangstoken van de ingelogde gebruiker
  Future<String?> getToken() async {
    try {
      // Verkrijg het huidige gebruiker
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        // Verkrijg het token
        String? token = await user.getIdToken();
        print('Access token: $token');
        return token;
      } else {
        print('Geen gebruiker ingelogd');
      }
    } catch (e) {
      print('Error getting token: $e');
    }
    return null;
  }
}
