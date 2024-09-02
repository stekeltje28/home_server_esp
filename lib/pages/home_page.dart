import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/pages/support_page.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'home/contact_page.dart';
import 'home/setting_page.dart';
import 'home/welcome_page.dart';
import 'login_page.dart';

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

  String _headText = 'Welkom';
  String _fullName = '';
  String _pfpURL = '';

  final List<Widget> _pages = [
    WelcomePage(),
    SupportPage(),
    SettingPage(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = SidebarXController(selectedIndex: widget.initialPageIndex, extended: true);
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _controller.addListener(_handleSidebarChange);
    _loadUserProfile();
    _updateHeadText();
  }

  void _handleSidebarChange() {
    print('Sidebar Index Changed: ${_controller.selectedIndex}');
    _updateHeadText();
  }

  void _updateHeadText() {
    List<List<String>> texts = [
      ["Welkom bij de Welkomstpagina!", "Hallo en welkom op onze site!", "Fijn dat je hier bent!"],
      ["Neem contact met ons op!", "We horen graag van je!", "Stuur ons een bericht!"],
      ["Dit zijn de instellingen.", "Hier kun je je voorkeuren aanpassen.", "Beheer je accountinstellingen hier."]
    ];

    if (_controller.selectedIndex < texts.length) {
      setState(() {
        _headText = texts[_controller.selectedIndex][Random().nextInt(texts[_controller.selectedIndex].length)];
        print('Updated Head Text for Index ${_controller.selectedIndex}: $_headText'); // Debugging
      });
    } else {
      setState(() {
        _headText = "Onbekende pagina.";
        print('Head Text for Unknown Index: $_headText'); // Debugging
      });
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
      _alertService.showToast(
        text: 'Fout bij het ophalen van het profiel.',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSidebarChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Builder(
        builder: (context) {
          final isSmallScreen = MediaQuery.of(context).size.width < 600;
          return Scaffold(
            key: _key,
            drawer: isSmallScreen
                ? ExampleSidebarX(
              controller: _controller,
              userProfile: UserProfile(name: _fullName, pfpURL: _pfpURL),
              onTap: () {
                _handleSidebarChange();
                _key.currentState?.openDrawer();
              },
            )
                : null,
            body: Row(
              children: [
                if (!isSmallScreen)
                  ExampleSidebarX(
                    controller: _controller,
                    userProfile: UserProfile(name: _fullName, pfpURL: _pfpURL),
                    onTap: () {
                      _handleSidebarChange();
                    },
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildBackground(),
                      Column(
                        children: [
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _headText,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: min(MediaQuery.of(context).size.width * 0.03 + MediaQuery.of(context).size.height * 0.01, 35),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _fullName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: const Color(0xCCDCDCDC),
                                        fontSize: min(MediaQuery.of(context).size.width * 0.03 + MediaQuery.of(context).size.height * 0.01, 25),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isSmallScreen)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: IconButton(
                                      onPressed: () {
                                        _key.currentState?.openDrawer();
                                      },
                                      icon: const Icon(
                                        Icons.menu,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: IndexedStack(
                              index: _controller.selectedIndex,
                              children: _pages,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Positioned(
          bottom: 10,
          left: 10,
          child: GradientBall(
            colors: [Colors.black45, Colors.green],
            size: Size.square(150),
          ),
        ),
        const Positioned(
          top: 100,
          right: 10,
          child: GradientBall(
            size: Size.square(120),
            colors: [Colors.purple, Colors.blue],
          ),
        ),
        const Positioned(
          top: 50,
          left: 20,
          child: GradientBall(
            size: Size.square(80),
            colors: [Colors.orange, Colors.yellowAccent],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}


class ExampleSidebarX extends StatefulWidget {
  final SidebarXController controller;
  final VoidCallback onTap;
  UserProfile userProfile;

  ExampleSidebarX({
    Key? key,
    required this.controller,
    required this.onTap,
    required this.userProfile,
  }) : super(key: key);

  @override
  _ExampleSidebarXState createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance.get<AuthService>();
    _navigationService = GetIt.instance.get<NavigationService>();
    _alertService = GetIt.instance.get<AlertService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
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

        // Start het uploaden van het bestand
        final uploadTask = storageRef.putFile(imageFile);

        // Wacht tot de upload is voltooid en verkrijg de download URL
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Werk de gebruikersprofielafbeelding bij in de database
        await _databaseService.updateUserProfilePicture(downloadUrl);

        // Werk de status van de gebruikersprofielafbeelding bij
        setState(() {
          widget.userProfile = widget.userProfile.copyWith(pfpURL: downloadUrl);
        });

        // Toon een succesmelding
        _alertService.showToast(
          text: 'Profile picture updated!',
          icon: Icons.check,
        );

      } catch (e) {
        // Toon een foutmelding als er iets misgaat
        _alertService.showToast(
          text: 'Error updating profile picture.',
          icon: Icons.error_outline,
        );
        print('Error updating profile picture: $e'); // Optioneel: voor debugging
      }
    } else {
      // Toon een melding als er geen afbeelding is geselecteerd
      _alertService.showToast(
        text: 'No image selected.',
        icon: Icons.info_outline,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget.controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
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
          border: Border.all(color: actionColor.withOpacity(0.37)),
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
                            backgroundColor: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: widget.userProfile.pfpURL!.isNotEmpty
                                        ? NetworkImage(widget.userProfile.pfpURL!)
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
                      radius: 50,
                      backgroundImage: widget.userProfile.pfpURL!.isNotEmpty
                          ? NetworkImage(widget.userProfile.pfpURL!)
                          : const AssetImage('assets/image/default.jpg') as ImageProvider,
                    ),
                  ),
                  if (extended)
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
              if (extended)
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
          onTap: () {
            widget.onTap();
            widget.controller.selectIndex(0);
          },
        ),
        SidebarXItem(
          icon: Icons.people_rounded,
          label: 'Support',
          onTap: () {
            widget.onTap();
            widget.controller.selectIndex(1);
          },
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            widget.onTap();
            widget.controller.selectIndex(2);
          },
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

const primaryColor = Color(0xFF0D1117);
const canvasColor = Color(0xFF000A27);
const scaffoldBackgroundColor = Color(0x66022E70);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

class GradientBall extends StatelessWidget {
  final List<Color> colors;
  final Size size;

  const GradientBall({
    Key? key,
    required this.colors,
    this.size = const Size.square(150),
  }) : super(key: key);

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
