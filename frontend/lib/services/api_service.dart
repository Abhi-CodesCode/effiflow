import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000/api";

  final Ref ref;

  ApiService(this.ref);

  // Private helper method for making GET requests
  Future<dynamic> _get(String endpoint) async {
    print("Requesting: $baseUrl/$endpoint");
    final token = ref.read(authProvider.notifier).getAccessToken();
    print("Token: $token");
    final response = await http.get(
      Uri.parse("$baseUrl/$endpoint"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from $endpoint');
    }
  }

  Future<List<dynamic>> getTasks() async {
    print("getTasks called");
    final response = await _get("tasks");
    print("getTasks response: $response");
    if (response is Map<String, dynamic> && response.containsKey('tasks')) {
      return response['tasks'];
    } else {
      throw Exception('Invalid response format for tasks');
    }
  }

  Future<Map<String, dynamic>?> getClipboard() async {
    print("getClipboard called");
    try {
      final response = await _get("clipboard");
      print("getClipboard response: $response");
      if (response is Map<String, dynamic> && response.containsKey('clipboard')) {
        final clipboardList = response['clipboard'] as List<dynamic>;
        if (clipboardList.isNotEmpty) {
          return clipboardList.first as Map<String, dynamic>;
        } else {
          return null;
        }
      } else {
        throw Exception('Invalid response format for clipboard');
      }
    } catch (e) {
      print("getClipboard error: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userId, String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/user/$userId"),
      headers: {
        'Authorization': 'Bearer $token', // Example of token-based authentication
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load user profile");
    }
  }
}