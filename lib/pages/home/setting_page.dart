import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:youtube_chat_app/services/alert_service.dart';
import 'package:youtube_chat_app/services/auth_service.dart';
import 'package:youtube_chat_app/services/database_service.dart';
import 'package:youtube_chat_app/services/local_storage.dart';
import 'package:youtube_chat_app/services/navigation_service.dart';
import 'package:youtube_chat_app/widgets/pfpdialog.dart';
import '../../services/theme.dart';

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
  late UserProfile _userProfile;

  var _fullName = '';
  var _pfpURL = '';

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance.get<AuthService>();
    _navigationService = GetIt.instance.get<NavigationService>();
    _alertService = GetIt.instance.get<AlertService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
    _userProfile = widget.userProfile;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      UserProfile? userProfile = await _databaseService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _fullName = userProfile.name ?? 'Onbekend';
          _pfpURL = userProfile.pfpURL ?? '';
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
          _pfpURL = downloadUrl;
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
              onTap: () async {
                await _updateThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: const Icon(Icons.dark_mode),
              title: const Text('Donker'),
              onTap: () async {
                await _updateThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: const Icon(Icons.phone_android),
              title: const Text('Systeem'),
              onTap: () async {
                await _updateThemeMode(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateThemeMode(ThemeMode themeMode) async {
    await LocalStorage.save('theme_mode', themeMode.toString().split('.').last);
    Provider.of<ThemeProvider>(context, listen: false).loadThemeMode();
    _getThemeModeText();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _profileSection(context, themeProvider, _fullName, _pfpURL),
              Padding(
                padding: EdgeInsets.all(themeProvider.themeMode == ThemeMode.dark ? 18 : 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0x1A000000),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x1A000000),
                        border: Border.all(
                          color: Colors.white, // Kies de kleur van de rand
                          width: 2, // Stel de dikte van de rand in
                        ),
                      ),
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
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
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(themeProvider.themeMode == ThemeMode.dark ? 18 : 8),
                child: InkWell(
                    onTap: () async {
                      bool result = await _authService.logout();
                      if (result) {
                        _navigationService.pushReplacementNamed('/login');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x1A000000),
                        border: Border.all(
                          color: Colors.white,
                          width: 2, // Stel de dikte van de rand in
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Uitloggen',
                            style: TextStyle(
                              color: themeProvider.themeMode == ThemeMode.dark
                                  ? Colors.blueGrey
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.logout,
                            color: themeProvider.themeMode == ThemeMode.dark
                                ? Colors.blueGrey
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeModeText() {
    var theme = LocalStorage.get("theme_mode");
    return theme;
  }

  Widget _profileSection(BuildContext context, ThemeProvider themeProvider, fullName, pfpURL) {
    return Container(
      padding: const EdgeInsets.all(30.0),
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
                      return PfpDialog(
                        pfpURL: pfpURL.isEmpty ? '' : pfpURL,
                        onEdit: _editProfilePicture,
                        themeProvider: themeProvider,
                        edit: true,
                      );
                    },
                  );
                },
                child: AvatarGlow(
                  glowCount: 2,
                  startDelay: const Duration(seconds: 2),
                  glowRadiusFactor: 0.3,
                  glowColor: Colors.blueGrey,
                  glowShape: BoxShape.circle,
                  curve: Curves.fastOutSlowIn,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(pfpURL),
                      radius: 80.0,
                    ),
                  ),
                ),
              Positioned(
                bottom: 5,
                right: 5,
                child: GestureDetector(
                  onTap: _editProfilePicture,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.themeMode == ThemeMode.dark ? Colors.blueGrey : Colors.blue[200],
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
            '$fullName',
            style: TextStyle(
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.blueGrey
                  : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
