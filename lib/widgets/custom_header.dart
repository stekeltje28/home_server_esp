import 'dart:math';
import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const CustomHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: min(MediaQuery.of(context).size.width * 0.03 + MediaQuery.of(context).size.height * 0.02, 50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey,
              fontSize: min(MediaQuery.of(context).size.width * 0.02 + MediaQuery.of(context).size.height * 0.01, 35),
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Implement your menu button action here
              Scaffold.of(context).openDrawer(); // Example: Open the drawer
            },
          ),
        ],
      ),
    );
  }
}
