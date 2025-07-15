import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AssigneeSelectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> connections;
  final String? selectedAssigneeId;
  final Function(String id, String name) onAssigneeSelected;

  const AssigneeSelectionWidget({
    Key? key,
    required this.connections,
    required this.selectedAssigneeId,
    required this.onAssigneeSelected,
  }) : super(key: key);

  @override
  State<AssigneeSelectionWidget> createState() =>
      _AssigneeSelectionWidgetState();
}

class _AssigneeSelectionWidgetState extends State<AssigneeSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredConnections = [];

  @override
  void initState() {
    super.initState();
    _filteredConnections = List.from(widget.connections);
    _searchController.addListener(_filterConnections);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterConnections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConnections = widget.connections.where((connection) {
        final name = (connection['name'] as String).toLowerCase();
        final username = (connection['username'] as String).toLowerCase();
        return name.contains(query) || username.contains(query);
      }).toList();
    });
  }

  void _showAssigneeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
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
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    Text(
                      'Select Assignee',
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

              // Search field
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search connections...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 5.w,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              size: 5.w,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              // Connections list
              Expanded(
                child: _filteredConnections.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: _filteredConnections.length,
                        itemBuilder: (context, index) {
                          final connection = _filteredConnections[index];
                          return _buildConnectionTile(connection);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No connections found',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your search terms',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTile(Map<String, dynamic> connection) {
    final isSelected = widget.selectedAssigneeId == connection['id'];
    final isOnline = connection['isOnline'] as bool;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: CustomImageWidget(
                imageUrl: connection['avatar'] as String,
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 3.w,
                  height: 3.w,
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          connection['name'] as String,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              connection['username'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              connection['lastActive'] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isOnline
                    ? AppTheme.successLight
                    : AppTheme.lightTheme.colorScheme.secondary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              )
            : null,
        onTap: () {
          widget.onAssigneeSelected(
            connection['id'] as String,
            connection['name'] as String,
          );
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedConnection = widget.connections.firstWhere(
      (conn) => conn['id'] == widget.selectedAssigneeId,
      orElse: () => <String, dynamic>{},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assign To *',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _showAssigneeBottomSheet,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: AppTheme.lightTheme.colorScheme.surface,
            ),
            child: selectedConnection.isNotEmpty
                ? Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomImageWidget(
                          imageUrl: selectedConnection['avatar'] as String,
                          width: 10.w,
                          height: 10.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedConnection['name'] as String,
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              selectedConnection['username'] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 6.w,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person_add',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Select assignee from connections',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 6.w,
                      ),
                    ],
                  ),
          ),
        ),
        if (widget.selectedAssigneeId == null)
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Text(
              'Please select an assignee',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorLight,
              ),
            ),
          ),
      ],
    );
  }
}
