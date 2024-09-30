import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';

import '../services/navigation_service.dart';

class CompletePage extends StatefulWidget {
  const CompletePage({super.key});

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage> {
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
// onPressed: () async {
// setState(() {
// isLoading = true;
// });
// try {
// if ((_registerFormKey.currentState?.validate() ?? false) && selectedImage != null) {
// _registerFormKey.currentState?.save();
// bool result = await _authService.signup(email!, password!);
// if (result) {
// String? pfpURL = await _storageService.upLoadUserPip(
// file: selectedImage!,
// uid: _authService.user!.uid
// );
// if (pfpURL != null) {
// await _databaseService.createUserProfile(userProfile: UserProfile(
// uid: _authService.user!.uid,
// name: name!,
// pfpURL: pfpURL,
// email: email!,
// access: false),
// );
// _alertService.showToast(text: 'Je hebt succesvol een account aangemaakt 💪', icon: Icons.check);
// }
// bool login = await _authService.login(email!, password!);
// if (login) {
// _alertService.showToast(text: 'Succesvol ingelogd 💪', icon: Icons.check);
// _navigationService.pushReplacementNamed('/home');
// } else {
// _alertService.showToast(text: 'Er is iets mis gegaan, probeer hier in te loggen', icon: Icons.error_outline);
// _navigationService.pushNamed('/login');
// }
// }
// } else if (selectedImage == null) {
// _alertService.showToast(text: 'Heb je al een afbeelding gekozen?', icon: Icons.error_outline);
// } else {
// _alertService.showToast(text: 'Vul alle tekstvelden correct in', icon: Icons.error_outline);
// }
// } catch (e) {
// print('Niet gelukt');
// _alertService.showToast(text: 'registratie is gefaald!', icon: Icons.error_outline);
// }
// setState(() {
// isLoading = false;
// });
// },
