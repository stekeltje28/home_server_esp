import 'dart:math';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/pages/home/add_content_page.dart';
import 'package:youtube_chat_app/pages/home/view_content.dart';
import 'package:youtube_chat_app/pages/support_page.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/local_storage.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:youtube_chat_app/services/theme.dart';
import 'home/setting_page.dart';
import 'home/welcome_page.dart';

class HomePage extends StatefulWidget {
  final int initialPageIndex;
  const HomePage({super.key, this.initialPageIndex = 0});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _key = GlobalKey<ScaffoldState>();
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late ThemeMode _themeMode;

  String _headText = 'Welkom';
  String _fullName = 'onbekend';
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
    loadThemeMode();
    _loadUserProfile();
    _updateHeadText();
  }

  Future<void> loadThemeMode() async {
    final themeMode = await LocalStorage.get('theme_mode');
    // Pas de theme-instellingen aan via Provider
    switch (themeMode) {
      case 'dark':
        context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
        break;
      case 'light':
        context.read<ThemeProvider>().setThemeMode(ThemeMode.light);
        break;
      case 'system':
      default:
        context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
        break;
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

  void _updateHeadText() {
    List<List<String>> texts = [
      [
        "Welkom bij de Welkomstpagina!",
        "Hallo en welkom op onze app!",
        "Fijn dat je hier bent!"
      ],
      [
        "Neem contact met ons op!",
        "We horen graag van je!",
        "Stuur ons een bericht!"
      ],
      [
        'voeg je content toe!',
        'bepaal je eigen style!',
        'doe het makkelijk en snel!'
      ],
      [
        'verbeter je content!',
        'zie wat je hebt!',
        'beheer je content!'
      ],
      [
        "Dit zijn de instellingen.",
        "Hier kun je je voorkeuren aanpassen.",
        "Beheer je accountinstellingen hier."
      ]
    ];

    setState(() {
      _headText = texts[currentIndex][Random().nextInt(texts[currentIndex].length)];
      print('Updated Head Text for Index $currentIndex: $_headText');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>( // Gebruik Consumer om het thema dynamisch aan te passen
      builder: (context, themeProvider, child) {
        // Pas de statusbalkkleur aan op basis van het thema
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.black // Zwarte statusbalk voor dark mode
                : Colors.white, // Witte statusbalk voor light mode
            statusBarIconBrightness: themeProvider.themeMode == ThemeMode.dark
                ? Brightness.light // Lichte iconen in dark mode
                : Brightness.dark, // Donkere iconen in light mode
            systemNavigationBarColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.black
                : Colors.white,
          ),
        );

        return MaterialApp(
          title: 'Home',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          themeMode: themeProvider.themeMode,
          home: Scaffold(
            key: _key,
            bottomNavigationBar: BottomBarInspiredFancy(
              items: const [
                TabItem(icon: Icons.home, title: 'Home'),
                TabItem(icon: Icons.people_rounded, title: 'Support'),
                TabItem(icon: Icons.add, title: 'Voeg toe'),
                TabItem(icon: Icons.article, title: 'Content'),
                TabItem(icon: Icons.settings, title: 'Instellingen'),
              ],
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.black // Achtergrondkleur zwart voor dark mode
                  : Colors.white, // Achtergrondkleur wit voor light mode
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.white70 // Icoon kleur lichtgrijs in dark mode
                  : Colors.black87, // Icoon kleur zwart in light mode
              colorSelected: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.blueGrey // Geselecteerde kleur blauwgrijs in dark mode
                  : Colors.blue, // Geselecteerde kleur blauw in light mode
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
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _headText,
                            style: TextStyle(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.blueGrey
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: min(
                                  MediaQuery.of(context).size.width * 0.035 +
                                      MediaQuery.of(context).size.height * 0.010,
                                  32),
                            ),
                          ),
                          const SizedBox(height: 4),
                            Text(
                              _fullName,
                              style: TextStyle(
                                color: themeProvider.themeMode == ThemeMode.dark
                                    ? Colors.blueGrey
                                    : Colors.black,
                                fontSize: min(
                                    MediaQuery.of(context).size.width * 0.03 +
                                        MediaQuery.of(context).size.height * 0.01,
                                    25),
                              ),
                            ),
                          const SizedBox(height: 5),
                          Divider(
                            thickness: 0.2,
                            color: Theme.of(context).dividerColor,
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
      },
    );
  }
}
