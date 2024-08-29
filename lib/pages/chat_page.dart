import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/models/chat.dart';
import 'package:youtube_chat_app/models/message.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/media_service.dart';
import 'package:youtube_chat_app/services/storage_service.dart';
import 'package:youtube_chat_app/utils.dart';

import '../services/local_storage.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({
    super.key,
    required this.chatUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FocusNode _focusNode = FocusNode();
  Color _fillColor = Colors.grey[300]!;
  final GetIt _getIt = GetIt.instance;
  bool _showtime = false;

  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();

    // Laad de _showtime waarde van local storage
    _loadShowtime();

    currentUser = ChatUser(
      id: _authService.user!.uid,
      firstName: _authService.user!.displayName,

    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  void _loadShowtime() async {
    // Verkrijg de opgeslagen showtime waarde van LocalStorage
    var storedShowtime = LocalStorage.get('showtime') ?? false;
    setState(() {
      _showtime = storedShowtime;
    });
  }

  void _onFocusChange() {
    setState(() {
      _fillColor = _focusNode.hasFocus ? Colors.white : Colors.grey[300]!;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatUser.pfpURL!),
            ),
            SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
            Expanded(
              child: Text(
                widget.chatUser.name!,
                overflow: TextOverflow.ellipsis, // Handle long names gracefully
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: () {
              setState(() {
                _showtime = !_showtime;
                LocalStorage.save('showtime', _showtime);
              });
            },
          )
        ],
      ),

      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _generateChatMessagesList(chat.messages!);
        }
        return DashChat(
          messageOptions: MessageOptions(
            messageDecorationBuilder: (ChatMessage message, ChatMessage? previousMessage, ChatMessage? nextMessage) {
              bool isUser = message.user.id == currentUser!.id;
              return BoxDecoration(
                color: isUser ? Colors.black : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.0),
              );
            },
            showOtherUsersAvatar: true,
            showOtherUsersName: true,
            showTime: _showtime,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            inputDecoration: InputDecoration(
              hintText: 'Typ hier je bericht!',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: _fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
              contentPadding: const EdgeInsets.only(
                right: 20.0,
                left: 20.0,
                top: 20.0,
              ),
            ),
            trailing: [
              _mediaMessageButton(),
            ],
            focusNode: _focusNode,
            sendButtonBuilder: (sendMessageCallback) {
              return IconButton(
                onPressed: sendMessageCallback,
                icon: const Icon(Icons.send, color: Colors.black), // Zwart pictogram
                splashColor: Colors.grey, // Splashkleur
                iconSize: 24.0,
              );
            },
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }

  Future<void> _sendMessage (ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessage(
          currentUser!.id,
          otherUser!.id,
          message,
        );
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );

      await _databaseService.sendChatMessage(
        currentUser!.id,
        otherUser!.id,
        message,
      );
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(url: m.content!, fileName: '', type: MediaType.image)
          ],
        );
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatID = generateChatID(
              uid1: currentUser!.id,
              uid2: otherUser!.id);
          String? downloadURL = await _storageService.uploadImageToChat(file: file, chatID: chatID);
          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
              user: currentUser!,
              createdAt: DateTime.now(),
              medias: [ChatMedia(url: downloadURL, fileName: '', type: MediaType.image)],
            );
            _sendMessage(chatMessage);
          }
        }
      },
      icon: const Icon(
        Icons.image,
        color: Colors.black,
      ),
    );
  }
}
