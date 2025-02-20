import 'package:flutter/material.dart';
import 'package:youtube_chat_app/pages/content_toevoegen/muziek.dart';

class ViewContent extends StatefulWidget {
  const ViewContent({super.key});

  @override
  State<ViewContent> createState() => _AddContentPageState();
}

class _AddContentPageState extends State<ViewContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Zorgen voor consistente achtergrondkleur
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
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
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
              style: TextStyle(
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        _buildOptionButton('Toevoegen', Icons.add, toevoegen),
                        _buildOptionButton('Inzien', Icons.remove_red_eye, inzien),
                        _buildOptionButton('Aanpassen', Icons.edit, aanpassen),
                      ],
                    ),
                  );
                } else {
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x4DFFFFFF)
              : const Color(0xB3FFFFFF),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              icon,
              color: Colors.black,
            ),
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
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0x4DFFFFFF)
              : const Color(0xB3FFFFFF),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              icon,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
