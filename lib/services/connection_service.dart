import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class ConnectionService {
  static final ConnectionService _instance = ConnectionService._internal();
  factory ConnectionService() => _instance;
  ConnectionService._internal();

  late final SupabaseClient _client;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (!_initialized) {
      final supabaseService = SupabaseService();
      _client = await supabaseService.client;
      _initialized = true;
    }
  }

  // Send connection request
  Future<void> sendConnectionRequest(String fromUserId, String toUserId) async {
    await _initialize();
    try {
      await _client.from('connection_requests').insert({
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'status': 'pending',
      });
    } catch (error) {
      throw Exception('Failed to send connection request: $error');
    }
  }

  // Accept connection request
  Future<void> acceptConnectionRequest(String requestId) async {
    await _initialize();
    try {
      await _client
          .from('connection_requests')
          .update({'status': 'accepted'}).eq('id', requestId);
    } catch (error) {
      throw Exception('Failed to accept connection request: $error');
    }
  }

  // Decline connection request
  Future<void> declineConnectionRequest(String requestId) async {
    await _initialize();
    try {
      await _client
          .from('connection_requests')
          .update({'status': 'declined'}).eq('id', requestId);
    } catch (error) {
      throw Exception('Failed to decline connection request: $error');
    }
  }

  // Get pending connection requests for user
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
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
          .eq('to_user_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get pending requests: $error');
    }
  }

  // Get sent connection requests
  Future<List<Map<String, dynamic>>> getSentRequests(String userId) async {
    await _initialize();
    try {
      final response = await _client.from('connection_requests').select('''
            id,
            from_user_id,
            to_user_id,
            status,
            created_at,
            from_user:user_profiles!from_user_id(id, username, name, photo),
            to_user:user_profiles!to_user_id(id, username, name, photo)
          ''').eq('from_user_id', userId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get sent requests: $error');
    }
  }

  // Check connection status between two users
  Future<String?> getConnectionStatus(String user1Id, String user2Id) async {
    await _initialize();
    try {
      final response = await _client
          .from('connection_requests')
          .select('status')
          .or('and(from_user_id.eq.$user1Id,to_user_id.eq.$user2Id),and(from_user_id.eq.$user2Id,to_user_id.eq.$user1Id)')
          .limit(1);

      if (response.isEmpty) {
        return null; // No connection request exists
      }

      return response.first['status'] as String;
    } catch (error) {
      throw Exception('Failed to check connection status: $error');
    }
  }

  // Check if users are connected
  Future<bool> areUsersConnected(String user1Id, String user2Id) async {
    await _initialize();
    try {
      final response = await _client
          .from('connection_requests')
          .select('id')
          .or('and(from_user_id.eq.$user1Id,to_user_id.eq.$user2Id),and(from_user_id.eq.$user2Id,to_user_id.eq.$user1Id)')
          .eq('status', 'accepted')
          .count();
      return response.count > 0;
    } catch (error) {
      return false;
    }
  }

  // Delete connection request
  Future<void> deleteConnectionRequest(String requestId) async {
    await _initialize();
    try {
      await _client.from('connection_requests').delete().eq('id', requestId);
    } catch (error) {
      throw Exception('Failed to delete connection request: $error');
    }
  }
}
