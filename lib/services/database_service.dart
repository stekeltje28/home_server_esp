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
      throw Exception('Failed to create user profile: $e');
    }
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    final currentUserId = _authService.user?.uid ?? '';
    return _userCollection!
        .where("uid", isNotEqualTo: currentUserId)
        .snapshots();
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    final chatID = generateChatID(uid1: uid1, uid2: uid2);
    try {
      final result = await _chatsCollection?.doc(chatID).get();
      return result?.exists ?? false;
    } catch (e) {
      throw Exception('Failed to check chat existence: $e');
    }
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    final chatID = generateChatID(uid1: uid1, uid2: uid2);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
    );
    try {
      await _chatsCollection?.doc(chatID).set(chat);
    } catch (e) {
      throw Exception('Failed to create new chat: $e');
    }
  }

  Future<void> sendChatMessage(String uid1, String uid2, Message message) async {
    final chatID = generateChatID(uid1: uid1, uid2: uid2);
    try {
      await _chatsCollection?.doc(chatID).update({
        "messages": FieldValue.arrayUnion([message.toJson()]),
      });
    } catch (e) {
      throw Exception('Failed to send chat message: $e');
    }
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    final chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection!.doc(chatID).snapshots();
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
      throw Exception('Failed to get user profile: $e');
    }
  }
}
