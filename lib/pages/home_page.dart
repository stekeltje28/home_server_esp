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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late ThemeProvider _themeProvider;

  String _headText = 'Welkom';
  String _fullName = 'onbekend';
  String _pfpURL = '';
  int currentIndex = 0;

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
    _themeProvider = context.read<ThemeProvider>();

    WidgetsBinding.instance.addObserver(this);

    _updateThemeFromSystem();
    _loadUserProfile();
    _updateHeadText();
  }

  @override
  void dispose() {
    // Verwijder de observer om geheugenlekken te voorkomen
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Deze methode wordt aangeroepen als het systeemthema verandert
  @override
  void didChangePlatformBrightness() {
    _updateThemeFromSystem();
  }

  // Wijzig het thema op basis van het systeem
  void _updateThemeFromSystem() {
    final systemBrightness = WidgetsBinding.instance.window.platformBrightness;
    final newThemeMode = systemBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;

    // Stel het nieuwe thema in
    _themeProvider.setThemeMode(newThemeMode);
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
        'Voeg je content toe!',
        'Bepaal je eigen stijl!',
        'Doe het makkelijk en snel!'
      ],
      [
        'Verbeter je content!',
        'Zie wat je hebt!',
        'Beheer je content!'
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
    return Consumer<ThemeProvider>(
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
            body: Column(
              children: [
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (currentIndex != 4)
                      Text(
                        _headText,
                        style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.blueGrey
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      if (currentIndex != 4)
                      const SizedBox(height: 4),
                      if (currentIndex != 4)
                        Text(
                          _fullName,
                          style: TextStyle(
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? Colors.blueGrey
                                : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      if (currentIndex != 4)
                      const SizedBox(height: 5),
                      if (currentIndex != 4)
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
          ),
        );
      },
    );
  }
}
