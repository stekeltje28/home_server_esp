import 'dart:convert';
import 'dart:io'; // Voor File-class
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // Voeg de image_picker package toe
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';

class AddNieuws extends StatefulWidget {
  const AddNieuws({super.key});

  @override
  State<AddNieuws> createState() => _AddNieuwsState();
}

class _AddNieuwsState extends State<AddNieuws> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _fullName = '';
  File? _selectedImage; // File voor de geselecteerde afbeelding
  final ImagePicker _picker = ImagePicker(); // ImagePicker-instantie

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _loadUserProfile();
  }

  Future<void> addContent(String title, String content, File? file, String url) async {
    if (file == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/api/$url/'),
    );

    request.headers['Content-Type'] = 'application/json; charset=UTF-8';
    request.fields['title'] = title;
    request.fields['content'] = content;


    // Voeg de afbeelding toe aan de aanvraag
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        print('Content added successfully!');
        _alertService.showToast(
          text: 'Inhoud succesvol gepubliceerd!',
          icon: Icons.check_circle,
        );
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

  Future<void> _selectImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path); // Sla het pad van de geselecteerde afbeelding op
          print(_selectedImage);
        });
      } else {
        _alertService.showToast(text: 'Error selecting image', icon: Icons.error_outline);
      }
    } catch (e) {
      print('Error selecting image: $e');
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

    return MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        canvasColor: canvasColor,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Scaffold(
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
                            'Nieuwsartikelen',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width * 0.05,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const SizedBox(width: 50,),
                          Text(
                            _fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(
                        thickness: 0.2,
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                      ),
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
                            onTap: _selectImage,
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey,
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                                  : const SizedBox(
                                height: 200,
                                child: Icon(Icons.image, size: 50),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Title',
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _contentController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Inhoud',
                              alignLabelWithHint: true,
                            ),
                            maxLines: 10,
                            minLines: 5,
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
                      onPressed: () async {
                        await addContent(
                          _titleController.text,
                          _contentController.text,
                          _selectedImage,
                          'images', // vervang dit door de juiste URL
                        );
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
      ),
    );
  }
}

const primaryColor = Color(0xFF000000);
const canvasColor = Color(0xFF000000);
const scaffoldBackgroundColor = Color(0xFFFFFFFF);
