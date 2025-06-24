import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/models/chat.dart';
import 'package:youtube_chat_app/models/message.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/utils.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  late AuthService _authService;

  CollectionReference<UserProfile>? _userCollection;
  CollectionReference<Chat>? _chatsCollection;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _setupCollectionReferences();
  }

  void _setupCollectionReferences() {
    _userCollection = _firebaseFirestore.collection('users').withConverter<UserProfile>(
      fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
      toFirestore: (userProfile, _) => userProfile.toJson(),
    );

    _chatsCollection = _firebaseFirestore.collection('chats').withConverter<Chat>(
      fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
      toFirestore: (chat, _) => chat.toJson(),
    );
  }

  Future<void> updateUserProfilePicture(String url) async {
    final userId = _getCurrentUserId();
    if (userId.isNotEmpty) {
      try {
        await _userCollection?.doc(userId).update({'pfpURL': url});
      } catch (e) {
        print('Failed to update profile picture: $e');
        throw Exception('Failed to update profile picture: $e');
      }
    } else {
      throw Exception('User ID is not available.');
    }
  }

  String _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    try {
      await _userCollection?.doc(userProfile.uid).set(userProfile);
    } catch (e) {
      print('Failed to create user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    final currentUserId = _authService.user?.uid ?? '';
    return _userCollection!
        .where("uid", isNotEqualTo: currentUserId)
        .snapshots();
  }


  Future<UserProfile?> getUserProfile() async {
    final uid = _authService.user?.uid;
    if (uid == null) {
      return null;
    }
    try {
      final docSnapshot = await _userCollection?.doc(uid).get();
      return docSnapshot?.data();
    } catch (e) {
      print('Failed to get user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }
}
