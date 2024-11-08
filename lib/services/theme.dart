import 'package:flutter/material.dart';
import 'package:youtube_chat_app/services/local_storage.dart';

// Licht Thema-instellingen
final lightTheme = ThemeData(
  canvasColor: Colors.white,
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Colors.blue,
    elevation: 4,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
  ),
  textTheme: const TextTheme(
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
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    labelStyle: const TextStyle(color: Colors.blue, fontSize: 16),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    margin: const EdgeInsets.all(10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  iconTheme: const IconThemeData(color: Colors.blue),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
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
  textTheme: const TextTheme(
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
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
    labelStyle: const TextStyle(color: Colors.blueGrey, fontSize: 16),
  ),
  cardTheme: CardTheme(
    color: Colors.grey[800],
    elevation: 2,
    margin: const EdgeInsets.all(10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blueGrey,
    foregroundColor: Colors.white,
  ),
);

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  late ThemeData _themeData;

  ThemeProvider() {
    _initializeTheme();
  }

  ThemeMode get themeMode => _themeMode;
  ThemeData get themeData => _themeData;

  Future<void> _initializeTheme() async {
    final savedThemeMode = await LocalStorage.get('theme_mode');
    if (savedThemeMode == null) {
      _themeMode = ThemeMode.system;
      _updateThemeData();
    } else {
      setThemeMode(savedThemeMode == 'dark' ? ThemeMode.dark : ThemeMode.light);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _updateThemeData();
    await LocalStorage.save('theme_mode', mode.toString().split('.').last);
    notifyListeners();
  }

  void _updateThemeData() {
    _themeData = (_themeMode == ThemeMode.dark) ? darkTheme : lightTheme;
  }
}
