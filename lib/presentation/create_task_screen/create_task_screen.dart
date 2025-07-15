import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/assignee_selection_widget.dart';
import './widgets/due_date_picker_widget.dart';
import './widgets/priority_picker_widget.dart';
import './widgets/reminder_settings_widget.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  String? _selectedAssigneeId;
  String? _selectedAssigneeName;
  String _selectedPriority = 'Medium';
  DateTime? _selectedDueDate;
  bool _reminderEnabled = false;
  int _reminderHours = 24;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  // Mock connections data
  final List<Map<String, dynamic>> _connections = [
    {
      "id": "user_001",
      "name": "Sarah Johnson",
      "username": "@sarah_j",
      "avatar":
          "https://images.unsplash.com/photo-1494790108755-2616b9c5e0c4?w=150&h=150&fit=crop&crop=face",
      "isOnline": true,
      "lastActive": "2 min ago"
    },
    {
      "id": "user_002",
      "name": "Michael Chen",
      "username": "@mike_chen",
      "avatar":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      "isOnline": false,
      "lastActive": "1 hour ago"
    },
    {
      "id": "user_003",
      "name": "Emily Rodriguez",
      "username": "@emily_r",
      "avatar":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      "isOnline": true,
      "lastActive": "Just now"
    },
    {
      "id": "user_004",
      "name": "David Kim",
      "username": "@david_kim",
      "avatar":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "isOnline": false,
      "lastActive": "3 hours ago"
    },
    {
      "id": "user_005",
      "name": "Jessica Taylor",
      "username": "@jess_taylor",
      "avatar":
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face",
      "isOnline": true,
      "lastActive": "5 min ago"
    }
  ];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty &&
        _selectedAssigneeId != null &&
        _selectedDueDate != null;
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Save Draft?',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              content: Text(
                'You have unsaved changes. Would you like to save as draft?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () {
                    _saveDraft();
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Save Draft'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Continue Editing'),
                ),
              ],
            ),
          ) ??
          false;
    }
    return true;
  }

  void _saveDraft() {
    // Mock draft saving functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _createTask() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Mock API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock task creation
      final taskData = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "assigneeId": _selectedAssigneeId,
        "assigneeName": _selectedAssigneeName,
        "priority": _selectedPriority,
        "dueDate": _selectedDueDate?.toIso8601String(),
        "reminderEnabled": _reminderEnabled,
        "reminderHours": _reminderHours,
        "createdAt": DateTime.now().toIso8601String(),
        "status": "Pending"
      };

      // Success haptic feedback
      HapticFeedback.mediumImpact();

      // Show success animation
      _showSuccessAnimation();

      // Navigate to sent tasks screen after delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/sent-tasks-screen');
      }
    } catch (error) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create task: Network error'),
          backgroundColor: AppTheme.errorLight,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _createTask,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check',
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Task Created!',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.successLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Create Task',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Task Title Field
                      _buildTaskTitleField(),
                      SizedBox(height: 3.h),

                      // Assignee Selection
                      AssigneeSelectionWidget(
                        connections: _connections,
                        selectedAssigneeId: _selectedAssigneeId,
                        onAssigneeSelected: (id, name) {
                          setState(() {
                            _selectedAssigneeId = id;
                            _selectedAssigneeName = name;
                          });
                          _onFormChanged();
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Description Field
                      _buildDescriptionField(),
                      SizedBox(height: 3.h),

                      // Priority Picker
                      PriorityPickerWidget(
                        selectedPriority: _selectedPriority,
                        onPriorityChanged: (priority) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                          _onFormChanged();
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Due Date Picker
                      DueDatePickerWidget(
                        selectedDate: _selectedDueDate,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDueDate = date;
                          });
                          _onFormChanged();
                        },
                      ),
                      SizedBox(height: 3.h),

                      // Reminder Settings
                      ReminderSettingsWidget(
                        reminderEnabled: _reminderEnabled,
                        reminderHours: _reminderHours,
                        onReminderToggled: (enabled) {
                          setState(() {
                            _reminderEnabled = enabled;
                          });
                          _onFormChanged();
                        },
                        onReminderHoursChanged: (hours) {
                          setState(() {
                            _reminderHours = hours;
                          });
                          _onFormChanged();
                        },
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),

              // Create Task Button
              _buildCreateTaskButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Title *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _titleController,
          maxLength: 100,
          style: AppTheme.lightTheme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter task title...',
            counterText: '${_titleController.text.length}/100',
            counterStyle: AppTheme.lightTheme.textTheme.bodySmall,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'assignment',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 5.w,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Task title is required';
            }
            if (value.trim().length < 3) {
              return 'Task title must be at least 3 characters';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            FocusScope.of(context).nextFocus();
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Add task description (optional)...',
            counterText: '${_descriptionController.text.length}/500',
            counterStyle: AppTheme.lightTheme.textTheme.bodySmall,
            alignLabelWithHint: true,
          ),
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }

  Widget _buildCreateTaskButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 6.h,
          child: ElevatedButton(
            onPressed: _isFormValid && !_isLoading ? _createTask : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFormValid
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              elevation: _isFormValid ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Create Task',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
