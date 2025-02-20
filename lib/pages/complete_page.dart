import 'dart:math';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/media_service.dart';
import 'package:youtube_chat_app/services/storage_service.dart';
import 'package:youtube_chat_app/widgets/costum_form_field.dart';
import '../services/navigation_service.dart';

class CompletePage extends StatefulWidget {
  const CompletePage({super.key, selectedImage});

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
  var selectedImage;
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  late AuthService _authService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  bool isLoading = false;

  // Nieuwe variabelen voor het opslaan van klantdata
  String? apiUrl;
  String? apiPages;
  String? dataToReceive;
  String? dataToPlace;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gradient Balls
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
                  top: 125,
                  left: 20,
                  child: GradientBall(
                    size: Size.square(80),
                    colors: [Colors.orange, Colors.yellowAccent],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                 // child: _buildUI(context, constraints),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUI(BuildContext context, BoxConstraints constraints) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth > 600 ? 600 : constraints.maxWidth,
          ),
          child: BlurryContainer(
            blur: 10,
            width: double.infinity,
            elevation: 0,
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.0),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                //  _headerText(context),
               //   _completeForm()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Laten we je website afmaken!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: min(MediaQuery.of(context).size.width * 0.03 + MediaQuery.of(context).size.height * 0.02, 36), // Limiting max size to 40
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Vul hier de volgende velden in om ons te helpen je website af te maken.",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.01, 18), // Limiting max size to 22
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _completeForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'wat voor type website had je in gedachten?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.01, 18), // Limiting max size to 22
            ),
          ),
          SizedBox(height: 10),
          CustomFormField(
            info: 'waar is je website voor bestemd?\nprobeer het te beschrijven in 1 woord',
            hintText: 'type website',
              suggestions: const [
                'Blog',
                'Portfolio',
                'E-commerce',
                'Nieuwswebsite',
                'Persoonlijke website',
                'Forum',
                'Landeningspagina',
                'Online CV',
                'Educatieve website',
                'Non-profit website',
                'Fotografie website',
                'Entertainment website',
                'Webapplicatie',
                'Winkelcatalogus',
                'Restaurant website',
                'Online community',
                'Reserveringssysteem',
                'Social media platform',
                'Crowdfunding platform',
                'Evenementenwebsite',
                'Muziekplatform',
                'Sportwebsite',
                'Reisblog',
                'Vakantieverhuur website',
              ],
              height: MediaQuery.of(context).size.height * 0.1,
            onSaved: (value) {
              apiUrl = value;
            },
          ),
          const SizedBox(height: 16),

          Text(
            'hoe groot moet de website worden?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.01, 18), // Limiting max size to 22
            ),
          ),
          SizedBox(height: 10),
          CustomFormField(
            info: 'hoe groot wil je jouw website hebben?\ndenk aan:\n* hoeveel pages?\n*wat wil je doen op je website?\n*wees zo uitgebreid mogelijk' ,
            maxLines: 5,
            hintText: "vul hier je wensen in",
            height: MediaQuery.of(context).size.height * 0.2,
            keyboardType: TextInputType.multiline,
            onSaved: (value) {},
          ),
          const SizedBox(height: 16),
          Text(
            'wat wil je makkelijk kunnen bewerken aan je website?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.01, 18), // Limiting max size to 22
            ),
          ),
          SizedBox(height: 5),
          CustomFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            info: 'bij je website krijg je een app,\n wat wil je met deze app makkelijk kunnen bewerken op je website?',
            hintText: "wat wil je kunnen aanpassen?",
            height: MediaQuery.of(context).size.height * 0.2,
            onSaved: (value) {
            },
          ),
          const SizedBox(height: 16),

          Text(
            'overige toevoegingen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.01, 18), // Limiting max size to 22
            ),
          ),
          SizedBox(height: 10),
          CustomFormField(
            info: 'hoe groot wil je jouw website hebben?\ndenk aan:\n* hoeveel pages?\n*wat wil je doen op je website?\n*wees zo uitgebreid mogelijk' ,
            maxLines: 5,
            hintText: "toevoegingen",
            height: MediaQuery.of(context).size.height * 0.2,
            keyboardType: TextInputType.multiline,
            onSaved: (value) {},
          ),
          const SizedBox(height: 16),
          //_registerButton(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02 + MediaQuery.of(context).size.width * 0.01,
          )
        ],
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Bedankt!"),
                content: const Text(
                    "Uw wensen worden verstuurd via onze chat, kijk even rond in de app...\nwij proberen zo snel mogelijk contact met u op te nemen"
                ),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      // Navigeren naar de wensen invullen pagina
                      Navigator.of(context).pushNamed('/home');
                    },
                  ),
                  TextButton(
                    child: const Text("Annuleren"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          setState(() {
            isLoading = false;
          });
        },

        child: isLoading
            ? const CircularProgressIndicator()
            : Row(
          mainAxisAlignment:  MainAxisAlignment.center,
          children: const [
            Text(
              "Verder gaan",
              style: TextStyle(fontSize: 20,
              color: Colors.white),
            ),
            Icon(Icons.arrow_forward, color: Colors.white,)
          ],
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}