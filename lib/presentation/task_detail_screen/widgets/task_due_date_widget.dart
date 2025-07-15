import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskDueDateWidget extends StatelessWidget {
  final String dueDate;

  const TaskDueDateWidget({
    super.key,
    required this.dueDate,
  });

  Map<String, dynamic> _getDueDateInfo() {
    final due = DateTime.parse(dueDate);
    final now = DateTime.now();
    final difference = due.difference(now);

    String formattedDate = '${due.day}/${due.month}/${due.year}';
    String timeLeft = '';
    Color urgencyColor = AppTheme.lightTheme.colorScheme.tertiary;

    if (difference.isNegative) {
      timeLeft = 'Overdue';
      urgencyColor = AppTheme.lightTheme.colorScheme.error;
    } else if (difference.inDays == 0) {
      timeLeft = 'Due today';
      urgencyColor = AppTheme.lightTheme.colorScheme.error;
    } else if (difference.inDays == 1) {
      timeLeft = 'Due tomorrow';
      urgencyColor = Colors.orange;
    } else if (difference.inDays <= 3) {
      timeLeft = 'Due in ${difference.inDays} days';
      urgencyColor = Colors.orange;
    } else if (difference.inDays <= 7) {
      timeLeft = 'Due in ${difference.inDays} days';
      urgencyColor = AppTheme.lightTheme.colorScheme.tertiary;
    } else {
      timeLeft = 'Due in ${difference.inDays} days';
      urgencyColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }

    return {
      'formattedDate': formattedDate,
      'timeLeft': timeLeft,
      'urgencyColor': urgencyColor,
      'isOverdue': difference.isNegative,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dueDateInfo = _getDueDateInfo();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dueDateInfo['isOverdue']
              ? AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3)
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              CustomIconWidget(
                iconName: 'event',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Due Date',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Due date info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dueDateInfo['formattedDate'],
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color:
                            dueDateInfo['urgencyColor'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: dueDateInfo['isOverdue']
                                ? 'warning'
                                : 'schedule',
                            color: dueDateInfo['urgencyColor'],
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            dueDateInfo['timeLeft'],
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: dueDateInfo['urgencyColor'],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar icon
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: dueDateInfo['urgencyColor'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: dueDateInfo['urgencyColor'],
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
