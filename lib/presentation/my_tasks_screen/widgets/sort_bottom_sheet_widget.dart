import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatefulWidget {
  final String selectedSort;
  final Function(String) onSortChanged;

  const SortBottomSheetWidget({
    Key? key,
    required this.selectedSort,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  State<SortBottomSheetWidget> createState() => _SortBottomSheetWidgetState();
}

class _SortBottomSheetWidgetState extends State<SortBottomSheetWidget> {
  late String _selectedSort;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'label': 'Due Date',
      'icon': 'schedule',
      'description': 'Sort by due date (earliest first)',
    },
    {
      'label': 'Priority',
      'icon': 'priority_high',
      'description': 'Sort by priority (high to low)',
    },
    {
      'label': 'Created Date',
      'icon': 'calendar_today',
      'description': 'Sort by creation date (newest first)',
    },
    {
      'label': 'Alphabetical',
      'icon': 'sort_by_alpha',
      'description': 'Sort by task title (A to Z)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.selectedSort;
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
                  'Sort Tasks',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ),

          Divider(
            color: AppTheme.lightTheme.colorScheme.outline,
            height: 1,
          ),

          // Sort Options
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                ...(_sortOptions.map((option) => _buildSortOption(option))),
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
                  widget.onSortChanged(_selectedSort);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text('Apply Sort'),
              ),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildSortOption(Map<String, dynamic> option) {
    final isSelected = _selectedSort == option['label'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = option['label'] as String;
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
}
