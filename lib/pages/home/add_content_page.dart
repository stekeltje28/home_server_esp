import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:youtube_chat_app/pages/content_toevoegen/muziek.dart';
import 'package:youtube_chat_app/pages/content_toevoegen/nieuws.dart';
import 'package:youtube_chat_app/pages/content_toevoegen/videos.dart';

class AddContentPage extends StatefulWidget {
  const AddContentPage({super.key});

  @override
  State<AddContentPage> createState() => _ViewContentState();
}

class _ViewContentState extends State<AddContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContentContainer('Nieuwsartikelen', Colors.red, context, const AddNieuws()), // Geeft de class 'Template' mee
              const SizedBox(height: 15),
              _buildContentContainer('Muziek', Colors.blue, context, const Muziektoevoegen()), // Geeft een andere class mee
              const SizedBox(height: 15),
              _buildContentContainer("Video's", Colors.green, context, const AddVideos()), // Geeft nog een andere class mee
            ],
          ),
        ),
      ),
    );
  }

  // Nieuwe parameter toegevoegd: Widget page
  Widget _buildContentContainer(String text, Color color, BuildContext context, Widget page) {
    return BlurryContainer(
      blur: 5,
      elevation: 0,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color, Colors.black],
            ),
          ),
          child: InkWell(
            onTap: () {
              // Navigeer naar de opgegeven pagina (page)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
