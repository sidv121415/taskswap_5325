import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late String _selectedFilter;

  final List<Map<String, dynamic>> _filterOptions = [
    {
      'label': 'All',
      'icon': 'list',
      'description': 'Show all tasks',
    },
    {
      'label': 'Pending',
      'icon': 'schedule',
      'description': 'Tasks in progress',
    },
    {
      'label': 'Completed',
      'icon': 'check_circle',
      'description': 'Finished tasks',
    },
    {
      'label': 'Overdue',
      'icon': 'warning',
      'description': 'Past due date',
    },
  ];

  final List<Map<String, dynamic>> _priorityOptions = [
    {
      'label': 'High Priority',
      'icon': 'priority_high',
      'color': AppTheme.errorLight,
    },
    {
      'label': 'Medium Priority',
      'icon': 'remove',
      'color': AppTheme.warningLight,
    },
    {
      'label': 'Low Priority',
      'icon': 'keyboard_arrow_down',
      'color': AppTheme.lightTheme.colorScheme.onSurfaceVariant,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                Text(
                  'Filter Tasks',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'All';
                    });
                  },
                  child: Text('Clear All'),
                ),
              ],
            ),
          ),

          Divider(
            color: AppTheme.lightTheme.colorScheme.outline,
            height: 1,
          ),

          // Status Filters
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                ...(_filterOptions.map((option) => _buildFilterOption(option))),
                SizedBox(height: 3.h),
                Text(
                  'Priority',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                ...(_priorityOptions
                    .map((option) => _buildPriorityOption(option))),
              ],
            ),
          ),

          // Apply Button
          Padding(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onFilterChanged(_selectedFilter);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text('Apply Filter'),
              ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFilterOption(Map<String, dynamic> option) {
    final isSelected = _selectedFilter == option['label'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = option['label'] as String;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: option['icon'] as String,
              color: isSelected
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['label'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.lightTheme.primaryColor
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    option['description'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(Map<String, dynamic> option) {
    final isSelected = _selectedFilter == option['label'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = option['label'] as String;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 1.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: option['icon'] as String,
              color: option['color'] as Color,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                option['label'] as String,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
