import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReminderSettingsWidget extends StatelessWidget {
  final bool reminderEnabled;
  final int reminderHours;
  final Function(bool) onReminderToggled;
  final Function(int) onReminderHoursChanged;

  const ReminderSettingsWidget({
    Key? key,
    required this.reminderEnabled,
    required this.reminderHours,
    required this.onReminderToggled,
    required this.onReminderHoursChanged,
  }) : super(key: key);

  void _showReminderOptions(BuildContext context) {
    final reminderOptions = [
      {'hours': 1, 'label': '1 hour before'},
      {'hours': 2, 'label': '2 hours before'},
      {'hours': 4, 'label': '4 hours before'},
      {'hours': 8, 'label': '8 hours before'},
      {'hours': 24, 'label': '1 day before'},
      {'hours': 48, 'label': '2 days before'},
      {'hours': 168, 'label': '1 week before'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  Text(
                    'Reminder Time',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),

            // Options list
            ...reminderOptions.map((option) {
              final hours = option['hours'] as int;
              final label = option['label'] as String;
              final isSelected = reminderHours == hours;

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                leading: CustomIconWidget(
                  iconName: 'notifications',
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.secondary,
                  size: 6.w,
                ),
                title: Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? CustomIconWidget(
                        iconName: 'check_circle',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      )
                    : null,
                onTap: () {
                  onReminderHoursChanged(hours);
                  Navigator.pop(context);
                },
              );
            }).toList(),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getReminderLabel(int hours) {
    if (hours == 1) return '1 hour before';
    if (hours == 2) return '2 hours before';
    if (hours == 4) return '4 hours before';
    if (hours == 8) return '8 hours before';
    if (hours == 24) return '1 day before';
    if (hours == 48) return '2 days before';
    if (hours == 168) return '1 week before';
    return '$hours hours before';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Settings',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),

        // Reminder toggle
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: AppTheme.lightTheme.colorScheme.surface,
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: reminderEnabled
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Reminder',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Get notified before the due date',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminderEnabled,
                onChanged: onReminderToggled,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),
        ),

        // Reminder time selection (only shown when enabled)
        if (reminderEnabled) ...[
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () => _showReminderOptions(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder Time',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ),
                        Text(
                          _getReminderLabel(reminderHours),
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Reminder info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'You\'ll receive a push notification ${_getReminderLabel(reminderHours)} the due date',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
