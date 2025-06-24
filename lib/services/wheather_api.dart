import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApi {
  final String apiKey;
  final String baseUrl = "https://api.openweathermap.org/data/2.5";

  // Constructor om de API-sleutel in te stellen
  WeatherApi({required this.apiKey});

  /// Haalt het huidige weer op voor een bepaalde stad
  Future<Map<String, dynamic>> fetchWeatherByCity(String city) async {
    final Uri url = Uri.parse("$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=nl");
    return _getData(url);
  }

  /// Haalt het huidige weer op voor een bepaalde locatie (latitude, longitude)
  Future<Map<String, dynamic>> fetchWeatherByLocation(double lat, double lon) async {
    final Uri url = Uri.parse("$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=nl");
    return _getData(url);
  }

  /// Haalt een 5-daagse weersvoorspelling op (elke 3 uur een update)
  Future<Map<String, dynamic>> fetchForecast(String city) async {
    final Uri url = Uri.parse("$baseUrl/forecast?q=$city&appid=$apiKey&units=metric&lang=nl");
    return _getData(url);
  }

  /// Haalt een 5-daagse weersvoorspelling op met coördinaten
  Future<Map<String, dynamic>> fetchForecastByLocation(double lat, double lon) async {
    final Uri url = Uri.parse("$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=nl");
    return _getData(url);
  }

  /// Haalt luchtvervuilingsgegevens op (CO, NO2, O3, PM2.5, etc.)
  Future<Map<String, dynamic>> fetchAirPollution(double lat, double lon) async {
    final Uri url = Uri.parse("$baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$apiKey");
    return _getData(url);
  }

  /// Haalt UV-index op basis van locatie
  Future<Map<String, dynamic>> fetchUVIndex(double lat, double lon) async {
    final Uri url = Uri.parse("$baseUrl/uvi?lat=$lat&lon=$lon&appid=$apiKey");
    return _getData(url);
  }

  /// Algemene functie om data op te halen en foutafhandeling te doen
  Future<Map<String, dynamic>> _getData(Uri url) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw _handleError(response.statusCode);
      }
    } catch (e) {
      throw Exception("Fout bij ophalen gegevens: $e");
    }
  }

  /// Foutafhandelingsfunctie
  Exception _handleError(int statusCode) {
    switch (statusCode) {
      case 401:
        return Exception("Ongeldige API-sleutel!");
      case 404:
        return Exception("Locatie niet gevonden!");
      case 429:
        return Exception("Te veel verzoeken! Probeer later opnieuw.");
      case 500:
      case 502:
      case 503:
        return Exception("Serverfout! Probeer later opnieuw.");
      default:
        return Exception("Onbekende fout: HTTP-statuscode $statusCode");
    }
  }
}
