import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskActionsWidget extends StatelessWidget {
  final bool isCurrentUserCreator;
  final String taskStatus;
  final VoidCallback onMarkComplete;
  final VoidCallback onRequestExtension;
  final VoidCallback onSendReminder;
  final VoidCallback onShareTask;

  const TaskActionsWidget({
    super.key,
    required this.isCurrentUserCreator,
    required this.taskStatus,
    required this.onMarkComplete,
    required this.onRequestExtension,
    required this.onSendReminder,
    required this.onShareTask,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Actions',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Action buttons based on user role
          if (isCurrentUserCreator) ...[
            // Creator actions
            _buildActionButton(
              icon: 'send',
              label: 'Send Reminder',
              description: 'Notify assignee about this task',
              color: AppTheme.lightTheme.colorScheme.primary,
              onTap: onSendReminder,
            ),

            SizedBox(height: 2.h),

            if (taskStatus.toLowerCase() != 'completed')
              _buildActionButton(
                icon: 'check_circle',
                label: 'Mark Complete',
                description: 'Override status to completed',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                onTap: onMarkComplete,
              ),
          ] else ...[
            // Assignee actions
            if (taskStatus.toLowerCase() != 'completed')
              _buildActionButton(
                icon: 'check_circle',
                label: 'Mark Complete',
                description: 'Mark this task as completed',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                onTap: onMarkComplete,
              ),

            SizedBox(height: 2.h),

            _buildActionButton(
              icon: 'schedule',
              label: 'Request Extension',
              description: 'Ask for more time to complete',
              color: Colors.orange,
              onTap: onRequestExtension,
            ),
          ],

          SizedBox(height: 2.h),

          // Common actions
          _buildActionButton(
            icon: 'share',
            label: 'Share Task',
            description: 'Share task details externally',
            color: AppTheme.lightTheme.colorScheme.secondary,
            onTap: onShareTask,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
