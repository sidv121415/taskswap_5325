import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/task_actions_widget.dart';
import './widgets/task_comments_widget.dart';
import './widgets/task_description_widget.dart';
import './widgets/task_due_date_widget.dart';
import './widgets/task_header_widget.dart';
import './widgets/task_info_widget.dart';
import './widgets/task_priority_widget.dart';
import './widgets/task_status_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  bool _isKeyboardVisible = false;
  bool _isCurrentUserCreator = true; // Mock: current user is task creator

  // Mock task data
  final Map<String, dynamic> taskData = {
    "id": "task_001",
    "title": "Design new user onboarding flow",
    "description":
        "Create a comprehensive user onboarding experience that guides new users through the key features of TaskSwap. Include interactive tutorials, progress indicators, and personalized welcome messages. The flow should be intuitive and reduce time-to-value for new users while highlighting core functionality like task creation, user connections, and notification preferences.",
    "priority": "High",
    "status": "In Progress",
    "dueDate": "2025-07-20T18:00:00.000Z",
    "createdDate": "2025-07-10T09:30:00.000Z",
    "creator": {
      "id": "user_001",
      "name": "Sarah Johnson",
      "username": "@sarah_j",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b9e2b8b8?w=400&h=400&fit=crop&crop=face"
    },
    "assignee": {
      "id": "user_002",
      "name": "Michael Chen",
      "username": "@michael_c",
      "avatar":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face"
    },
    "comments": [
      {
        "id": "comment_001",
        "userId": "user_001",
        "userName": "Sarah Johnson",
        "userAvatar":
            "https://images.unsplash.com/photo-1494790108755-2616b9e2b8b8?w=400&h=400&fit=crop&crop=face",
        "content":
            "Hey Michael! I've added some initial wireframes to the project folder. Let me know if you need any clarification on the user flow requirements.",
        "timestamp": "2025-07-12T14:30:00.000Z",
        "replies": []
      },
      {
        "id": "comment_002",
        "userId": "user_002",
        "userName": "Michael Chen",
        "userAvatar":
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face",
        "content":
            "Thanks Sarah! The wireframes look great. I'm working on the interactive prototypes now. Should have the first iteration ready by tomorrow.",
        "timestamp": "2025-07-13T10:15:00.000Z",
        "replies": [
          {
            "id": "reply_001",
            "userId": "user_001",
            "userName": "Sarah Johnson",
            "userAvatar":
                "https://images.unsplash.com/photo-1494790108755-2616b9e2b8b8?w=400&h=400&fit=crop&crop=face",
            "content": "Perfect! Looking forward to seeing the prototypes.",
            "timestamp": "2025-07-13T11:00:00.000Z"
          }
        ]
      }
    ]
  };

  @override
  void initState() {
    super.initState();
    _commentFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isKeyboardVisible = _commentFocusNode.hasFocus;
    });
  }

  void _onTaskStatusChanged(String newStatus) {
    setState(() {
      taskData["status"] = newStatus;
    });
  }

  void _onCommentAdded(String comment) {
    if (comment.trim().isNotEmpty) {
      final newComment = {
        "id": "comment_${DateTime.now().millisecondsSinceEpoch}",
        "userId": "user_current",
        "userName": "Current User",
        "userAvatar":
            "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face",
        "content": comment.trim(),
        "timestamp": DateTime.now().toIso8601String(),
        "replies": []
      };

      setState(() {
        (taskData["comments"] as List).add(newComment);
      });

      _commentController.clear();
      _commentFocusNode.unfocus();
    }
  }

  void _onEditTask() {
    Navigator.pushNamed(context, '/create-task-screen');
  }

  void _onSendReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder sent to ${taskData["assignee"]["name"]}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _onRequestExtension() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Extension'),
        content:
            const Text('Would you like to request an extension for this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Extension request sent')),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  void _onShareTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task details copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and edit button
            TaskHeaderWidget(
              title: taskData["title"] as String,
              isCreator: _isCurrentUserCreator,
              onBack: () => Navigator.pop(context),
              onEdit: _onEditTask,
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Task info (creator/assignee)
                    TaskInfoWidget(
                      creator: taskData["creator"] as Map<String, dynamic>,
                      assignee: taskData["assignee"] as Map<String, dynamic>,
                      createdDate: taskData["createdDate"] as String,
                      isCurrentUserCreator: _isCurrentUserCreator,
                    ),

                    SizedBox(height: 3.h),

                    // Task description
                    TaskDescriptionWidget(
                      description: taskData["description"] as String,
                    ),

                    SizedBox(height: 3.h),

                    // Due date
                    TaskDueDateWidget(
                      dueDate: taskData["dueDate"] as String,
                    ),

                    SizedBox(height: 3.h),

                    // Priority
                    TaskPriorityWidget(
                      priority: taskData["priority"] as String,
                    ),

                    SizedBox(height: 3.h),

                    // Status
                    TaskStatusWidget(
                      status: taskData["status"] as String,
                      isCurrentUserCreator: _isCurrentUserCreator,
                      onStatusChanged: _onTaskStatusChanged,
                    ),

                    SizedBox(height: 3.h),

                    // Comments section
                    TaskCommentsWidget(
                      comments: taskData["comments"] as List,
                      commentController: _commentController,
                      commentFocusNode: _commentFocusNode,
                      onCommentAdded: _onCommentAdded,
                    ),

                    SizedBox(height: 3.h),

                    // Action buttons
                    TaskActionsWidget(
                      isCurrentUserCreator: _isCurrentUserCreator,
                      taskStatus: taskData["status"] as String,
                      onMarkComplete: () => _onTaskStatusChanged("Completed"),
                      onRequestExtension: _onRequestExtension,
                      onSendReminder: _onSendReminder,
                      onShareTask: _onShareTask,
                    ),

                    SizedBox(height: _isKeyboardVisible ? 30.h : 10.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
