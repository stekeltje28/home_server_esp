import 'package:flutter/material.dart';
import 'package:youtube_chat_app/services/local_storage.dart';

// Thema-instellingen

// Licht Thema-instellingen
final lightTheme = ThemeData(
  canvasColor: Colors.white,
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.blue,
    elevation: 4,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: TextTheme(
    titleMedium: TextStyle(color: Colors.black, fontSize: 18),
    bodyLarge: TextStyle(color: Colors.black87, fontSize: 14),
    bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
    bodySmall: TextStyle(color: Colors.grey, fontSize: 12),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
    fillColor: Colors.white70,
    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
    labelStyle: TextStyle(color: Colors.blue, fontSize: 16),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    margin: EdgeInsets.all(10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  iconTheme: IconThemeData(color: Colors.blue),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
);

// Donker Thema-instellingen
final darkTheme = ThemeData(
  cardColor: Colors.black,
  canvasColor: Colors.black,
  brightness: Brightness.dark,
  primaryColor: Colors.blueGrey,
  scaffoldBackgroundColor: Colors.black,
  textTheme: TextTheme(
    titleMedium: TextStyle(color: Colors.white, fontSize: 18),
    bodyLarge: TextStyle(color: Colors.white70, fontSize: 14),
    bodyMedium: TextStyle(color: Colors.white54, fontSize: 14),
    bodySmall: TextStyle(color: Colors.grey, fontSize: 12),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blueGrey,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    filled: true,
    fillColor: Colors.white12,
    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
    labelStyle: TextStyle(color: Colors.blueGrey, fontSize: 16),
  ),
  cardTheme: CardTheme(
    color: Colors.grey[800],
    elevation: 2,
    margin: EdgeInsets.all(10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  iconTheme: IconThemeData(color: Colors.white),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blueGrey,
    foregroundColor: Colors.white,
  ),
);
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeData _themeData = lightTheme; // Default to lightTheme initially

  ThemeProvider() {
    loadThemeMode(); // Load saved theme mode on initialization
  }

  ThemeMode get themeMode => _themeMode;
  ThemeData get themeData => _themeData;

  // Load the theme at app start
  Future<void> loadThemeMode() async {
    final savedThemeMode = await LocalStorage.get('theme_mode');
    print('Fetching saved theme mode...');

    if (savedThemeMode == null) {
      // No saved theme; use system brightness as fallback
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      _themeMode = (brightness == Brightness.dark) ? ThemeMode.dark : ThemeMode.light;
      _themeData = (brightness == Brightness.dark) ? darkTheme : lightTheme;
    } else {
      // Use saved theme mode
      switch (savedThemeMode) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          _themeData = darkTheme;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          _themeData = lightTheme;
          break;
        default:
          final brightness = WidgetsBinding.instance.window.platformBrightness;
          _themeMode = (brightness == Brightness.dark) ? ThemeMode.dark : ThemeMode.light;
          _themeData = (brightness == Brightness.dark) ? darkTheme : lightTheme;
          break;
      }
    }
    notifyListeners();
  }

  // Update the theme and save it
  Future<void> setThemeMode(ThemeMode mode) async {
    print('Setting theme...');
    _themeMode = mode;
    _themeData = (mode == ThemeMode.dark) ? darkTheme : lightTheme;

    await LocalStorage.save('theme_mode', mode.toString().split('.').last);
    notifyListeners();
  }
}

