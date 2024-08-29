import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/pages/home/contact_page.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/widgets/background_widget.dart';


class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final GetIt _getIt = GetIt.instance;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _loadUserProfile();
  }

  String _fullName = '';

  Future<void> _loadUserProfile() async {
    try {
      UserProfile? userProfile = await _databaseService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _fullName = userProfile.name ?? 'Onbekend';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
      _alertService.showToast(
          text: 'Fout bij het ophalen van het profiel.',
          icon: Icons.error_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zorg ervoor dat de achtergrond doorzichtig is
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Zorg ervoor dat de tekst links uitgelijnd is
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0), // Voeg padding toe rondom de tekst
                child: Text(
                  "$_fullName, wij helpen je!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Voeg wat ruimte toe onder de tekst
              _buildBlurryContactContainer(), // Voeg de container met medewerkers toe
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlurryContactContainer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlurryContainer(
        blur: 10,
        width: double.infinity,
        height: 150,
        elevation: 0,
        color: Colors.white.withOpacity(0.3), // Lichtere kleur met hogere opaciteit
        borderRadius: BorderRadius.circular(20.0),
        padding: const EdgeInsets.all(0), // Verwijder padding zodat de bovenkant volledig wordt bedekt
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0x2F000000), // Lichtere kleur voor de bovenkant
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Optionele padding voor de tekst en icon
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Text(
                    'Onze Medewerkers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactPage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Ruimte tussen de titel en de afbeeldingen
            Expanded(child: _buildEmployeeRow()), // Rest van de container wordt gevuld met inhoud
          ],
        ),
      ),
    );
  }



  Widget _buildEmployeeRow() {
    return StreamBuilder<QuerySnapshot<UserProfile>>(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Niet mogelijk data te laden",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        if (snapshot.hasData) {
          final users = snapshot.data!.docs
              .where((doc) => doc.data().access == true)
              .map((doc) => doc.data())
              .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text(
                "Geen medewerkers beschikbaar",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: users.map((user) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(user.pfpURL ?? ''),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(user.pfpURL ?? ''),
                      radius: 30,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
