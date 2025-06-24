import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/api.dart';
import '../../services/theme.dart';
import 'Devices.dart';
class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  Map<String, bool> deviceStates = {
    'lamp1': false,
    'lamp2': false,
    'lamp3': false,
    'ventilation': true,
  };
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDeviceStatuses();
  }

  Future<void> fetchDeviceStatuses() async {
    try {
      final data = await apiService.fetchDeviceStatuses();
      if (data != null) {
        setState(() {
          deviceStates['lamp1'] = data['lampen']['lamp1'] == 'on';
          deviceStates['lamp2'] = data['lampen']['lamp2'] == 'on';
          deviceStates['lamp3'] = data['lampen']['lamp3'] == 'on';
          deviceStates['ventilatie'] = data['ventilatie'] == 'on';
        });
        print('Apparaat statussen succesvol opgehaald: $data');
      } else {
        print('Geen data gevonden');
      }
    } catch (e) {
      print('Fout bij ophalen apparaat statussen: $e');
    }
  }

  void toggleDevice(String deviceId) async {
    bool currentState = deviceStates[deviceId] ?? false;
    bool success = false;

    if (deviceId.startsWith('lamp')) {
      success = await apiService.controlLamp(deviceId, currentState ? "off" : "on");
    } else if (deviceId == 'ventilation') {
      success = await apiService.controlVentilation(currentState ? "off" : "on");
    }

    if (success) {
      setState(() {
        deviceStates[deviceId] = !currentState;
      });
    }
  }

  void addDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apparaat Toevoegen'),
        content: const Text('Functionaliteit voor apparaten toevoegen komt hier.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  DeviceCard(
                    isOn: deviceStates['lamp1'] ?? false,
                    onToggle: () => toggleDevice('lamp1'),
                    activeIcon: Icons.lightbulb,
                    inactiveIcon: Icons.lightbulb_outline,
                    activeColor: Colors.yellow,
                    deviceName: 'Lamp 1',
                  ),
                  DeviceCard(
                    isOn: deviceStates['lamp2'] ?? false,
                    onToggle: () => toggleDevice('lamp2'),
                    activeIcon: Icons.lightbulb,
                    inactiveIcon: Icons.lightbulb_outline,
                    activeColor: Colors.orange,
                    deviceName: 'Lamp 2',
                  ),
                  DeviceCard(
                    isOn: deviceStates['lamp3'] ?? false,
                    onToggle: () => toggleDevice('lamp3'),
                    activeIcon: Icons.lightbulb,
                    inactiveIcon: Icons.lightbulb_outline,
                    activeColor: Colors.green,
                    deviceName: 'Lamp 3',
                  ),
                  DeviceCard(
                    isOn: deviceStates['ventilation'] ?? false,
                    onToggle: () => toggleDevice('ventilation'),
                    activeIcon: Icons.air,
                    inactiveIcon: Icons.air_outlined,
                    activeColor: Colors.blue,
                    deviceName: 'Ventilatie',
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addDevice,
                child: const Text('Apparaten Toevoegen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DeviceCard extends StatelessWidget {
  final bool isOn;
  final String deviceName;
  final VoidCallback onToggle;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.isOn,
    required this.onToggle,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      elevation: 5,
      color: themeProvider.themeMode == ThemeMode.dark
          ? Colors.blueGrey[800]
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              isOn ? activeIcon : inactiveIcon,
              size: 80,
              color: isOn ? activeColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            deviceName,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: themeProvider.themeMode == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}