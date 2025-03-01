import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});

class AuthState {
  final String? token;
  final String? refreshToken;
  final bool isLoading;

  const AuthState({
    this.token,
    this.refreshToken,
    required this.isLoading,
  });

  AuthState copyWith({
    String? token,
    String? refreshToken,
    bool? isLoading,
  }) {
    return AuthState(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthProvider extends StateNotifier<AuthState> {
  SharedPreferences? _prefs;

  AuthProvider() : super(const AuthState(isLoading: true, token: null, refreshToken: null)) {
    _init();
  }

  Future<void> _init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final token = _prefs?.getString('access_token');
      final refreshToken = _prefs?.getString('refresh_token');
      state = state.copyWith(
        token: token,
        refreshToken: refreshToken,
        isLoading: false,
      );
    } catch (e) {
      state = const AuthState(token: null, refreshToken: null, isLoading: false);
    }
  }

  Future<void> _ensurePrefsInitialized() async {
    if (_prefs == null) {
      await _init();
    }
  }

  Future<void> login(String email, String password) async {
    await _ensurePrefsInitialized();
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _prefs?.setString('access_token', data['access_token']);
        await _prefs?.setString('refresh_token', data['refresh_token']);
        state = AuthState(
          token: data['access_token'],
          refreshToken: data['refresh_token'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> register(String name, String email, String password) async {
    await _ensurePrefsInitialized();
    state = state.copyWith(isLoading: true);
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        await login(email, password);
      } else {
        state = state.copyWith(isLoading: false);
        throw Exception('Registration failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _ensurePrefsInitialized();
    state = state.copyWith(isLoading: true);
    try {
      await _prefs?.remove('access_token');
      await _prefs?.remove('refresh_token');
      state = const AuthState(token: null, refreshToken: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}