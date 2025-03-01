import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =  "http://localhost:8000/api"; // For iOS Simulator

  static Future<dynamic> getData(String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl/$endpoint"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load data");
    }
  }
}
