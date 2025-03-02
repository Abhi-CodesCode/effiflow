import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../services/api_service.dart';

final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final apiService = ApiService(ref); // Assuming you have an ApiService
  try {
    final tasksJson = await apiService.getTasks(); // Fetch tasks from API
    final tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
    return tasks;
  } catch (e) {
    throw Exception('Failed to load tasks: $e');
  }
});