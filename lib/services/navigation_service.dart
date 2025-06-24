import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:youtube_chat_app/pages/home_page.dart';
import 'package:youtube_chat_app/pages/login_page.dart';
import 'package:youtube_chat_app/pages/register_page.dart';

class NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final Map<String, Widget Function(BuildContext)> _routes = {

    "/login": (context) => const LoginPage(),
    "/register": (context) => const RegisterPage(),
    "/home": (context) => const HomePage(),

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
}