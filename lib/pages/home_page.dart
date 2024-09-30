import 'dart:math';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/pages/home/add_content_page.dart';
import 'package:youtube_chat_app/pages/home/view_content.dart';
import 'package:youtube_chat_app/pages/support_page.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'home/setting_page.dart';
import 'home/welcome_page.dart';

class HomePage extends StatefulWidget {
  final int initialPageIndex;

  const HomePage({super.key, this.initialPageIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _key = GlobalKey<ScaffoldState>();
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  String _headText = 'Welkom';
  String _fullName = 'test';
  String _pfpURL = '';
  int currentIndex = 0;

  final ImagePicker _picker = ImagePicker();

  final List<Widget> _pages = [
    const WelcomePage(),
    const SupportPage(),
    const AddContentPage(),
    const ViewContent(),
    SettingPage(userProfile: UserProfile()),
  ];

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _loadUserProfile();
    _updateHeadText();
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

  void _updateHeadText() {
    List<List<String>> texts = [
      [ //welcome page
        "Welkom bij de Welkomstpagina!",
        "Hallo en welkom op onze app!",
        "Fijn dat je hier bent!"
      ],
      [ // support page
        "Neem contact met ons op!",
        "We horen graag van je!",
        "Stuur ons een bericht!"
      ],
      [ // content toevoegen
        'voeg je content toe!',
        'bepaal je eigen style!',
        'doe het makkelijk en snel!'
      ],
      [ //content beheren
        'verbeter je content!',
        'zie wat je hebt!',
        'beheer je content!'
      ],
      [  //settingpage
        "Dit zijn de instellingen.",
        "Hier kun je je voorkeuren aanpassen.",
        "Beheer je accountinstellingen hier."
      ]
    ];

    setState(() {
      _headText = texts[currentIndex][Random().nextInt(texts[currentIndex].length)];
      print('Updated Head Text for Index $currentIndex: $_headText'); // Debugging
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
      home: Scaffold(
        key: _key,
        bottomNavigationBar: BottomBarInspiredFancy(
          items: const [
            //homepage
            TabItem(
              icon: Icons.home,
              title: 'Home',
            ),
            //supportpage
            TabItem(
              icon: Icons.people_rounded,
              title: 'Support',
            ),
            //addcontentpage
            TabItem(
              icon: Icons.add,
              title: 'Voeg toe',
            ),
            //viewcontentpage
            TabItem(
              icon: Icons.article,
              title: 'Content',
            ),
            //settingpage
            TabItem(
              icon: Icons.settings,
              title: 'Instellingen',
            ),
          ],
          backgroundColor: Colors.white,
          color: Colors.black,
          colorSelected: Colors.blue,
          indexSelected: currentIndex,
          styleIconFooter: StyleIconFooter.dot,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
              _updateHeadText();
            });
          },
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _headText,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: min(
                              MediaQuery.of(context).size.width * 0.03 +
                                  MediaQuery.of(context).size.height * 0.01,
                              35),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fullName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontSize: min(
                              MediaQuery.of(context).size.width * 0.03 +
                                  MediaQuery.of(context).size.height * 0.01,
                              25),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(
                        thickness: 0.2,
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const primaryColor = Color(0xFF000000);
const canvasColor = Color(0xFF000000);
const scaffoldBackgroundColor = Color(0xFFFFFFFF);
