import 'package:flutter/material.dart';
import '../../services/api.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  State<Devices> createState() => _DevicesState();
}

class _DevicesState extends State<Devices> {
  bool isLampOn = false;
  bool isVentilationOn = true;
  final ApiService apiService = ApiService();

  void toggleLamp() async {
    bool success = await apiService.controlLamp("lamp1", isLampOn ? "off" : "on");
    if (success) {
      setState(() {
        isLampOn = !isLampOn;
      });
    }
  }

  void toggleVentilation() async {
    bool success = await apiService.controlVentilation(isVentilationOn ? "off" : "on");
    if (success) {
      setState(() {
        isVentilationOn = !isVentilationOn;
      });
    }
  }

  void addDevice() {
    // Voeg hier functionaliteit toe om een apparaat toe te voegen
    print("Apparaat toevoegen");
  }

  @override
  Widget build(BuildContext context) {
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
                    isOn: isLampOn,
                    onToggle: toggleLamp,
                    activeIcon: Icons.lightbulb,
                    inactiveIcon: Icons.lightbulb_outline,
                    activeColor: Colors.yellow,
                    labelOn: 'Lamp Uit',
                    labelOff: 'Lamp Aan',
                  ),
                  DeviceCard(
                    isOn: isVentilationOn,
                    onToggle: toggleVentilation,
                    activeIcon: Icons.air,
                    inactiveIcon: Icons.air_outlined,
                    activeColor: Colors.blue,
                    labelOn: 'Ventilatie Uit',
                    labelOff: 'Ventilatie Aan',
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addDevice,
                child: const Text("Apparaten Toevoegen"),
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
  final VoidCallback onToggle;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final String labelOn;
  final String labelOff;

  const DeviceCard({
    super.key,
    required this.isOn,
    required this.onToggle,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.activeColor,
    required this.labelOn,
    required this.labelOff,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isOn ? activeIcon : inactiveIcon,
            size: 80,
            color: isOn ? activeColor : Colors.grey,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onToggle,
            child: Text(isOn ? labelOn : labelOff),
          ),
        ],
      ),
    );
  }
}
