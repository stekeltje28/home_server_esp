import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/pages/home/setting_page.dart';
import 'package:youtube_chat_app/pages/home/welcome_page.dart';
import 'package:youtube_chat_app/pages/support_page.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:youtube_chat_app/widgets/background_widget.dart';

class HomePage extends StatefulWidget {
  final int initialPageIndex;

  const HomePage({super.key, this.initialPageIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SidebarXController _controller;
  final _key = GlobalKey<ScaffoldState>();
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  String _fullName = '';
  String _pfpURL = '';

  final List<Widget> _pages = [
    const WelcomePage(),
    const SupportPage(),
    const SettingPage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = SidebarXController(selectedIndex: widget.initialPageIndex, extended: true);
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _loadUserProfile();
    _controller.addListener(_handleSidebarChange);
  }

  void _handleSidebarChange() {
    if (_controller.selectedIndex != widget.initialPageIndex) {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      UserProfile? userProfile = await _databaseService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _fullName = userProfile.name ?? 'Onbekend';
          _pfpURL = userProfile.pfpURL ?? '';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      _alertService.showToast(text: 'Fout bij het ophalen van het profiel.', icon: Icons.error_outline);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSidebarChange);
    super.dispose();
  }

  void _onSidebarItemTap(int index) {
    setState(() {
      _controller.selectIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    void openSidebar() {
      if (_key.currentState != null) {
        _key.currentState!.openDrawer();
      }
    }

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Scaffold(
        key: _key,
        drawer: isSmallScreen
            ? ExampleSidebarX(
          controller: _controller,
          onTap: _onSidebarItemTap,
          userProfile: UserProfile(name: _fullName, pfpURL: _pfpURL),
        )
            : null,
        appBar: AppBar(
          actions: [IconButton(onPressed: openSidebar, icon: const Icon(Icons.menu))],
        ),
        body: Row(
          children: [
            if (!isSmallScreen)
              ExampleSidebarX(
                controller: _controller,
                onTap: _onSidebarItemTap,
                userProfile: UserProfile(name: _fullName, pfpURL: _pfpURL),
              ),
            Expanded(
              child: BackgroundContainer(
                child: IndexedStack(
                  index: _controller.selectedIndex,
                  children: _pages,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const primaryColor = Color(0xFF0D1117);
const canvasColor = Color(0xFF000A27);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3));

class ExampleSidebarX extends StatefulWidget {
  ExampleSidebarX({
    super.key,
    required SidebarXController controller,
    required this.onTap,
    required this.userProfile,
  }) : _controller = controller;

  final SidebarXController _controller;
  final void Function(int) onTap;
  UserProfile userProfile;

  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }



  Future<void> _editProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(DateTime.now().toIso8601String());

        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await _databaseService.updateUserProfilePicture(downloadUrl);

        setState(() {
          widget.userProfile = widget.userProfile.copyWith(pfpURL: downloadUrl);
        });

        _alertService.showToast(text: 'Profile picture updated!', icon: Icons.check);

      } catch (e) {
        _alertService.showToast(text: 'Error updating profile picture.', icon: Icons.error_outline);
      }
    } else {
      _alertService.showToast(text: 'No image selected.', icon: Icons.info_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget._controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: canvasColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: canvasColor,
        ),
      ),
      headerBuilder: (context, extended) {
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent, // Maakt de achtergrond van de dialog transparant
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop(); // Sluit de dialog wanneer je op de afbeelding klikt
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8, // 80% van de schermbreedte
                                height: MediaQuery.of(context).size.width * 0.8, // 80% van de schermbreedte
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: widget.userProfile.pfpURL!.isNotEmpty
                                        ? NetworkImage(widget.userProfile.pfpURL!) // force reload
                                        : const AssetImage('assets/image/default_profile.png') as ImageProvider,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.userProfile.pfpURL!.isNotEmpty
                          ? NetworkImage(widget.userProfile.pfpURL!) // force reload
                          : const AssetImage('assets/image/default_profile.png') as ImageProvider,
                    ),
                  ),

                  if (extended) // Show the edit icon only when sidebar is extended
                    Positioned(
                      bottom: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: _editProfilePicture,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (extended) // Show name text only when sidebar is extended
                const SizedBox(height: 10),
              if (extended)
                Text(
                  widget.userProfile.name ?? 'Onbekend',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        );
      },
      footerDivider: divider,
      items: [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () => widget.onTap(0),
        ),
        SidebarXItem(
          icon: Icons.people_rounded,
          label: 'Support',
          onTap: () => widget.onTap(1),
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () => widget.onTap(2),
        ),
        SidebarXItem(
          icon: Icons.logout,
          label: 'Uitloggen',
          onTap: () async {
            bool result = await _authService.logout();
            if (result) {
              _navigationService.pushReplacementNamed('/login');
            }
          },
        ),
      ],
    );
  }
}
