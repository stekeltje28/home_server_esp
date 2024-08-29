import 'package:flutter/material.dart';
import 'package:youtube_chat_app/models/user_profile.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;
  final bool? access;

  const ChatTile({
    super.key,
    required this.userProfile,
    required this.onTap,
    this.access = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(
          userProfile.pfpURL!,
        ),
      ),
      title:  Text(userProfile.name!,
        style: const TextStyle(
        color: Color(0xCDCACACA)
      ),),
    );
  }
}
