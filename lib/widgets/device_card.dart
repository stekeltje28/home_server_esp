import 'package:flutter/material.dart';

class DeviceCard extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onDelete;
  final VoidCallback onInfo;

  const DeviceCard({
    super.key,
    required this.imageUrl,
    required this.onDelete,
    required this.onInfo,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // Vierkante vorm
      height: 150, // Zelfde als breedte
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Afbeelding in het midden
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.network(
                  widget.imageUrl,
                  width: 60, // Groter maken indien nodig
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                ),
              ),
            ),

            // Drie puntjes menu rechtsboven
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    widget.onDelete();
                  } else if (value == 'info') {
                    widget.onInfo();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Verwijderen'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'info',
                    child: ListTile(
                      leading: Icon(Icons.info, color: Colors.blue),
                      title: Text('Info'),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
