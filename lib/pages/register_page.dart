import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../consts.dart';
import '../models/user_profile.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/media_service.dart';
import '../services/navigation_service.dart';
import '../services/storage_service.dart';
import '../widgets/costum_form_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  late AuthService _authService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  String? email, password, name;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _alertService = _getIt.get<AlertService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

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
                  child: _buildUI(context, constraints),
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
                  _headerText(context),
                  _registerForm(),
                  _loginAnAccountLink(),
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
            "Laten we beginnen!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: min(MediaQuery.of(context).size.width * 0.03 + MediaQuery.of(context).size.height * 0.02, 40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "registreer je account",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.01, 22),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pfpSelectionField(),
          const SizedBox(height: 16),
          CustomFormField(
            hintText: 'Volledige naam',
            height: MediaQuery.of(context).size.height * 0.1,
            onsave: (value) {
              setState(() {
                name = value;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomFormField(
            hintText: 'Email',
            height: MediaQuery.of(context).size.height * 0.1,
            onsave: (value) {
              setState(() {
                email = value;
              });
            },
          ),
          const SizedBox(height: 16),
          CustomFormField(
            hintText: 'Wachtwoord',
            height: MediaQuery.of(context).size.height * 0.1,
            obscureText: true,
            onsave: (value) {
              setState(() {
                password = value;
              });
            },
          ),
          const SizedBox(height: 20),
          _registerButton(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02 + MediaQuery.of(context).size.width * 0.01,
          )
        ],
      ),
    );
  }

  Widget _pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: min(MediaQuery.of(context).size.width * 0.04 + MediaQuery.of(context).size.height * 0.03, 55),
                backgroundImage: selectedImage != null
                    ? FileImage(selectedImage!)
                    : const NetworkImage(PLACEHOLDER_PFP),
              ),
              Visibility(
                visible: selectedImage == null,
                child: const Text(
                  'Kies een afbeelding',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
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
          print("Button pressed, starting registration process");
          print('email: $email wachtwoord: $password');
          try {
            // Validate form fields
            if ((_registerFormKey.currentState?.validate() ?? false) && selectedImage != null) {
              _registerFormKey.currentState?.save();

              if (email == null || password == null) {
                _alertService.showToast(
                  text: 'Vul een geldige email en wachtwoord in',
                  icon: Icons.error_outline,
                );
                return;
              }

              bool result = await _authService.signup(email!, password!);

              if (result) {
                if (selectedImage != null) {
                  String? pfpURL = await _storageService.upLoadUserPip(
                    file: selectedImage!,
                    uid: _authService.user!.uid,
                  );

                  if (pfpURL != null) {
                    await _databaseService.createUserProfile(
                      userProfile: UserProfile(
                        uid: _authService.user?.uid ?? "NULL",
                        name: name,
                        pfpURL: pfpURL,
                        email: email,
                        access: false,
                      ),
                    );
                    _alertService.showToast(
                      text: 'Je hebt succesvol een account aangemaakt 💪',
                      icon: Icons.check,
                    );
                  }
                }

                bool login = await _authService.login(email!, password!);
                if (login) {
                  _navigationService.pushNamed('/home');
                } else {
                  _alertService.showToast(
                    text: 'Er is iets mis gegaan, probeer hier in te loggen',
                    icon: Icons.error_outline,
                  );
                  _navigationService.pushNamed('/login');
                }
              }
            } else {
              print('email: $email wachtwoord: $password');
              _alertService.showToast(
                text: 'Vul alle tekstvelden correct in',
                icon: Icons.error_outline,
              );
            }
          } catch (e, stacktrace) {
            print('Registratie mislukt met fout: $e');
            print('Stacktrace: $stacktrace');
            _alertService.showToast(
              text: 'Registratie is gefaald!',
              icon: Icons.error_outline,
            );
          }
          setState(() {
            isLoading = false;
          });
        },
        child: isLoading
            ? const CircularProgressIndicator()
            : const Text(
          "Aanmelden",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _loginAnAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Heb je al een account? ',
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            _navigationService.pushNamed("/login");
          },
          child: const Text(
            'Inloggen',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }
}

class GradientBall extends StatelessWidget {
  final List<Color> colors;
  final Size size;

  const GradientBall({
    super.key,
    required this.colors,
    this.size = const Size.square(150),
  });

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
