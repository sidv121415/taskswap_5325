import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_status_widget.dart';
import './widgets/profile_actions_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_stats_widget.dart';
import './widgets/recent_activity_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isOwnProfile = true;
  bool isConnected = false;
  bool hasRequestSent = false;
  bool hasRequestReceived = false;
  bool showActivityFeed = true;
  bool showConnectionCount = true;

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": "user_001",
    "username": "@sarah_johnson",
    "displayName": "Sarah Johnson",
    "bio":
        "Product Manager at TechCorp. Love organizing tasks and helping teams stay productive! 🚀",
    "profilePhoto":
        "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
    "taskCompletionRate": 87,
    "activeTasks": 12,
    "connectionCount": 156,
    "joinedDate": "2023-03-15",
    "isVerified": true,
    "privacySettings": {"hideActivity": false, "hideConnections": false}
  };

  final List<Map<String, dynamic>> recentActivity = [
    {
      "id": "activity_001",
      "type": "task_completed",
      "title": "Completed: Review quarterly reports",
      "description":
          "Successfully finished reviewing Q3 financial reports ahead of deadline",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "priority": "High",
      "isPublic": true
    },
    {
      "id": "activity_002",
      "type": "achievement",
      "title": "Achievement Unlocked: Task Master",
      "description": "Completed 50 tasks this month with 95% on-time delivery",
      "timestamp": DateTime.now().subtract(Duration(hours: 8)),
      "badge": "🏆",
      "isPublic": true
    },
    {
      "id": "activity_003",
      "type": "task_completed",
      "title": "Completed: Team meeting preparation",
      "description": "Prepared agenda and materials for weekly team sync",
      "timestamp": DateTime.now().subtract(Duration(days: 1)),
      "priority": "Medium",
      "isPublic": true
    },
    {
      "id": "activity_004",
      "type": "connection",
      "title": "Connected with Alex Chen",
      "description": "Started collaborating on project management tasks",
      "timestamp": DateTime.now().subtract(Duration(days: 2)),
      "isPublic": true
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileHeaderWidget(
                userData: userData,
                isOwnProfile: isOwnProfile,
                onEditProfile: _handleEditProfile,
                onPhotoTap: _handlePhotoTap,
              ),
              SizedBox(height: 2.h),
              ProfileStatsWidget(
                userData: userData,
                showConnectionCount: showConnectionCount,
                onStatTap: _handleStatTap,
              ),
              SizedBox(height: 2.h),
              if (!isOwnProfile) ...[
                ConnectionStatusWidget(
                  isConnected: isConnected,
                  hasRequestSent: hasRequestSent,
                  hasRequestReceived: hasRequestReceived,
                  onConnectionAction: _handleConnectionAction,
                ),
                SizedBox(height: 2.h),
              ],
              ProfileActionsWidget(
                isOwnProfile: isOwnProfile,
                isConnected: isConnected,
                onEditProfile: _handleEditProfile,
                onSendTask: _handleSendTask,
                onMessage: _handleMessage,
                onSendRequest: _handleSendRequest,
              ),
              SizedBox(height: 3.h),
              if (showActivityFeed || isOwnProfile) ...[
                RecentActivityWidget(
                  activities: recentActivity,
                  isOwnProfile: isOwnProfile,
                  onActivityLongPress: _handleActivityLongPress,
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(4.w),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'lock',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Private Activity',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'This user has chosen to keep their activity private',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Text(
        isOwnProfile ? 'My Profile' : userData["displayName"] ?? 'Profile',
        style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
      ),
      actions: [
        if (!isOwnProfile)
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: CustomIconWidget(
              iconName: 'more_vert',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'block',
                child: Text('Block User'),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Text('Report User'),
              ),
            ],
          ),
        if (isOwnProfile)
          IconButton(
            onPressed: _handleSettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Future<void> _refreshProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        // Simulate data refresh
      });
    }
  }

  void _handleEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditProfileSheet(),
    );
  }

  Widget _buildEditProfileSheet() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  'Edit Profile',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Profile updated successfully')),
                    );
                  },
                  child: Text(
                    'Save',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 15.w,
                        backgroundImage: NetworkImage(userData["profilePhoto"]),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: 'camera_alt',
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  TextFormField(
                    initialValue: userData["displayName"],
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your display name',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    initialValue: userData["username"],
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixText: '@',
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    initialValue: userData["bio"],
                    maxLines: 3,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell others about yourself',
                      alignLabelWithHint: true,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Privacy Settings',
                          style: AppTheme.lightTheme.textTheme.titleSmall,
                        ),
                        SizedBox(height: 2.h),
                        SwitchListTile(
                          title: const Text('Hide Activity Feed'),
                          subtitle: const Text(
                              'Others won\'t see your recent activity'),
                          value: !showActivityFeed,
                          onChanged: (value) {
                            setState(() {
                              showActivityFeed = !value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        SwitchListTile(
                          title: const Text('Hide Connection Count'),
                          subtitle: const Text(
                              'Others won\'t see your connection count'),
                          value: !showConnectionCount,
                          onChanged: (value) {
                            setState(() {
                              showConnectionCount = !value;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePhotoTap() {
    if (isOwnProfile) {
      _showPhotoOptions();
    } else {
      _showFullScreenPhoto();
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera opened')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery opened')),
                );
              },
            ),
            if (userData["profilePhoto"] != null)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Photo removed')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenPhoto() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: CustomImageWidget(
                imageUrl: userData["profilePhoto"],
                width: 90.w,
                height: 90.w,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 2.h,
              right: 2.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStatTap(String statType) {
    switch (statType) {
      case 'completion':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completion details')),
        );
        break;
      case 'active':
        Navigator.pushNamed(context, '/my-tasks-screen');
        break;
      case 'connections':
        if (showConnectionCount) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connections list')),
          );
        }
        break;
    }
  }

  void _handleConnectionAction(String action) {
    setState(() {
      switch (action) {
        case 'connect':
          hasRequestSent = true;
          break;
        case 'accept':
          isConnected = true;
          hasRequestReceived = false;
          break;
        case 'decline':
          hasRequestReceived = false;
          break;
        case 'cancel':
          hasRequestSent = false;
          break;
        case 'disconnect':
          isConnected = false;
          break;
      }
    });

    String message = '';
    switch (action) {
      case 'connect':
        message = 'Connection request sent';
        break;
      case 'accept':
        message = 'Connection request accepted';
        break;
      case 'decline':
        message = 'Connection request declined';
        break;
      case 'cancel':
        message = 'Connection request cancelled';
        break;
      case 'disconnect':
        message = 'Connection removed';
        break;
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _handleSendTask() {
    Navigator.pushNamed(context, '/create-task-screen');
  }

  void _handleMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening message thread')),
    );
  }

  void _handleSendRequest() {
    _handleConnectionAction('connect');
  }

  void _handleActivityLongPress(Map<String, dynamic> activity) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Share Activity'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Activity shared')),
                );
              },
            ),
            if (isOwnProfile)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'visibility_off',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                title: const Text('Hide Activity'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Activity hidden')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'block':
        _showBlockDialog();
        break;
      case 'report':
        _showReportDialog();
        break;
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
            'Are you sure you want to block ${userData["displayName"]}? They won\'t be able to send you tasks or messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('${userData["displayName"]} has been blocked')),
              );
            },
            child: Text(
              'Block',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: Text(
            'Report ${userData["displayName"]} for inappropriate behavior?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted')),
              );
            },
            child: Text(
              'Report',
              style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening settings')),
    );
  }
}
