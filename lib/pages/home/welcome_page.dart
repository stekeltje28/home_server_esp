import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final ApiService apiService = ApiService();
  String temperature = "Laden...";

  @override
  void initState() {
    super.initState();
    fetchTemperature();
  }

  Future<void> fetchTemperature() async {
    final data = await apiService.fetchTemperature();
    if (data != null) {
      setState(() {
        temperature = "${data["temperature"]}°C";
      });
    } else {
      setState(() {
        temperature = "Fout bij ophalen!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  "Huidige temperatuur: $temperature",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
