import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final String selectedFilter;
  final String selectedSort;
  final String selectedAssignee;
  final List<String> availableAssignees;
  final Function(String filter, String sort, String assignee) onFilterChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.selectedAssignee,
    required this.availableAssignees,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late String _tempFilter;
  late String _tempSort;
  late String _tempAssignee;

  final List<String> _filterOptions = [
    'All Sent',
    'Pending',
    'Completed',
    'Overdue',
  ];

  final List<String> _sortOptions = [
    'Due Date',
    'Created Date',
    'Priority',
    'Assignee Name',
  ];

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.selectedFilter;
    _tempSort = widget.selectedSort;
    _tempAssignee = widget.selectedAssignee;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilter = 'All Sent';
                      _tempSort = 'Due Date';
                      _tempAssignee = 'All';
                    });
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppTheme.borderLight, height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter Section
                  _buildSectionHeader('Status Filter'),
                  SizedBox(height: 2.h),
                  _buildFilterGrid(_filterOptions, _tempFilter, (value) {
                    setState(() {
                      _tempFilter = value;
                    });
                  }),

                  SizedBox(height: 3.h),

                  // Sort Section
                  _buildSectionHeader('Sort By'),
                  SizedBox(height: 2.h),
                  _buildFilterGrid(_sortOptions, _tempSort, (value) {
                    setState(() {
                      _tempSort = value;
                    });
                  }),

                  SizedBox(height: 3.h),

                  // Assignee Filter Section
                  _buildSectionHeader('Filter by Assignee'),
                  SizedBox(height: 2.h),
                  _buildAssigneeFilter(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.borderLight, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      side: BorderSide(color: AppTheme.borderLight),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onFilterChanged(
                          _tempFilter, _tempSort, _tempAssignee);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      backgroundColor: AppTheme.primaryLight,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryLight,
      ),
    );
  }

  Widget _buildFilterGrid(
      List<String> options, String selected, Function(String) onChanged) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryLight
                  : AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected ? AppTheme.primaryLight : AppTheme.borderLight,
                width: 1,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimaryLight,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAssigneeFilter() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: widget.availableAssignees.map((assignee) {
          final isSelected = assignee == _tempAssignee;
          return ListTile(
            leading: assignee == 'All'
                ? CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.textSecondaryLight,
                    size: 20,
                  )
                : Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryLight.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        assignee.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ),
                  ),
            title: Text(
              assignee,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            trailing: isSelected
                ? CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.primaryLight,
                    size: 20,
                  )
                : null,
            onTap: () {
              setState(() {
                _tempAssignee = assignee;
              });
            },
            contentPadding:
                EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
          );
        }).toList(),
      ),
    );
  }
}
