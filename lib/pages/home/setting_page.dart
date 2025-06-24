import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../services/alert_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/delete_account.dart';
import '../../services/local_storage.dart';
import '../../services/navigation_service.dart';
import '../../services/theme.dart';
import '../../widgets/pfpdialog.dart';

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
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _authService = GetIt.instance.get<AuthService>();
    _navigationService = GetIt.instance.get<NavigationService>();
    _alertService = GetIt.instance.get<AlertService>();
    _databaseService = GetIt.instance.get<DatabaseService>();
    _userProfile = widget.userProfile;
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    try {
      UserProfile? userProfile = await _databaseService.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _fullName = userProfile.name ?? 'Onbekend';
          _pfpURL = userProfile.pfpURL ?? '';

          // Veilige manier van ophalen van instellingen met fallback
          _notificationsEnabled = LocalStorage.get('notifications_enabled') ?? true;
        });
      }
    } catch (e) {
      print('Error loading user settings: $e');
      _alertService.showToast(
        text: 'Fout bij het ophalen van instellingen.',
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
            .child('${DateTime.now().toIso8601String()}_${_userProfile.uid}');

        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await _databaseService.updateUserProfilePicture(downloadUrl);

        setState(() {
          _pfpURL = downloadUrl;
        });

        _alertService.showToast(
            text: 'Profielfoto bijgewerkt!',
            icon: Icons.check
        );
      } catch (e) {
        _alertService.showToast(
            text: 'Fout bij bijwerken profielfoto.',
            icon: Icons.error_outline
        );
      }
    } else {
      _alertService.showToast(
          text: 'Geen afbeelding geselecteerd.',
          icon: Icons.info_outline
      );
    }
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
      LocalStorage.save('notifications_enabled', value);
      _alertService.showToast(
        text: value ? 'Meldingen ingeschakeld' : 'Meldingen uitgeschakeld',
        icon: value ? Icons.notifications_active : Icons.notifications_off,
      );
    });
  }

  void _showAccountDeletionConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account verwijderen'),
          content: const Text('Weet je zeker dat je je account wilt verwijderen? Dit kan niet ongedaan worden gemaakt.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () {
                DeleteAccountDialog.show(
                  context,
                  authService: _authService,
                  navigationService: _navigationService,
                  alertService: _alertService,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );
  }



  void _showThemeModeSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Licht'),
              onTap: () async {
                await _updateThemeMode(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Donker'),
              onTap: () async {
                await _updateThemeMode(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
            ListTile(
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
  }

  String _getThemeModeText() {
    String? theme = LocalStorage.get("theme_mode");
    switch (theme) {
      case 'light':
        return 'Licht';
      case 'dark':
        return 'Donker';
      case 'system':
        return 'Systeem';
      default:
        return 'Systeem';
    }
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.grey[800]
                        : const Color(0x1A000000),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.dark_mode),
                        title: const Text('Thema'),
                        subtitle: Text(_getThemeModeText()),
                        onTap: _showThemeModeSheet,
                      ),
                      SwitchListTile(
                        title: const Text('Meldingen'),
                        subtitle: const Text('Systeemmeldingen'),
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        secondary: const Icon(Icons.notifications),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_forever),
                        title: const Text('Account verwijderen'),
                        subtitle: const Text('Permanent account verwijderen'),
                        onTap: _showAccountDeletionConfirmation,
                        textColor: Colors.red,
                        iconColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(themeProvider.themeMode == ThemeMode.dark ? 18 : 8),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    bool result = await _authService.logout();
                    if (result) {
                      _navigationService.pushReplacementNamed('/login');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Uitloggen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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

  Widget _profileSection(BuildContext context, ThemeProvider themeProvider, String fullName, String pfpURL) {
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
                    backgroundImage: pfpURL.isNotEmpty
                        ? NetworkImage(pfpURL)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
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
                      color: themeProvider.themeMode == ThemeMode.dark
                          ? Colors.blueGrey
                          : Colors.blue[200],
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
            fullName,
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