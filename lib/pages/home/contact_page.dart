import 'dart:ui';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/pages/chat_page.dart';
import 'package:youtube_chat_app/pages/home_page.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GetIt _getIt = GetIt.instance;

  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  void _belNummer(String nummer) async {
    final Uri url = Uri(scheme: 'tel', path: nummer);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Kon de telefoonapp niet openen';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0x00000000),
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage(initialPageIndex: 1)),
            );
          },
          icon: const Icon(Icons.arrow_back),
          iconSize: 32.0,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: _buildUI(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chatList(),
          ],
        ),
      ),
    );
  }

  Widget _chatList() {
    return StreamBuilder<QuerySnapshot<UserProfile>>(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Niet mogelijk data te laden",
              style: TextStyle(color: Colors.black),
            ),
          );
        }
        if (snapshot.hasData) {
          final users = snapshot.data!.docs;
          final currentUserAccess = _authService.userProfile?.access ?? false;

          if (users.isEmpty) {
            return const Center(
              child: Text(
                "Geen contacten beschikbaar",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final usersWithAccess = users.where((doc) => doc.data().access == true).map((doc) => doc.data()).toList();
          final usersWithoutAccess = users.where((doc) => doc.data().access == false).map((doc) => doc.data()).toList();

          final filteredUsers = currentUserAccess ? usersWithAccess + usersWithoutAccess : usersWithAccess;

          if (filteredUsers.isEmpty) {
            return const Center(
              child: Text(
                "Geen contacten beschikbaar",
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentUserAccess) ...[
                _sectionTitle("Contacten met toegang"),
                ...usersWithAccess.map((user) => contactTrue(user)),
                _sectionTitle("Contacten zonder toegang"),
                ...usersWithoutAccess.map((user) => contactFalse(user)),
              ] else
                ...[
                  _sectionTitle("Medewerkers"),
                  ...usersWithAccess.map((user) => contactTrue(user)),
                ],
            ],
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget contactFalse(UserProfile user) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width > 600 ? 1000 : MediaQuery.of(context).size.width,
            ),
            child: BlurryContainer(
              blur: 10,
              width: double.infinity,
              elevation: 0,
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.pfpURL ?? ''),
                        radius: 30,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          user.name ?? '',
                          style: TextStyle(color: Colors.black, fontSize: 15 * MediaQuery.of(context).textScaleFactor),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.black),
                        onPressed: () {
                          _belNummer('123456789');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat, color: Colors.black),
                        onPressed: () async {
                          final chatExists = await _databaseService.checkChatExist(
                            _authService.user!.uid,
                            user.uid!,
                          );
                          if (!chatExists) {
                            await _databaseService.createNewChat(
                              _authService.user!.uid,
                              user.uid!,
                            );
                          }
                          _navigationService.push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(chatUser: user);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget contactTrue(UserProfile user) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width > 600 ? 1000 : MediaQuery.of(context).size.width,
            ),
            child: BlurryContainer(
              elevation: 0,
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ExpansionTile(
                    iconColor: Colors.black,
                    collapsedIconColor: Colors.black,
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      height: MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: user.pfpURL!.isNotEmpty
                                              ? NetworkImage(user.pfpURL!)
                                              : const AssetImage('assets/image/default.jpg') as ImageProvider,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(user.pfpURL ?? ''),
                            radius: 24, // Verklein de straal van de afbeelding
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            user.name ?? '',
                            style: TextStyle(color: Colors.black, fontSize: 15 * MediaQuery.of(context).textScaleFactor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          iconSize: 21,
                          icon: const Icon(Icons.call, color: Colors.black),
                          onPressed: () {
                            _belNummer('123456789');
                          },
                        ),
                        IconButton(
                          iconSize: 21,
                          icon: const Icon(Icons.chat, color: Colors.black),
                          onPressed: () async {
                            final chatExists = await _databaseService.checkChatExist(
                              _authService.user!.uid,
                              user.uid!,
                            );
                            if (!chatExists) {
                              await _databaseService.createNewChat(
                                _authService.user!.uid,
                                user.uid!,
                              );
                            }
                            _navigationService.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChatPage(chatUser: user);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    backgroundColor: Colors.black.withOpacity(0.0),
                    children: user.access == true ? [_availabilityList()] : [],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _availabilityList() {
    final availability = [
      "Maandag: 9:00 - 17:00",
      "Dinsdag: 10:00 - 18:00",
      "Woensdag: 9:00 - 17:00",
      "Donderdag: 12:00 - 20:00",
      "Vrijdag: 9:00 - 15:00",
      "Zaterdag: Niet beschikbaar",
      "Zondag: Niet beschikbaar",
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: availability.map((day) =>
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(day,
                style: TextStyle(color: Colors.black, fontSize: 16 * MediaQuery.of(context).textScaleFactor)),
          )).toList(),
    );
  }
}

class GradientBall extends StatelessWidget {
  final List<Color> colors;
  final Size size;

  const GradientBall({
    super.key,
    required this.colors,
    this.size = const Size.square(150),
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}
