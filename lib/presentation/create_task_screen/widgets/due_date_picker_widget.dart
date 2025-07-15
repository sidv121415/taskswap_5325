import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DueDatePickerWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const DueDatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        selectedDate ?? now.add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now)
          ? now.add(const Duration(days: 1))
          : initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              headerBackgroundColor: AppTheme.lightTheme.colorScheme.primary,
              headerForegroundColor: Colors.white,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppTheme.lightTheme.colorScheme.onSurface;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTheme.lightTheme.colorScheme.primary;
                }
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.all(
                AppTheme.lightTheme.colorScheme.primary,
              ),
              todayBackgroundColor: WidgetStateProperty.all(
                Colors.transparent,
              ),
              todayBorder: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dayShape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final dayAfterTomorrow = now.add(const Duration(days: 2));

    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, tomorrow)) {
      return 'Tomorrow';
    } else if (_isSameDay(date, dayAfterTomorrow)) {
      return 'Day after tomorrow';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Color _getDateColor() {
    if (selectedDate == null) return AppTheme.lightTheme.colorScheme.secondary;

    final now = DateTime.now();
    final daysUntilDue = selectedDate!.difference(now).inDays;

    if (daysUntilDue <= 1) {
      return AppTheme.errorLight;
    } else if (daysUntilDue <= 3) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }

  String _getDateUrgency() {
    if (selectedDate == null) return '';

    final now = DateTime.now();
    final daysUntilDue = selectedDate!.difference(now).inDays;

    if (daysUntilDue == 0) {
      return 'Due today';
    } else if (daysUntilDue == 1) {
      return 'Due tomorrow';
    } else if (daysUntilDue <= 3) {
      return 'Due soon';
    } else if (daysUntilDue <= 7) {
      return 'Due this week';
    } else {
      return 'Due in $daysUntilDue days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedDate != null
                    ? _getDateColor()
                    : AppTheme.lightTheme.colorScheme.outline,
                width: selectedDate != null ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: selectedDate != null
                  ? _getDateColor().withValues(alpha: 0.05)
                  : AppTheme.lightTheme.colorScheme.surface,
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'calendar_today',
                  color: selectedDate != null
                      ? _getDateColor()
                      : AppTheme.lightTheme.colorScheme.secondary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDate != null
                            ? _formatDate(selectedDate!)
                            : 'Select due date',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: selectedDate != null
                              ? _getDateColor()
                              : AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: selectedDate != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      if (selectedDate != null) ...[
                        SizedBox(height: 0.5.h),
                        Text(
                          _getDateUrgency(),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: _getDateColor(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: selectedDate != null
                      ? _getDateColor()
                      : AppTheme.lightTheme.colorScheme.secondary,
                  size: 6.w,
                ),
              ],
            ),
          ),
        ),
        if (selectedDate == null)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Text(
              'Please select a due date',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorLight,
              ),
            ),
          ),
        if (selectedDate != null)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _getDateColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getDateColor().withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: _getDateColor(),
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Task will be marked as overdue if not completed by this date',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getDateColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
