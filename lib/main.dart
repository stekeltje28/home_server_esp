
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_chat_app/firebase_options.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/local_storage.dart';
import 'package:youtube_chat_app/services/media_service.dart';
import 'package:youtube_chat_app/services/message_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:youtube_chat_app/utils.dart';

void main() async {
  // Zorg ervoor dat de binding als eerste wordt geïnitialiseerd
  WidgetsFlutterBinding.ensureInitialized();
  print('klaar met ensureInitialized');

  // Initialiseer Firebase
  print('bezig met initialize');
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  await FirebaseMessage().initNotifications();
  print('klaar met initialize');

  // Initialiseer LocalStorage
  print('bezig met LocalStorage.init');
  await LocalStorage.init();
  print('klaar met LocalStorage.init');

  // Voer setup uit
  print('bezig met setup()');
  await setup();
  print('klaar met setup()');




  // Start de app
  runApp(MyApp());
}


Future<void> setup() async {
  await setupFirebase();
  registerServices();
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GetIt getIt = GetIt.instance;
  late final NavigationService _navigationService = getIt.get<NavigationService>();
  late final AuthService _authService = getIt.get<AuthService>();
  late final AlertService _alertService = getIt.get<AlertService>();
  late final MediaService _mediaService = getIt.get<MediaService>();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigationService.navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      routes: _navigationService.routes,
      initialRoute: _authService.user != null ? "/home" : "/login",
      builder: (context, child) {
        return child!;
      },
    );
  }
}
