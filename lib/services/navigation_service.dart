import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:youtube_chat_app/pages/complete_page.dart';
import 'package:youtube_chat_app/pages/content_toevoegen/confirm_page.dart';
import 'package:youtube_chat_app/pages/home_page.dart';
import 'package:youtube_chat_app/pages/login_page.dart';
import 'package:youtube_chat_app/pages/register_page.dart';
import 'package:youtube_chat_app/pages/support_page.dart';

class NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final Map<String, Widget Function(BuildContext)> _routes = {

    "/login": (context) => const LoginPage(),
    "/register": (context) => const RegisterPage(),
    "/home": (context) =>  const HomePage(),
    "/contact": (context) => const SupportPage(),
    "/complete": (context) => const CompletePage(),
    "/confirm_page": (context) => const ConfirmPage(),



  };

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  Map<String, Widget Function(BuildContext)> get routes => _routes;

  void push(MaterialPageRoute route) {
    _navigatorKey.currentState?.push(route);
  }
  void pushNamed(String routeName) {
    print('Navigating to $routeName');
    _navigatorKey.currentState?.pushNamed(routeName);
  }

  void pushReplacementNamed(String routeName) {
    print('Replacing with $routeName');
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goBack() {
    print('Going back');
    _navigatorKey.currentState?.pop();
  }

  Widget _buildBackground() {
    return Stack(
      alignment: Alignment.center,
      children: [
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
          top: 50,
          left: 20,
          child: GradientBall(
            size: Size.square(80),
            colors: [Colors.orange, Colors.yellowAccent],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
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




