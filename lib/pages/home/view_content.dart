import 'package:flutter/material.dart';
import 'package:youtube_chat_app/pages/content_toevoegen/muziek.dart';
// Voeg hier extra pagina's toe die je wilt gebruiken voor navigatie

class ViewContent extends StatefulWidget {
  const ViewContent({super.key});

  @override
  State<ViewContent> createState() => _AddContentPageState();
}

class _AddContentPageState extends State<ViewContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpandableContainer('Nieuwsartikelen', Colors.red, Muziekinzien(), Muziekaanpassen(), Muziektoevoegen()),
              const SizedBox(height: 20),
              _buildExpandableContainer('Muziek', Colors.blue, Muziekinzien(), Muziekaanpassen(), Muziektoevoegen()),
              const SizedBox(height: 20),
              _buildExpandableContainer("Video's", Colors.green, Muziekinzien(), Muziekaanpassen(), Muziektoevoegen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableContainer(String text, Color color, Widget inzien, Widget aanpassen, Widget toevoegen) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          title: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          collapsedBackgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 500) {
                  // Als de beschikbare breedte kleiner is dan 500 pixels
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 10.0, // Ruimte tussen knoppen horizontaal
                      runSpacing: 10.0, // Ruimte tussen knoppen verticaal
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        // 3 unieke functies voor Nieuwsartikelen
                        _buildOptionButton('Toevoegen', Icons.add, toevoegen),
                        _buildOptionButton('Inzien', Icons.remove_red_eye, inzien),
                        _buildOptionButton('Aanpassen', Icons.edit, aanpassen),
                      ],
                    ),
                  );
                } else {
                  // Als de beschikbare breedte groter is dan 500 pixels
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildWideButton('Toevoegen', Icons.add, constraints.maxWidth / 3 - 20, toevoegen),
                        _buildWideButton('Inzien', Icons.remove_red_eye, constraints.maxWidth / 3 - 20, inzien),
                        _buildWideButton('Aanpassen', Icons.edit, constraints.maxWidth / 3 - 20, aanpassen),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String text, IconData icon, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0x4DFFFFFF),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(text),
            const SizedBox(width: 10),
            Icon(icon),
          ],
        ),
      ),
    );
  }

  Widget _buildWideButton(String text, IconData icon, double width, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        width: width, // Breedte aanpassen aan het scherm
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0x4DFFFFFF),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(text),
            Icon(icon),
          ],
        ),
      ),
    );
  }
}
