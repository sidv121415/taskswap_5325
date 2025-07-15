import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late final SupabaseClient _client;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (!_initialized) {
      final supabaseService = SupabaseService();
      _client = await supabaseService.client;
      _initialized = true;
    }
  }

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String type,
    required String message,
  }) async {
    await _initialize();
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': type,
        'message': message,
        'read': false,
      });
    } catch (error) {
      throw Exception('Failed to create notification: $error');
    }
  }

  // Get user notifications
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    await _initialize();
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get notifications: $error');
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _initialize();
    try {
      await _client
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);
    } catch (error) {
      throw Exception('Failed to mark notification as read: $error');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    await _initialize();
    try {
      await _client
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
    } catch (error) {
      throw Exception('Failed to mark all notifications as read: $error');
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    await _initialize();
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('read', false)
          .count();
      return response.count;
    } catch (error) {
      throw Exception('Failed to get unread count: $error');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _initialize();
    try {
      await _client.from('notifications').delete().eq('id', notificationId);
    } catch (error) {
      throw Exception('Failed to delete notification: $error');
    }
  }

  // Listen to real-time notifications
  Stream<List<Map<String, dynamic>>> listenToNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
