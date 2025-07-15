import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PriorityPickerWidget extends StatelessWidget {
  final String selectedPriority;
  final Function(String) onPriorityChanged;

  const PriorityPickerWidget({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'Medium':
        return AppTheme.warningLight;
      case 'High':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'Low':
        return Icons.keyboard_arrow_down;
      case 'Medium':
        return Icons.remove;
      case 'High':
        return Icons.keyboard_arrow_up;
      default:
        return Icons.remove;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorities = ['Low', 'Medium', 'High'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: priorities.map((priority) {
              final isSelected = selectedPriority == priority;
              final priorityColor = _getPriorityColor(priority);
              final isFirst = priority == priorities.first;
              final isLast = priority == priorities.last;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onPriorityChanged(priority),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? priorityColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.horizontal(
                        left: isFirst ? const Radius.circular(12) : Radius.zero,
                        right: isLast ? const Radius.circular(12) : Radius.zero,
                      ),
                      border: isSelected
                          ? Border.all(color: priorityColor, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName:
                              _getPriorityIcon(priority).codePoint.toString(),
                          color: isSelected
                              ? priorityColor
                              : AppTheme.lightTheme.colorScheme.secondary,
                          size: 6.w,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          priority,
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: isSelected
                                ? priorityColor
                                : AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 1.h),

        // Priority description
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: _getPriorityColor(selectedPriority).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getPriorityColor(selectedPriority).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: _getPriorityColor(selectedPriority),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _getPriorityDescription(selectedPriority),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _getPriorityColor(selectedPriority),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getPriorityDescription(String priority) {
    switch (priority) {
      case 'Low':
        return 'Task can be completed when convenient. No immediate deadline pressure.';
      case 'Medium':
        return 'Task should be completed within reasonable timeframe. Moderate importance.';
      case 'High':
        return 'Task requires immediate attention. High importance and urgency.';
      default:
        return '';
    }
  }
}
