import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecentActivityItemWidget extends StatelessWidget {
  final int id;
  final String type;
  final String title;
  final String description;
  final String userAvatar;
  final String userName;
  final DateTime timestamp;
  final String priority;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onMarkComplete;
  final VoidCallback onViewDetails;
  final VoidCallback onReply;

  const RecentActivityItemWidget({
    Key? key,
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.userAvatar,
    required this.userName,
    required this.timestamp,
    required this.priority,
    required this.isCompleted,
    required this.onTap,
    required this.onMarkComplete,
    required this.onViewDetails,
    required this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.startToEnd,
      background: _buildSwipeBackground(),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onMarkComplete();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.lightShadow,
          ),
          child: Row(
            children: [
              _buildUserAvatar(),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildPriorityBadge(),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _buildTypeIcon(),
                        SizedBox(width: 2.w),
                        Text(
                          _formatTimestamp(timestamp),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                        const Spacer(),
                        if (isCompleted)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.successLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Completed",
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.successLight,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _getTypeColor().withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: CustomImageWidget(
          imageUrl: userAvatar,
          width: 12.w,
          height: 12.w,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = AppTheme.errorLight;
        break;
      case 'medium':
        priorityColor = AppTheme.warningLight;
        break;
      case 'low':
        priorityColor = AppTheme.successLight;
        break;
      default:
        priorityColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: priorityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: priorityColor,
          fontWeight: FontWeight.w500,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: CustomIconWidget(
        iconName: _getTypeIconName(),
        color: _getTypeColor(),
        size: 3.w,
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      color: AppTheme.successLight,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          Text(
            "Mark Complete",
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case 'task_assigned':
        return AppTheme.lightTheme.primaryColor;
      case 'task_completed':
        return AppTheme.successLight;
      case 'connection_request':
        return AppTheme.warningLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _getTypeIconName() {
    switch (type) {
      case 'task_assigned':
        return 'assignment';
      case 'task_completed':
        return 'check_circle';
      case 'connection_request':
        return 'person_add';
      default:
        return 'info';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
              title: Text("View Details"),
              onTap: () {
                Navigator.pop(context);
                onViewDetails();
              },
            ),
            if (!isCompleted)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successLight,
                  size: 6.w,
                ),
                title: Text("Mark Complete"),
                onTap: () {
                  Navigator.pop(context);
                  onMarkComplete();
                },
              ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'reply',
                color: AppTheme.warningLight,
                size: 6.w,
              ),
              title: Text("Reply"),
              onTap: () {
                Navigator.pop(context);
                onReply();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'archive',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              title: Text("Archive"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications_off',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 6.w,
              ),
              title: Text("Mute Notifications"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
