import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:youtube_chat_app/services/theme_service.dart';

class SettingPage extends StatefulWidget {
  final UserProfile userProfile;

  const SettingPage({super.key, required this.userProfile});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  final ImagePicker _picker = ImagePicker();
  ThemeMode _themeMode = ThemeMode.system;
  late UserProfile _userProfile;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance.get<AuthService>();
    _navigationService = GetIt.instance.get<NavigationService>();
    _alertService = GetIt.instance.get<AlertService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
    _userProfile = widget.userProfile;
  }




  Future<void> _editProfilePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures')
            .child(DateTime.now().toIso8601String());

        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await _databaseService.updateUserProfilePicture(downloadUrl);

        setState(() {
          _userProfile = _userProfile.copyWith(pfpURL: downloadUrl);
        });

        _alertService.showToast(text: 'Profile picture updated!', icon: Icons.check);
      } catch (e) {
        _alertService.showToast(text: 'Error updating profile picture.', icon: Icons.error_outline);
      }
    } else {
      _alertService.showToast(text: 'No image selected.', icon: Icons.info_outline);
    }
  }

  void _showThemeModeSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: const Icon(Icons.light_mode),
              title: const Text('Licht'),
              onTap: () {
                setState(() {
                  _themeMode = ThemeMode.light;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: const Icon(Icons.dark_mode),
              title: const Text('Donker'),
              onTap: () {
                setState(() {
                  _themeMode = ThemeMode.dark;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: const Icon(Icons.phone_android),
              title: const Text('Systeem'),
              onTap: () {
                setState(() {
                  _themeMode = ThemeMode.system;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _profileSection(context),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0x1A000000),
              ),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column( // Gebruik Column in plaats van ListView hier
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: const Text('Dark Mode'),
                        subtitle: Text(_getThemeModeText()),
                        onTap: _showThemeModeSheet,
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Meldingen'),
                        subtitle: const Text('Meldingsinstellingen aanpassen'),
                        onTap: () {
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0x1A000000),
              ),
              child: InkWell(
                onTap: () async {
                  bool result = await _authService.logout();
                  if (result) {
                    _navigationService.pushReplacementNamed('/login');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Uitloggen',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _getThemeModeText() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Licht';
      case ThemeMode.dark:
        return 'Donker';
      case ThemeMode.system:
      default:
        return 'Systeem';
    }
  }

  Widget _profileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
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
                                image: AssetImage('assets/image/Schermafbeelding 2024-07-31 104216.png'),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage('assets/image/Schermafbeelding 2024-07-31 104216.png'),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: _editProfilePicture,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Onbekend', // Gebruik een fallback voor als gebruikersnaam niet beschikbaar is
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
