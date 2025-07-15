import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_sent_tasks_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/sent_task_card_widget.dart';

class SentTasksScreen extends StatefulWidget {
  const SentTasksScreen({super.key});

  @override
  State<SentTasksScreen> createState() => _SentTasksScreenState();
}

class _SentTasksScreenState extends State<SentTasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedFilter = 'All Sent';
  String _selectedSort = 'Due Date';
  String _selectedAssignee = 'All';
  bool _isSearching = false;
  bool _isRefreshing = false;

  // Mock data for sent tasks
  final List<Map<String, dynamic>> _allSentTasks = [
    {
      "id": "st_001",
      "title": "Review quarterly budget report",
      "description":
          "Please review the Q3 budget analysis and provide feedback on resource allocation for next quarter.",
      "assignee": {
        "id": "user_002",
        "name": "Sarah Johnson",
        "username": "@sarah_j",
        "avatar":
            "https://images.unsplash.com/photo-1494790108755-2616b9c8c8b1?w=400&h=400&fit=crop&crop=face"
      },
      "priority": "High",
      "status": "Pending",
      "dueDate": DateTime.now().add(Duration(days: 2)),
      "createdDate": DateTime.now().subtract(Duration(days: 3)),
      "isOverdue": false,
    },
    {
      "id": "st_002",
      "title": "Update project documentation",
      "description":
          "Update the API documentation with recent changes and add examples for new endpoints.",
      "assignee": {
        "id": "user_003",
        "name": "Michael Chen",
        "username": "@mike_dev",
        "avatar":
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop&crop=face"
      },
      "priority": "Medium",
      "status": "Completed",
      "dueDate": DateTime.now().subtract(Duration(days: 1)),
      "createdDate": DateTime.now().subtract(Duration(days: 5)),
      "isOverdue": false,
    },
    {
      "id": "st_003",
      "title": "Prepare presentation slides",
      "description":
          "Create slides for the client meeting covering project progress and next milestones.",
      "assignee": {
        "id": "user_004",
        "name": "Emily Rodriguez",
        "username": "@emily_r",
        "avatar":
            "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop&crop=face"
      },
      "priority": "High",
      "status": "Overdue",
      "dueDate": DateTime.now().subtract(Duration(days: 2)),
      "createdDate": DateTime.now().subtract(Duration(days: 7)),
      "isOverdue": true,
    },
    {
      "id": "st_004",
      "title": "Test mobile app features",
      "description":
          "Perform comprehensive testing of the new user authentication flow and report any issues.",
      "assignee": {
        "id": "user_005",
        "name": "David Kim",
        "username": "@david_qa",
        "avatar":
            "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face"
      },
      "priority": "Medium",
      "status": "Pending",
      "dueDate": DateTime.now().add(Duration(days: 5)),
      "createdDate": DateTime.now().subtract(Duration(days: 1)),
      "isOverdue": false,
    },
    {
      "id": "st_005",
      "title": "Review marketing campaign",
      "description":
          "Analyze the performance metrics of the recent social media campaign and suggest improvements.",
      "assignee": {
        "id": "user_006",
        "name": "Lisa Thompson",
        "username": "@lisa_marketing",
        "avatar":
            "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop&crop=face"
      },
      "priority": "Low",
      "status": "Completed",
      "dueDate": DateTime.now().subtract(Duration(days: 3)),
      "createdDate": DateTime.now().subtract(Duration(days: 8)),
      "isOverdue": false,
    },
  ];

  List<Map<String, dynamic>> get _filteredTasks {
    List<Map<String, dynamic>> filtered = List.from(_allSentTasks);

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((task) {
        final title = (task["title"] as String).toLowerCase();
        final description = (task["description"] as String).toLowerCase();
        final assigneeName =
            ((task["assignee"] as Map<String, dynamic>)["name"] as String)
                .toLowerCase();
        return title.contains(searchTerm) ||
            description.contains(searchTerm) ||
            assigneeName.contains(searchTerm);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All Sent') {
      filtered =
          filtered.where((task) => task["status"] == _selectedFilter).toList();
    }

    // Apply assignee filter
    if (_selectedAssignee != 'All') {
      filtered = filtered
          .where((task) =>
              ((task["assignee"] as Map<String, dynamic>)["name"] as String) ==
              _selectedAssignee)
          .toList();
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Due Date':
        filtered.sort((a, b) =>
            (a["dueDate"] as DateTime).compareTo(b["dueDate"] as DateTime));
        break;
      case 'Created Date':
        filtered.sort((a, b) => (b["createdDate"] as DateTime)
            .compareTo(a["createdDate"] as DateTime));
        break;
      case 'Priority':
        final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        filtered.sort((a, b) => (priorityOrder[a["priority"]] ?? 3)
            .compareTo(priorityOrder[b["priority"]] ?? 3));
        break;
      case 'Assignee Name':
        filtered.sort((a, b) =>
            ((a["assignee"] as Map<String, dynamic>)["name"] as String)
                .compareTo(
                    (b["assignee"] as Map<String, dynamic>)["name"] as String));
        break;
    }

    return filtered;
  }

  List<String> get _availableAssignees {
    final assignees = _allSentTasks
        .map((task) =>
            (task["assignee"] as Map<String, dynamic>)["name"] as String)
        .toSet()
        .toList();
    assignees.sort();
    return ['All', ...assignees];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tasks updated'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedFilter: _selectedFilter,
        selectedSort: _selectedSort,
        selectedAssignee: _selectedAssignee,
        availableAssignees: _availableAssignees,
        onFilterChanged: (filter, sort, assignee) {
          setState(() {
            _selectedFilter = filter;
            _selectedSort = sort;
            _selectedAssignee = assignee;
          });
        },
      ),
    );
  }

  void _handleTaskAction(String taskId, String action) {
    final task = _allSentTasks.firstWhere((t) => t["id"] == taskId);

    switch (action) {
      case 'edit':
        Navigator.pushNamed(context, '/task-detail-screen',
            arguments: {'taskId': taskId, 'mode': 'edit'});
        break;
      case 'reminder':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reminder sent to ${(task["assignee"] as Map<String, dynamic>)["name"]}'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'details':
        Navigator.pushNamed(context, '/task-detail-screen',
            arguments: {'taskId': taskId});
        break;
      case 'duplicate':
        Navigator.pushNamed(context, '/create-task-screen',
            arguments: {'duplicateFrom': taskId});
        break;
      case 'delete':
        _showDeleteConfirmation(taskId);
        break;
    }
  }

  void _showDeleteConfirmation(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text(
            'Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _allSentTasks.removeWhere((task) => task["id"] == taskId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.errorLight)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondaryLight,
                    fontSize: 16.sp,
                  ),
                ),
                style: TextStyle(
                  color: AppTheme.textPrimaryLight,
                  fontSize: 16.sp,
                ),
                onChanged: (value) => setState(() {}),
              )
            : Text(
                'Sent Tasks',
                style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
              ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
            icon: CustomIconWidget(
              iconName: _isSearching ? 'close' : 'search',
              color: AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.primaryLight,
              size: 24,
            ),
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? EmptySentTasksWidget(
              onCreateTask: () =>
                  Navigator.pushNamed(context, '/create-task-screen'),
            )
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: AppTheme.primaryLight,
              child: Column(
                children: [
                  // Filter summary
                  if (_selectedFilter != 'All Sent' ||
                      _selectedAssignee != 'All' ||
                      _searchController.text.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      color: AppTheme.primaryLight.withValues(alpha: 0.1),
                      child: Wrap(
                        spacing: 2.w,
                        runSpacing: 0.5.h,
                        children: [
                          if (_selectedFilter != 'All Sent')
                            _buildFilterChip('Status: $_selectedFilter'),
                          if (_selectedAssignee != 'All')
                            _buildFilterChip('Assignee: $_selectedAssignee'),
                          if (_searchController.text.isNotEmpty)
                            _buildFilterChip(
                                'Search: "${_searchController.text}"'),
                        ],
                      ),
                    ),

                  // Task count and sort info
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredTasks.length} task${filteredTasks.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: AppTheme.textSecondaryLight,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Sorted by $_selectedSort',
                          style: TextStyle(
                            color: AppTheme.textSecondaryLight,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Task list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return SentTaskCardWidget(
                          task: task,
                          onTap: () => _handleTaskAction(task["id"], 'details'),
                          onLongPress: () => _showTaskContextMenu(task),
                          onSwipeRight: (action) =>
                              _handleTaskAction(task["id"], action),
                          onSwipeLeft: (action) =>
                              _handleTaskAction(task["id"], action),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-task-screen'),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          'New Task',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () {
              setState(() {
                if (label.startsWith('Status:')) {
                  _selectedFilter = 'All Sent';
                } else if (label.startsWith('Assignee:')) {
                  _selectedAssignee = 'All';
                } else if (label.startsWith('Search:')) {
                  _searchController.clear();
                }
              });
            },
            child: CustomIconWidget(
              iconName: 'close',
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskContextMenu(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.only(top: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task["title"],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  _buildContextMenuItem(
                    icon: 'edit',
                    title: 'Edit Task',
                    onTap: () {
                      Navigator.pop(context);
                      _handleTaskAction(task["id"], 'edit');
                    },
                  ),
                  _buildContextMenuItem(
                    icon: 'content_copy',
                    title: 'Duplicate Task',
                    onTap: () {
                      Navigator.pop(context);
                      _handleTaskAction(task["id"], 'duplicate');
                    },
                  ),
                  _buildContextMenuItem(
                    icon: 'notifications',
                    title: 'Send Reminder',
                    onTap: () {
                      Navigator.pop(context);
                      _handleTaskAction(task["id"], 'reminder');
                    },
                  ),
                  if (task["status"] == 'Pending')
                    _buildContextMenuItem(
                      icon: 'delete',
                      title: 'Delete Task',
                      color: AppTheme.errorLight,
                      onTap: () {
                        Navigator.pop(context);
                        _handleTaskAction(task["id"], 'delete');
                      },
                    ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: color ?? AppTheme.textPrimaryLight,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: color ?? AppTheme.textPrimaryLight,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
