import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskPriorityWidget extends StatelessWidget {
  final String priority;

  const TaskPriorityWidget({
    super.key,
    required this.priority,
  });

  Map<String, dynamic> _getPriorityInfo() {
    switch (priority.toLowerCase()) {
      case 'high':
        return {
          'color': AppTheme.lightTheme.colorScheme.error,
          'icon': 'priority_high',
          'description':
              'Requires immediate attention and should be completed first',
        };
      case 'medium':
        return {
          'color': Colors.orange,
          'icon': 'remove',
          'description': 'Important task that should be completed soon',
        };
      case 'low':
        return {
          'color': AppTheme.lightTheme.colorScheme.tertiary,
          'icon': 'keyboard_arrow_down',
          'description': 'Can be completed when time permits',
        };
      default:
        return {
          'color': AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          'icon': 'help_outline',
          'description': 'Priority level not specified',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityInfo = _getPriorityInfo();

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
                iconName: 'flag',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Priority',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Priority level
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: priorityInfo['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: priorityInfo['icon'],
                  color: priorityInfo['color'],
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$priority Priority',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: priorityInfo['color'],
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      priorityInfo['description'],
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

          SizedBox(height: 2.h),

          // Priority indicator bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: priority.toLowerCase() == 'low' ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: priority.toLowerCase() == 'low'
                          ? priorityInfo['color']
                          : Colors.transparent,
                    ),
                  ),
                ),
                Expanded(
                  flex: priority.toLowerCase() == 'medium' ? 2 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: priority.toLowerCase() == 'medium'
                          ? priorityInfo['color']
                          : Colors.transparent,
                    ),
                  ),
                ),
                Expanded(
                  flex: priority.toLowerCase() == 'high' ? 3 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: priority.toLowerCase() == 'high'
                          ? priorityInfo['color']
                          : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
