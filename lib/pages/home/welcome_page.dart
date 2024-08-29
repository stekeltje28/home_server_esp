import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('welcome Page', style: TextStyle(color: Colors.white, fontSize: 24)),
    );
  }
}
