import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/recent_activity_item_widget.dart';
import './widgets/task_summary_card_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with TickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int _selectedIndex = 0;
  bool _isRefreshing = false;
  int _notificationCount = 3;

  // Mock data for task summary
  final List<Map<String, dynamic>> taskSummaryData = [
    {
      "title": "Tasks Due Today",
      "count": 5,
      "color": AppTheme.errorLight,
      "icon": "today",
      "route": "/my-tasks-screen"
    },
    {
      "title": "Pending Tasks",
      "count": 12,
      "color": AppTheme.warningLight,
      "icon": "pending_actions",
      "route": "/my-tasks-screen"
    },
    {
      "title": "Completed This Week",
      "count": 8,
      "color": AppTheme.successLight,
      "icon": "check_circle",
      "route": "/my-tasks-screen"
    },
  ];

  // Mock data for recent activity
  final List<Map<String, dynamic>> recentActivityData = [
    {
      "id": 1,
      "type": "task_assigned",
      "title": "Review project proposal",
      "description": "Sarah assigned you a new task",
      "userAvatar":
          "https://images.unsplash.com/photo-1494790108755-2616b9e0b8e0?w=150&h=150&fit=crop&crop=face",
      "userName": "Sarah Johnson",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "priority": "High",
      "isCompleted": false
    },
    {
      "id": 2,
      "type": "task_completed",
      "title": "Update user documentation",
      "description": "You completed this task",
      "userAvatar":
          "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face",
      "userName": "You",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "priority": "Medium",
      "isCompleted": true
    },
    {
      "id": 3,
      "type": "connection_request",
      "title": "Connection Request",
      "description": "Mike wants to connect with you",
      "userAvatar":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
      "userName": "Mike Chen",
      "timestamp": DateTime.now().subtract(Duration(hours: 4)),
      "priority": "Low",
      "isCompleted": false
    },
    {
      "id": 4,
      "type": "task_assigned",
      "title": "Prepare presentation slides",
      "description": "Alex assigned you a new task",
      "userAvatar":
          "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face",
      "userName": "Alex Rivera",
      "timestamp": DateTime.now().subtract(Duration(hours: 6)),
      "priority": "High",
      "isCompleted": false
    },
    {
      "id": 5,
      "type": "task_completed",
      "title": "Code review for mobile app",
      "description": "Jessica completed this task",
      "userAvatar":
          "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=face",
      "userName": "Jessica Wong",
      "timestamp": DateTime.now().subtract(Duration(hours: 8)),
      "priority": "Medium",
      "isCompleted": true
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(),
            Expanded(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _handleRefresh,
                color: AppTheme.lightTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),
                      _buildTaskSummarySection(),
                      SizedBox(height: 3.h),
                      _buildQuickActions(),
                      SizedBox(height: 3.h),
                      _buildRecentActivitySection(),
                      SizedBox(height: 10.h), // Bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildStickyHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: AppTheme.lightShadow,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/user-profile-screen'),
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightTheme.primaryColor,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl:
                      "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&h=150&fit=crop&crop=face",
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good morning!",
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  "John Doe",
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle notification tap
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  CustomIconWidget(
                    iconName: 'notifications',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 6.w,
                  ),
                  _notificationCount > 0
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: AppTheme.errorLight,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 4.w,
                              minHeight: 4.w,
                            ),
                            child: Text(
                              _notificationCount.toString(),
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            "Task Overview",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 20.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: taskSummaryData.length,
            itemBuilder: (context, index) {
              final task = taskSummaryData[index];
              return Padding(
                padding: EdgeInsets.only(right: 3.w),
                child: TaskSummaryCardWidget(
                  title: task["title"] as String,
                  count: task["count"] as int,
                  color: task["color"] as Color,
                  iconName: task["icon"] as String,
                  onTap: () =>
                      Navigator.pushNamed(context, task["route"] as String),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activity",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle view all
                },
                child: Text(
                  "View All",
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        recentActivityData.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentActivityData.length,
                itemBuilder: (context, index) {
                  final activity = recentActivityData[index];
                  return RecentActivityItemWidget(
                    id: activity["id"] as int,
                    type: activity["type"] as String,
                    title: activity["title"] as String,
                    description: activity["description"] as String,
                    userAvatar: activity["userAvatar"] as String,
                    userName: activity["userName"] as String,
                    timestamp: activity["timestamp"] as DateTime,
                    priority: activity["priority"] as String,
                    isCompleted: activity["isCompleted"] as bool,
                    onTap: () =>
                        Navigator.pushNamed(context, '/task-detail-screen'),
                    onMarkComplete: () =>
                        _handleMarkComplete(activity["id"] as int),
                    onViewDetails: () =>
                        Navigator.pushNamed(context, '/task-detail-screen'),
                    onReply: () => _handleReply(activity["id"] as int),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'task_alt',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20.w,
          ),
          SizedBox(height: 2.h),
          Text(
            "No recent activity",
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Create your first task or connect with friends to get started",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/create-task-screen'),
            child: Text("Create Your First Task"),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      selectedItemColor: AppTheme.lightTheme.primaryColor,
      unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'home',
            color: _selectedIndex == 0
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'assignment',
            color: _selectedIndex == 1
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          label: 'My Tasks',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'send',
            color: _selectedIndex == 2
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          label: 'Sent',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _selectedIndex == 3
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 6.w,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, '/create-task-screen'),
      backgroundColor: AppTheme.lightTheme.primaryColor,
      foregroundColor: Colors.white,
      icon: CustomIconWidget(
        iconName: 'add',
        color: Colors.white,
        size: 6.w,
      ),
      label: Text(
        "New Task",
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/my-tasks-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/sent-tasks-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile-screen');
        break;
    }
  }

  void _handleMarkComplete(int taskId) {
    setState(() {
      final taskIndex =
          recentActivityData.indexWhere((task) => task["id"] == taskId);
      if (taskIndex != -1) {
        recentActivityData[taskIndex]["isCompleted"] = true;
      }
    });
  }

  void _handleReply(int taskId) {
    // Handle reply functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Reply to Task"),
        content: Text("Reply functionality would be implemented here."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }
}
