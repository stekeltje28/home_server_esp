import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../services/api.dart';
import '../../services/theme.dart';
import '../../services/wheather_api.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final ApiService apiService = ApiService();
  final WeatherApi weatherApi = WeatherApi(apiKey: '6f9f1d2a6a49eb456ba5df1beab21e57');
  String home_temperature = 'Laden...';
  String temperature = "Laden...";
  String weatherDescription = "";
  String humidity = "";
  String windSpeed = "";
  String iconUrl = "";

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
    fetchTemperature();
  }

  Future<void> fetchTemperature() async {
    final data = await apiService.fetchTemperature();
    if (data != null) {
      setState(() {
        home_temperature = "${data["temperatuur"]}°C";
      });
    } else {
      setState(() {
        home_temperature = "Fout bij ophalen!";
      });
    }
  }


  Future<void> fetchWeatherData() async {
    try {
      final data = await weatherApi.fetchWeatherByCity("Amsterdam");
      if (data != null) {
        setState(() {
          temperature = "${data['main']['temp']}°C";
          weatherDescription = data['weather'][0]['description'];
          humidity = "${data['main']['humidity']}%";
          windSpeed = "${data['wind']['speed']} m/s";
          iconUrl = "https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png";
        });
      } else {
        setState(() {
          temperature = "Fout bij ophalen!";
          weatherDescription = "";
          humidity = "";
          windSpeed = "";
        });
      }
    } catch (e) {
      setState(() {
        temperature = "Fout bij ophalen!";
        weatherDescription = "";
        humidity = "";
        windSpeed = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.blueGrey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Huis temperatuur: $home_temperature",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.deepPurpleAccent,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? Colors.blueGrey[800]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (iconUrl.isNotEmpty)
                      Image.network(iconUrl, width: 80, height: 80),
                    Text(
                      "Buiten temperatuur: 20 graden",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Weer: $weatherDescription",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.white70
                        : Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Luchtvochtigheid: $humidity",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.white70
                            : Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Wind: $windSpeed",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: themeProvider.themeMode == ThemeMode.dark
                            ? Colors.white70
                            : Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
