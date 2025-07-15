import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  late final SupabaseClient _client;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (!_initialized) {
      final supabaseService = SupabaseService();
      _client = await supabaseService.client;
      _initialized = true;
    }
  }

  // Create a new task
  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    required String priority,
    DateTime? dueDate,
    required String assignedBy,
    required String assignedTo,
  }) async {
    await _initialize();
    try {
      final response = await _client
          .from('tasks')
          .insert({
            'title': title,
            'description': description,
            'priority': priority,
            'due_date': dueDate?.toIso8601String(),
            'assigned_by': assignedBy,
            'assigned_to': assignedTo,
            'status': 'pending',
          })
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create task: $error');
    }
  }

  // Get tasks assigned to a user
  Future<List<Map<String, dynamic>>> getMyTasks(String userId) async {
    await _initialize();
    try {
      final response = await _client.from('tasks').select('''
            id,
            title,
            description,
            priority,
            due_date,
            status,
            created_at,
            assigned_by,
            assigned_to,
            assigner:user_profiles!assigned_by(id, username, name, photo),
            assignee:user_profiles!assigned_to(id, username, name, photo)
          ''').eq('assigned_to', userId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get my tasks: $error');
    }
  }

  // Get tasks assigned by a user
  Future<List<Map<String, dynamic>>> getSentTasks(String userId) async {
    await _initialize();
    try {
      final response = await _client.from('tasks').select('''
            id,
            title,
            description,
            priority,
            due_date,
            status,
            created_at,
            assigned_by,
            assigned_to,
            assigner:user_profiles!assigned_by(id, username, name, photo),
            assignee:user_profiles!assigned_to(id, username, name, photo)
          ''').eq('assigned_by', userId).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get sent tasks: $error');
    }
  }

  // Update task status
  Future<void> updateTaskStatus(String taskId, String status) async {
    await _initialize();
    try {
      await _client.from('tasks').update({'status': status}).eq('id', taskId);
    } catch (error) {
      throw Exception('Failed to update task status: $error');
    }
  }

  // Get task by ID
  Future<Map<String, dynamic>?> getTaskById(String taskId) async {
    await _initialize();
    try {
      final response = await _client.from('tasks').select('''
            id,
            title,
            description,
            priority,
            due_date,
            status,
            created_at,
            assigned_by,
            assigned_to,
            assigner:user_profiles!assigned_by(id, username, name, photo),
            assignee:user_profiles!assigned_to(id, username, name, photo)
          ''').eq('id', taskId).single();
      return response;
    } catch (error) {
      throw Exception('Failed to get task: $error');
    }
  }

  // Filter tasks by status
  Future<List<Map<String, dynamic>>> filterTasksByStatus(
      String userId, String status,
      {bool isSentTasks = false}) async {
    await _initialize();
    try {
      final column = isSentTasks ? 'assigned_by' : 'assigned_to';
      final response = await _client
          .from('tasks')
          .select('''
            id,
            title,
            description,
            priority,
            due_date,
            status,
            created_at,
            assigned_by,
            assigned_to,
            assigner:user_profiles!assigned_by(id, username, name, photo),
            assignee:user_profiles!assigned_to(id, username, name, photo)
          ''')
          .eq(column, userId)
          .eq('status', status)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to filter tasks: $error');
    }
  }

  // Filter tasks by priority
  Future<List<Map<String, dynamic>>> filterTasksByPriority(
      String userId, String priority,
      {bool isSentTasks = false}) async {
    await _initialize();
    try {
      final column = isSentTasks ? 'assigned_by' : 'assigned_to';
      final response = await _client
          .from('tasks')
          .select('''
            id,
            title,
            description,
            priority,
            due_date,
            status,
            created_at,
            assigned_by,
            assigned_to,
            assigner:user_profiles!assigned_by(id, username, name, photo),
            assignee:user_profiles!assigned_to(id, username, name, photo)
          ''')
          .eq(column, userId)
          .eq('priority', priority)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to filter tasks by priority: $error');
    }
  }

  // Sort tasks by due date
  Future<List<Map<String, dynamic>>> sortTasksByDueDate(String userId,
      {bool ascending = true, bool isSentTasks = false}) async {
    await _initialize();
    try {
      final column = isSentTasks ? 'assigned_by' : 'assigned_to';
      final response = await _client
          .from('tasks')
          .select('''
            id,
            title,
            description,
            priority,
            due_date,
            status,
            created_at,
            assigned_by,
            assigned_to,
            assigner:user_profiles!assigned_by(id, username, name, photo),
            assignee:user_profiles!assigned_to(id, username, name, photo)
          ''')
          .eq(column, userId)
          .order('due_date', ascending: ascending, nullsFirst: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to sort tasks by due date: $error');
    }
  }

  // Get task statistics
  Future<Map<String, dynamic>> getTaskStatistics(String userId) async {
    await _initialize();
    try {
      final results = await Future.wait([
        // Total tasks assigned to user
        _client.from('tasks').select().eq('assigned_to', userId).count(),

        // Completed tasks
        _client
            .from('tasks')
            .select()
            .eq('assigned_to', userId)
            .eq('status', 'completed')
            .count(),

        // Pending tasks
        _client
            .from('tasks')
            .select()
            .eq('assigned_to', userId)
            .eq('status', 'pending')
            .count(),

        // Tasks sent by user
        _client.from('tasks').select().eq('assigned_by', userId).count(),
      ]);

      final totalTasks = results[0].count;
      final completedTasks = results[1].count;
      final pendingTasks = results[2].count;
      final sentTasks = results[3].count;

      return {
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'pending_tasks': pendingTasks,
        'sent_tasks': sentTasks,
        'completion_rate':
            totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to get task statistics: $error');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await _initialize();
    try {
      await _client.from('tasks').delete().eq('id', taskId);
    } catch (error) {
      throw Exception('Failed to delete task: $error');
    }
  }
}
