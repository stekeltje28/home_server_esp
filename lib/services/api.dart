import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://192.168.x.x:5555"; // Vervang met je server IP

  // 🟢 Haal temperatuur op
  Future<Map<String, dynamic>?> fetchTemperature() async {
    final url = Uri.parse("$baseUrl/data");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Fout bij ophalen: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Netwerkfout: $e");
      return null;
    }
  }

  // 💡 Zet een lamp aan/uit
  Future<bool> controlLamp(String lampId, String status) async {
    final url = Uri.parse("$baseUrl/lamp");
    final body = jsonEncode({"lampid": lampId, "status": status});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Netwerkfout: $e");
      return false;
    }
  }

  // 🌬 Zet ventilatie aan/uit
  Future<bool> controlVentilation(String status) async {
    final url = Uri.parse("$baseUrl/ventilatie");
    final body = jsonEncode({"status": status});

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Netwerkfout: $e");
      return false;
    }
  }
}
