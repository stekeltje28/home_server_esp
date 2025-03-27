import 'package:flutter/material.dart';
import '../../widgets/device_card.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<String> deviceImages = [
    'https://via.placeholder.com/100',
    'https://via.placeholder.com/100',
    'https://via.placeholder.com/100',
    'https://via.placeholder.com/100',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context, 'Je apparaten'),
          _deviceScrollList(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String naam) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          naam,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            thickness: 0.2,
            color: Theme.of(context).dividerColor,
            indent: 10,
            endIndent: 10,
          ),
        ),
      ],
    );
  }

  // ✅ Horizontale scrollbare lijst met apparaten
  Widget _deviceScrollList(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: deviceImages.length,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 150,
              child: DeviceCard(
                imageUrl: deviceImages[index],
                onDelete: () {
                  setState(() {
                    deviceImages.removeAt(index); // ✅ Card verwijderen
                  });
                },
                onInfo: () {
                  _showInfoDialog(context, deviceImages[index]); // ✅ Info dialoog openen
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ Dialoog voor apparaatinfo tonen
  void _showInfoDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Apparaat Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(imageUrl, width: 100, height: 100),
              const SizedBox(height: 10),
              const Text('Dit is een voorbeeld apparaat.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }
}
