import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:youtube_chat_app/firebase_options.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/local_storage.dart';
import 'package:youtube_chat_app/services/message_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:youtube_chat_app/services/theme.dart';
import 'package:youtube_chat_app/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Consider showing a dialog or an error page if Firebase is essential
  }

  await FirebaseMessage().initNotifications();
  await LocalStorage.init();

  await setup();  // Calls registerServices

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Add other providers as needed
      ],
      child: MyApp(),
    ),
  );
}

Future<void> setup() async {
  registerServices();
}

class MyApp extends StatelessWidget {
  final GetIt getIt = GetIt.instance;

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationService navigationService = getIt.get<NavigationService>();
    final AuthService authService = getIt.get<AuthService>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigationService.navigatorKey,
      title: 'easy',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      routes: navigationService.routes,
      initialRoute: authService.user != null ? "/home" : "/login",
      builder: (context, child) {
        return child!;
      },
    );
  }
}
