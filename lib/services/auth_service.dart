import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late final SupabaseClient _client;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (!_initialized) {
      final supabaseService = SupabaseService();
      _client = await supabaseService.client;
      _initialized = true;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? name,
    String? phone,
  }) async {
    await _initialize();
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username ?? email.split('@')[0],
          'name': name ?? email.split('@')[0],
          'phone': phone,
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    await _initialize();
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _initialize();
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Get current session
  Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    return _client.auth.currentUser != null;
  }

  // Get user ID
  String? get userId {
    return _client.auth.currentUser?.id;
  }
}
