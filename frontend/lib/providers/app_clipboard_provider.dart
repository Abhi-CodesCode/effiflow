import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/app_clipboard_data.dart';
import 'package:frontend/services/api_service.dart';

final appClipboardDataProvider = FutureProvider<AppClipboardData?>((ref) async {
  final apiService = ApiService(ref);
  try {
    final clipboardJson = await apiService.getClipboard();
    print("clipboardJson: $clipboardJson");
    if (clipboardJson == null) {
      return null; // No clipboard data found
    }
    return AppClipboardData.fromJson(clipboardJson);
  } catch (e) {
    throw Exception('Failed to load clipboard data: $e');
  }
});