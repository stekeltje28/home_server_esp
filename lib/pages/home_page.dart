import 'dart:math';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../services/theme.dart';
import 'home/Devices.dart';
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
    const Devices(),
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _updateThemeFromSystem();
  }

  void _updateThemeFromSystem() {
    final systemBrightness = WidgetsBinding.instance.window.platformBrightness;
    final newThemeMode = systemBrightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
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
    List<String> texts = [
      "Welkom bij de Home pagina!",
      "zie hier je apparaten",
      "Welkom bij instellingen",
    ];

    setState(() {
      _headText = texts[currentIndex];
      print('Updated Head Text for Index $currentIndex: $_headText');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.black
                : Colors.white,
            statusBarIconBrightness: themeProvider.themeMode == ThemeMode.dark
                ? Brightness.light
                : Brightness.dark,
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
                TabItem(icon: Icons.devices, title: 'Apparaten'),
                TabItem(icon: Icons.settings, title: 'Instellingen'),
              ],
              backgroundColor: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.black
                  : Colors.white,
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.white70
                  : Colors.black87,
              colorSelected: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.blueGrey
                  : Colors.blue,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(height: 3),
                      Text(
                        _fullName,
                        style: TextStyle(
                          color: themeProvider.themeMode == ThemeMode.dark
                              ? Colors.blueGrey
                              : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 5),
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
