import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';

class Muziektoevoegen extends StatefulWidget {
  const Muziektoevoegen({super.key});

  @override
  State<Muziektoevoegen> createState() => _addMuziekState();
}

class _addMuziekState extends State<Muziektoevoegen> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  String _fullName = '';
  File? _selectedAudio; // File voor de geselecteerde audio
  final TextEditingController _titleController = TextEditingController(); // Controller voor de titel

  @override
  void initState() {
    super.initState();
    _authService = _getIt<AuthService>();
    _navigationService = _getIt<NavigationService>();
    _alertService = _getIt<AlertService>();
    _databaseService = _getIt<DatabaseService>();
    _loadUserProfile();
  }

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
        icon: Icons.error_outline,
      );
    }
  }

  Future<void> _selectMuziek() async {
    try {
      // Selecteer een audio bestand
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedAudio = File(result.files.single.path!); // Sla het pad van de geselecteerde audio op
          print('Geselecteerde audio: ${_selectedAudio!.path}');
        });
      } else {
        _alertService.showToast(text: 'Fout bij het selecteren van audio', icon: Icons.error_outline);
      }
    } catch (e) {
      print('Error selecting audio: $e');
    }
  }

  Future<void> addContent(String title, File? file) async {
    if (file == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/api/muziekcontent/'), // Zorg ervoor dat deze URL klopt
    );

    request.fields['title'] = title;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        print('Content added successfully!');
        _alertService.showToast(
          text: 'Inhoud succesvol gepubliceerd!',
          icon: Icons.check_circle,
        );

        // Terug naar de vorige pagina of een andere actie
        Navigator.pop(context);
      } else {
        print('Failed to add content: ${response.statusCode}');
        _alertService.showToast(
          text: 'Publiceren mislukt: ${response.statusCode}',
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      print('Error adding content: $e');
      _alertService.showToast(
        text: 'Fout bij het publiceren.',
        icon: Icons.error_outline,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                        ),
                        Text(
                          'Muziek',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 50),
                        Text(
                          _fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Divider(thickness: 0.2, color: Colors.black, indent: 10, endIndent: 10),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _selectMuziek,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey,
                            ),
                            child: Center(
                              child: Text(
                                _selectedAudio != null
                                    ? 'Audio geselecteerd: ${_selectedAudio!.path.split('/').last}'
                                    : 'Selecteer Audio',
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Titel',
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () {
                      // Actie bij drukken op de knop
                      if (_titleController.text.isNotEmpty) {
                        addContent(_titleController.text, _selectedAudio);
                      } else {
                        _alertService.showToast(
                          text: 'Voer een titel in.',
                          icon: Icons.error_outline,
                        );
                      }
                    },
                    child: const Text(
                      'Publiceren',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class Muziekinzien extends StatefulWidget {
  const Muziekinzien({super.key});

  @override
  State<Muziekinzien> createState() => _MuziekinzienState();
}

class _MuziekinzienState extends State<Muziekinzien> {
  // Functie om muziekcontent op te halen van de API
  Future<List<dynamic>> viewContent() async {
    final response = await http.get(Uri.parse('localhost:8000api/muziekcontent/'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // De data als JSON decoderen
    } else {
      throw Exception('Failed to load music contents');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muziek Inzien'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: viewContent(), // Voer de functie uit om muziekcontent op te halen
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Laat laadindicator zien als data nog niet binnen is
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Toon foutmelding als er een probleem is met de API-aanroep
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Toon bericht als er geen data beschikbaar is
            return const Center(child: Text('Geen muziek gevonden'));
          } else {
            // Bouw de lijst van muziekcontent
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final muziek = snapshot.data![index];
                return _buildMuziekCard(muziek); // Bouwt elke muziekkaart
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Muziektoevoegen()), // Pagina voor muziek toevoegen
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Widget om elke muziekkaart te tonen
  Widget _buildMuziekCard(dynamic muziek) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(muziek['title'] ?? 'Geen titel', style: const TextStyle(fontSize: 18)),
        subtitle: Text(muziek['description'] ?? 'Geen beschrijving'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Muziekaanpassen()), // Pagina voor muziek aanpassen
            );
          },
        ),
      ),
    );
  }
}
class Muziekaanpassen extends StatefulWidget {
  const Muziekaanpassen({super.key});

  @override
  State<Muziekinzien> createState() => _editMuziekState();
}

class _editMuziekState extends State<Muziekinzien> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  final TextEditingController _titleController = TextEditingController(); // Controller voor de titel

  @override
  void initState() {
    super.initState();
    _authService = _getIt<AuthService>();
    _navigationService = _getIt<NavigationService>();
    _alertService = _getIt<AlertService>();
    _databaseService = _getIt<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

    );
  }

}

