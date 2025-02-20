import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:youtube_chat_app/pages/home/contact_page.dart';
import 'package:youtube_chat_app/services/theme.dart';
import 'package:youtube_chat_app/widgets/pfpdialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_chat_app/models/user_profile.dart';
import 'package:get_it/get_it.dart';
import 'package:youtube_chat_app/services/database_service.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBlurryContactContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurryContactContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BlurryContainer(
        blur: 10,
        width: double.infinity,
        height: 150,
        elevation: 0,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xAA1E1E1E) // Donkergrijs met hogere opaciteit voor dark mode
            : const Color(0x2F000000),  // Transparanter zwart voor light mode
        borderRadius: BorderRadius.circular(20.0),
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0x2F000000),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        MaterialPageRoute(
                          builder: (context) => const ContactPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Expanded(child: _buildEmployeeRow(ThemeProvider())),
          ],
        ),
      ),
    );
  }


  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0x2F000000),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                MaterialPageRoute(
                  builder: (context) => const ContactPage(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(ThemeProvider themeProvider) {
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

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final users = snapshot.data?.docs
            .where((doc) => doc.data().access == true)
            .map((doc) => doc.data())
            .toList() ??
            [];

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
                        return PfpDialog(
                          pfpURL: user.pfpURL != null && user.pfpURL!.isNotEmpty
                              ? user.pfpURL!
                              : 'assets/image/default.jpg',
                          themeProvider: themeProvider,
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: user.pfpURL != null && user.pfpURL!.isNotEmpty
                        ? NetworkImage(user.pfpURL!)
                        : const AssetImage('assets/image/default.jpg')
                    as ImageProvider,
                    radius: 30,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
