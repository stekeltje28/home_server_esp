import 'dart:async'; // Import for Future
import 'dart:io'; // Import for InternetAddress
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:blurrycontainer/blurrycontainer.dart';

import '../consts.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../widgets/costum_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormkey = GlobalKey();
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
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
                // Grootste bal links onder
                const Positioned(
                  bottom: 10,
                  left: 10,
                  child: GradientBall(
                    colors: [Colors.black45, Colors.green],
                    size: Size.square(150),
                  ),
                ),
                // Middelste bal rechts boven
                const Positioned(
                  top: 100,
                  right: 10,
                  child: GradientBall(
                    size: Size.square(120),
                    colors: [Colors.purple, Colors.blue],
                  ),
                ),
                // Kleinste bal links boven
                const Positioned(
                  top: 50,
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
                  _loginForm(context),
                  _createAnAccountLink(),
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
            "Hoi, welkom terug!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: min(MediaQuery.of(context).size.width * 0.03 + MediaQuery.of(context).size.height * 0.02, 50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We hebben je gemist",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.015, 35),
            ),
          )
        ],
      ),
    );
  }

  Widget _loginForm(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05),
      child: Form(
        key: _loginFormkey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomFormField(
              height: MediaQuery.of(context).size.height * 0.1,
              hintText: 'E-mail',
              validationRegEx: EMAIL_VALIDATION_REGEX,
              onsave: (value) {
                email = value;
              },
            ),
            CustomFormField(
              height: MediaQuery.of(context).size.height * 0.1,
              hintText: 'Wachtwoord',
              validationRegEx: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              onsave: (value) {
                password = value;
              },
            ),
            _loginButton()
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {

          await _authService.login('thijs.stekeltje@gmail.com', 'T@stekeltje2007');
          _navigationService.pushReplacementNamed('/home');

          // if (_loginFormkey.currentState?.validate() ?? false) {
          //   _loginFormkey.currentState?.save();
          //   print('email: $email \n password: $password');
          //
          //   if (email != null && password != null) {
          //     // Check internet connection
          //     bool connection = await hasInternetConnection();
          //     if (!connection) {
          //       _alertService.showToast(
          //         text: 'Geen internetverbinding. Probeer het later opnieuw.',
          //         icon: Icons.error_outline,
          //       );
          //       return; // Exit the function if no internet
          //     }
          //
          //     // Attempt to log in
          //     bool result = await _authService.login(email!, password!);
          //     if (result) {
          //       // Navigate to the home page on the main thread
          //       WidgetsBinding.instance.addPostFrameCallback((_) {
          //         _navigationService.pushReplacementNamed('/home');
          //       });
          //     } else {
          //       _alertService.showToast(
          //         text: 'Gebruikersnaam en/of wachtwoord zijn onjuist',
          //         icon: Icons.error_outline,
          //       );
          //     }
          //   }
          // } else {
          //   _alertService.showToast(
          //     text: 'Gebruikersnaam en/of wachtwoord voldoen niet aan de eisen',
          //     icon: Icons.error_outline,
          //   );
          // }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Login",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _createAnAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Geen account? ',
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
          onTap: () {
            _navigationService.pushNamed("/register");
          },
          child: const Text(
            'Aanmelden',
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
