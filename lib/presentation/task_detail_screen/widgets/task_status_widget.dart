import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskStatusWidget extends StatelessWidget {
  final String status;
  final bool isCurrentUserCreator;
  final Function(String) onStatusChanged;

  const TaskStatusWidget({
    super.key,
    required this.status,
    required this.isCurrentUserCreator,
    required this.onStatusChanged,
  });

  Map<String, dynamic> _getStatusInfo() {
    switch (status.toLowerCase()) {
      case 'pending':
        return {
          'color': Colors.orange,
          'icon': 'schedule',
          'description': 'Task is waiting to be started',
        };
      case 'in progress':
        return {
          'color': AppTheme.lightTheme.colorScheme.primary,
          'icon': 'play_circle_outline',
          'description': 'Task is currently being worked on',
        };
      case 'completed':
        return {
          'color': AppTheme.lightTheme.colorScheme.tertiary,
          'icon': 'check_circle',
          'description': 'Task has been successfully completed',
        };
      case 'overdue':
        return {
          'color': AppTheme.lightTheme.colorScheme.error,
          'icon': 'warning',
          'description': 'Task is past its due date',
        };
      default:
        return {
          'color': AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          'icon': 'help_outline',
          'description': 'Status not specified',
        };
    }
  }

  void _showStatusChangeDialog(BuildContext context) {
    final statusOptions = ['Pending', 'In Progress', 'Completed'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusOptions.map((statusOption) {
            final isSelected =
                statusOption.toLowerCase() == status.toLowerCase();
            return ListTile(
              leading: CustomIconWidget(
                iconName: isSelected
                    ? 'radio_button_checked'
                    : 'radio_button_unchecked',
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              title: Text(statusOption),
              onTap: () {
                Navigator.pop(context);
                if (!isSelected) {
                  onStatusChanged(statusOption);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

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
                iconName: 'assignment',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),

              SizedBox(width: 2.w),

              Text(
                'Status',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),

              const Spacer(),

              // Change status button (for creators)
              if (isCurrentUserCreator)
                GestureDetector(
                  onTap: () => _showStatusChangeDialog(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'edit',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Change',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Status info
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: statusInfo['icon'],
                  color: statusInfo['color'],
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusInfo['color'],
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      statusInfo['description'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Completion toggle for assignees
          if (!isCurrentUserCreator && status.toLowerCase() != 'completed') ...[
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: () => onStatusChanged('Completed'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.tertiary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle_outline',
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Mark as Complete',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
