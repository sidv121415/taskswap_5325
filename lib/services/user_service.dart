import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  late final SupabaseClient _client;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (!_initialized) {
      final supabaseService = SupabaseService();
      _client = await supabaseService.client;
      _initialized = true;
    }
  }

  // Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    await _initialize();
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _initialize();
    try {
      await _client.from('user_profiles').update(data).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Search users by username or name
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    await _initialize();
    try {
      final response = await _client
          .from('user_profiles')
          .select('id, username, name, email, photo')
          .or('username.ilike.%$query%,name.ilike.%$query%')
          .limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search users: $error');
    }
  }

  // Get all users (for directory)
  Future<List<Map<String, dynamic>>> getAllUsers({int limit = 50}) async {
    await _initialize();
    try {
      final response = await _client
          .from('user_profiles')
          .select('id, username, name, email, photo')
          .order('created_at', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get users: $error');
    }
  }

  // Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    await _initialize();
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('username', username)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to get user by username: $error');
    }
  }

  // Check if username exists
  Future<bool> checkUsernameExists(String username) async {
    await _initialize();
    try {
      final response = await _client
          .from('user_profiles')
          .select('id')
          .eq('username', username)
          .count();
      return response.count > 0;
    } catch (error) {
      return false;
    }
  }

  // Get user connections
  Future<List<Map<String, dynamic>>> getUserConnections(String userId) async {
    await _initialize();
    try {
      final response = await _client
          .from('connection_requests')
          .select('''
            id,
            from_user_id,
            to_user_id,
            status,
            created_at,
            from_user:user_profiles!from_user_id(id, username, name, photo),
            to_user:user_profiles!to_user_id(id, username, name, photo)
          ''')
          .or('from_user_id.eq.$userId,to_user_id.eq.$userId')
          .eq('status', 'accepted')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user connections: $error');
    }
  }
}
