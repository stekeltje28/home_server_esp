import 'dart:ui';
import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor; // Voeg een parameter toe voor de achtergrondkleur

  const BackgroundContainer({super.key, 
    required this.child,
    this.backgroundColor = const Color(0xFF0D1B2A),});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildBackground(), // De achtergrond met kleur en decoratieve elementen
        child, // Hier wordt de content van de specifieke pagina geplaatst
      ],
    );
  }

  Widget _buildBackground() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Plaats een volledig schermvullende Container als eerste widget in de Stack
        Container(
          color: backgroundColor, // Gebruik de opgegeven achtergrondkleur
        ),
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
            colors: [Colors.purple, Colors.blue], // De blauwe gloed
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
            color: Colors.black.withOpacity(0.5), // Zwarte overlay met transparantie
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
