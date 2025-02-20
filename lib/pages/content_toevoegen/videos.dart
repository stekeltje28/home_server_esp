import 'dart:io'; // Voor File-class
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:video_player/video_player.dart'; // Import video_player
import 'package:http/http.dart' as http; // Import the http package
import 'package:mime/mime.dart'; // For handling file MIME types

class AddVideos extends StatefulWidget {
  const AddVideos({super.key});

  @override
  State<AddVideos> createState() => _VideoState();
}

class _VideoState extends State<AddVideos> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  final _titleController = TextEditingController();

  String _fullName = '';
  File? _selectedVideo;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
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
  }Future<void> addContent(String title,  File? file, String url) async {
    if (file == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/api/$url/'),
    );

    request.headers['Content-Type'] = 'application/json; charset=UTF-8';
    request.fields['title'] = title;

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


  Future<void> _selectVideo() async {
    try {
      final XFile? pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedVideo = File(pickedFile.path);
          _videoController = VideoPlayerController.file(_selectedVideo!);
              setState(() {
                _videoController = VideoPlayerController.file(_selectedVideo!);
              });
        });
      } else {
        _alertService.showToast(text: 'Error selecting video', icon: Icons.error_outline);
      }
    } catch (e) {
      print('Error selecting video: $e');
    }
  }

  Future<void> _uploadVideo(File videoFile) async {
    try {
      final String apiUrl = 'http://localhost:8000/api/videocontent/'; // Replace with your API URL
      final mimeType = lookupMimeType(videoFile.path); // Get the MIME type of the file
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.files.add(
        await http.MultipartFile.fromPath(
          'video', // Name of the form field the API expects
          videoFile.path,
          contentType: MediaType(mimeType!.split('/')[0], mimeType.split('/')[1]), // Set MIME type
        ),
      );

      // Send the request
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Video uploaded successfully');
        _alertService.showToast(
          text: 'Video succesvol geüpload!',
          icon: Icons.check_circle_outline,
        );
      } else {
        print('Failed to upload video: ${response.statusCode}');
        _alertService.showToast(
          text: 'Video uploaden mislukt!',
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      print('Error uploading video: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
                            'Video',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: min(
                                MediaQuery.of(context).size.width * 0.03 +
                                    MediaQuery.of(context).size.height * 0.01,
                                35,
                              ),
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
                              fontSize: 25,
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
                            onTap: _selectVideo,
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 0.8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey,
                              ),
                              child: _videoController != null && _videoController!.value.isInitialized
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                ),
                              )
                                  : const SizedBox(
                                height: 200,
                                child: Icon(Icons.video_library, size: 50),
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
                          _selectedVideo,
                          'videocontent', // vervang dit door de juiste URL
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


