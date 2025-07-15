import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';
import './widgets/task_card_widget.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({Key? key}) : super(key: key);

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _selectedFilter = 'All';
  String _selectedSort = 'Due Date';
  String _searchQuery = '';
  bool _isLoading = false;

  // Mock data for tasks assigned to current user
  final List<Map<String, dynamic>> _myTasks = [
    {
      "id": 1,
      "title": "Review quarterly budget report",
      "description":
          "Analyze Q3 financial performance and prepare recommendations for Q4 budget allocation",
      "priority": "High",
      "status": "Pending",
      "dueDate": DateTime.now().add(Duration(days: 2)),
      "createdDate": DateTime.now().subtract(Duration(days: 5)),
      "assignerName": "Sarah Johnson",
      "assignerAvatar":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isOverdue": false,
    },
    {
      "id": 2,
      "title": "Update project documentation",
      "description":
          "Revise API documentation and user guides for the new feature release",
      "priority": "Medium",
      "status": "Pending",
      "dueDate": DateTime.now().add(Duration(days: 7)),
      "createdDate": DateTime.now().subtract(Duration(days: 3)),
      "assignerName": "Michael Chen",
      "assignerAvatar":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isOverdue": false,
    },
    {
      "id": 3,
      "title": "Prepare presentation slides",
      "description":
          "Create slides for the upcoming client meeting on project milestones",
      "priority": "High",
      "status": "Overdue",
      "dueDate": DateTime.now().subtract(Duration(days: 1)),
      "createdDate": DateTime.now().subtract(Duration(days: 8)),
      "assignerName": "Emily Rodriguez",
      "assignerAvatar":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isOverdue": true,
    },
    {
      "id": 4,
      "title": "Code review for mobile app",
      "description":
          "Review pull requests and provide feedback on the new authentication module",
      "priority": "Medium",
      "status": "Completed",
      "dueDate": DateTime.now().subtract(Duration(days: 2)),
      "createdDate": DateTime.now().subtract(Duration(days: 10)),
      "assignerName": "David Kim",
      "assignerAvatar":
          "https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isOverdue": false,
    },
    {
      "id": 5,
      "title": "Database optimization",
      "description":
          "Optimize database queries and improve application performance",
      "priority": "Low",
      "status": "Pending",
      "dueDate": DateTime.now().add(Duration(days: 14)),
      "createdDate": DateTime.now().subtract(Duration(days: 1)),
      "assignerName": "Lisa Wang",
      "assignerAvatar":
          "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isOverdue": false,
    },
  ];

  // Mock data for tasks sent by current user
  final List<Map<String, dynamic>> _sentTasks = [
    {
      "id": 6,
      "title": "Design system updates",
      "description":
          "Update design tokens and component library for consistency",
      "priority": "Medium",
      "status": "Pending",
      "dueDate": DateTime.now().add(Duration(days: 5)),
      "createdDate": DateTime.now().subtract(Duration(days: 2)),
      "assigneeName": "Alex Thompson",
      "assigneeAvatar":
          "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isOverdue": false,
    },
    {
      "id": 7,
      "title": "User testing session",
      "description":
          "Conduct usability testing for the new dashboard interface",
      "priority": "High",
      "status": "Completed",
      "dueDate": DateTime.now().subtract(Duration(days: 3)),
      "createdDate": DateTime.now().subtract(Duration(days: 7)),
      "assigneeName": "Rachel Green",
      "assigneeAvatar":
          "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400",
      "isOverdue": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTasks {
    List<Map<String, dynamic>> tasks =
        _tabController.index == 0 ? _myTasks : _sentTasks;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) {
        final title = (task['title'] as String).toLowerCase();
        final description = (task['description'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'All') {
      tasks = tasks.where((task) {
        if (_selectedFilter == 'Overdue') {
          return task['isOverdue'] == true;
        }
        return task['status'] == _selectedFilter;
      }).toList();
    }

    // Apply sorting
    tasks.sort((a, b) {
      switch (_selectedSort) {
        case 'Due Date':
          return (a['dueDate'] as DateTime).compareTo(b['dueDate'] as DateTime);
        case 'Priority':
          final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
          return priorityOrder[a['priority']]!
              .compareTo(priorityOrder[b['priority']]!);
        case 'Created Date':
          return (b['createdDate'] as DateTime)
              .compareTo(a['createdDate'] as DateTime);
        case 'Alphabetical':
          return (a['title'] as String).compareTo(b['title'] as String);
        default:
          return 0;
      }
    });

    return tasks;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        selectedSort: _selectedSort,
        onSortChanged: (sort) {
          setState(() {
            _selectedSort = sort;
          });
        },
      ),
    );
  }

  void _onTaskTap(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/task-detail-screen', arguments: task);
  }

  void _onTaskAction(Map<String, dynamic> task, String action) {
    switch (action) {
      case 'complete':
        setState(() {
          task['status'] = 'Completed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task marked as completed')),
        );
        break;
      case 'reminder':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder set for task')),
        );
        break;
      case 'archive':
        setState(() {
          if (_tabController.index == 0) {
            _myTasks.remove(task);
          } else {
            _sentTasks.remove(task);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task archived')),
        );
        break;
      case 'delete':
        setState(() {
          if (_tabController.index == 0) {
            _myTasks.remove(task);
          } else {
            _sentTasks.remove(task);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Container(
            color: AppTheme.lightTheme.appBarTheme.backgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'My Tasks'),
                Tab(text: 'Sent Tasks'),
              ],
              labelColor: AppTheme.lightTheme.primaryColor,
              unselectedLabelColor:
                  AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              indicatorColor: AppTheme.lightTheme.primaryColor,
              indicatorWeight: 2,
              labelStyle: AppTheme.lightTheme.textTheme.labelLarge,
              unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Header
          Container(
            padding: EdgeInsets.all(4.w),
            color: AppTheme.lightTheme.colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: CustomIconWidget(
                          iconName: 'search',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                      ),
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                GestureDetector(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    height: 6.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'filter_list',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: _showSortBottomSheet,
                  child: Container(
                    height: 6.h,
                    width: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 1,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'sort',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Task List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(),
                _buildTaskList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-task-screen');
        },
        backgroundColor: AppTheme.lightTheme.primaryColor,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final filteredTasks = _filteredTasks;

    if (filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _onRefresh,
      color: AppTheme.lightTheme.primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return TaskCardWidget(
            task: task,
            isMyTask: _tabController.index == 0,
            onTap: () => _onTaskTap(task),
            onAction: (action) => _onTaskAction(task, action),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'assignment',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 3.h),
          Text(
            _tabController.index == 0
                ? 'No tasks assigned to you'
                : 'No tasks sent by you',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _tabController.index == 0
                ? 'Tasks assigned to you will appear here'
                : 'Tasks you assign to others will appear here',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home-dashboard');
            },
            child: Text(_tabController.index == 0
                ? 'Browse Connections'
                : 'Create Task'),
          ),
        ],
      ),
    );
  }
}
