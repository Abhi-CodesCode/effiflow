import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_provider.dart';

final userProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final auth = ref.watch(authProvider.notifier);
  final token = await auth.getToken();

  if (token == null) {
    throw Exception('No authentication token available');
  }

  final response = await http.get(
    Uri.parse('http://localhost:8000/api/user'), // Replace with your API endpoint
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load user data');
  }
});