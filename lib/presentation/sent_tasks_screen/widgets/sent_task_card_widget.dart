import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SentTaskCardWidget extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(String) onSwipeRight;
  final Function(String) onSwipeLeft;

  const SentTaskCardWidget({
    super.key,
    required this.task,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipeRight,
    required this.onSwipeLeft,
  });

  @override
  State<SentTaskCardWidget> createState() => _SentTaskCardWidgetState();
}

class _SentTaskCardWidgetState extends State<SentTaskCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSwipeActive = false;
  String _swipeDirection = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.successLight;
      case 'Overdue':
        return AppTheme.errorLight;
      case 'Pending':
      default:
        return AppTheme.primaryLight;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppTheme.errorLight;
      case 'Medium':
        return AppTheme.warningLight;
      case 'Low':
      default:
        return AppTheme.successLight;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else {
      final overdueDays = -difference;
      return overdueDays == 1 ? '1 day overdue' : '$overdueDays days overdue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignee = widget.task["assignee"] as Map<String, dynamic>;
    final status = widget.task["status"] as String;
    final priority = widget.task["priority"] as String;
    final dueDate = widget.task["dueDate"] as DateTime;
    final isOverdue = widget.task["isOverdue"] as bool;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Dismissible(
        key: Key(widget.task["id"]),
        background: _buildSwipeBackground(true),
        secondaryBackground: _buildSwipeBackground(false),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _showSwipeActions(true);
          } else {
            _showSwipeActions(false);
          }
          return false;
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOverdue
                    ? AppTheme.errorLight.withValues(alpha: 0.3)
                    : AppTheme.borderLight,
                width: isOverdue ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with assignee and status
                Row(
                  children: [
                    // Assignee avatar
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _getStatusColor(status),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: CustomImageWidget(
                          imageUrl: assignee["avatar"],
                          width: 10.w,
                          height: 10.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),

                    // Assignee info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assignee["name"],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            assignee["username"],
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(status).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Task title
                Text(
                  widget.task["title"],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 1.h),

                // Task description
                Text(
                  widget.task["description"],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondaryLight,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2.h),

                // Footer with priority and due date
                Row(
                  children: [
                    // Priority indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color:
                            _getPriorityColor(priority).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: priority == 'High'
                                ? 'keyboard_arrow_up'
                                : priority == 'Medium'
                                    ? 'remove'
                                    : 'keyboard_arrow_down',
                            color: _getPriorityColor(priority),
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            priority,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: _getPriorityColor(priority),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Spacer(),

                    // Due date
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: isOverdue
                              ? AppTheme.errorLight
                              : AppTheme.textSecondaryLight,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _formatDueDate(dueDate),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isOverdue
                                ? AppTheme.errorLight
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Completion indicator for completed tasks
                if (status == 'Completed')
                  Container(
                    margin: EdgeInsets.only(top: 1.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.successLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.successLight.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.successLight,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Completed by ${assignee["name"]}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.successLight,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(bool isRightSwipe) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: isRightSwipe ? AppTheme.primaryLight : AppTheme.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isRightSwipe ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isRightSwipe ? 'edit' : 'delete',
                color: Colors.white,
                size: 24,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isRightSwipe ? 'Edit' : 'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSwipeActions(bool isRightSwipe) {
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
                children: isRightSwipe
                    ? [
                        _buildActionItem(
                          icon: 'edit',
                          title: 'Edit Task',
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSwipeRight('edit');
                          },
                        ),
                        _buildActionItem(
                          icon: 'notifications',
                          title: 'Send Reminder',
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSwipeRight('reminder');
                          },
                        ),
                        _buildActionItem(
                          icon: 'visibility',
                          title: 'View Details',
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSwipeRight('details');
                          },
                        ),
                      ]
                    : [
                        if (widget.task["status"] == 'Pending')
                          _buildActionItem(
                            icon: 'delete',
                            title: 'Delete Task',
                            color: AppTheme.errorLight,
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSwipeLeft('delete');
                            },
                          ),
                        _buildActionItem(
                          icon: 'archive',
                          title: 'Archive Task',
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSwipeLeft('archive');
                          },
                        ),
                      ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
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
