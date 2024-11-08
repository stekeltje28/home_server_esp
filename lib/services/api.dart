import 'dart:convert';
import 'package:http/http.dart' as http;

class api {

  //voeg toe
  Future<void> addContent(String title, String content, String file, String url ) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/$url/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': title,
        'content': content,
        'file': file,
      }),
      );
    }

  //verwijder

  Future<void> deleteContent(int id, String url) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8000/api/$url/$id/'),
    );
  }

  //inzien

    Future<List<dynamic>> viewContent(url) async {
      final response = await http.get(Uri.parse('http://localhost:8000/api/$url/'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load text contents');
      }
    }
  }
