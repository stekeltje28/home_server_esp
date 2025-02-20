import 'package:flutter/material.dart';
import 'package:youtube_chat_app/services/theme.dart';

class PfpDialog extends StatelessWidget {
  final String pfpURL;
  final VoidCallback? onEdit;
  final ThemeProvider themeProvider;
  final bool? edit;

  PfpDialog({
    Key? key,
    required this.pfpURL,
    this.onEdit,
    this.edit = false,
    required this.themeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? Colors.blueGrey
          : Colors.white70,
      child: Container(
        decoration: BoxDecoration(
          color: themeProvider.themeMode == ThemeMode.dark
              ? Colors.blueGrey
              : Colors.white70, // Gebruik de dialoog achtergrondkleur van het thema
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Stel de border radius in
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.75, // Stel de breedte in van het vierkant
                      height: MediaQuery.sizeOf(context).height * 0.4, // Stel de hoogte in van het vierkant
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: pfpURL != null && pfpURL!.isNotEmpty
                              ? NetworkImage(pfpURL!)
                              : const AssetImage('assets/image/default.jpg'),
                          fit: BoxFit.cover, // Zorg ervoor dat de afbeelding netjes wordt bijgesneden
                        ),
                        borderRadius: BorderRadius.circular(15), // Zorg voor afgeronde hoeken
                        color: Colors.grey[200], // Standaardkleur voor wanneer er geen afbeelding is
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // Donkere achtergrond
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop(); // Sluit de dialoog
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (edit != false)
              const SizedBox(height: 20),
            if (edit != false)
              ElevatedButton(
                onPressed: onEdit,
                child: Text(
                  'Bewerk Foto',
                  style: TextStyle(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme
                      .of(context)
                      .cardColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
