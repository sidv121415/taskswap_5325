import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskDescriptionWidget extends StatefulWidget {
  final String description;

  const TaskDescriptionWidget({
    super.key,
    required this.description,
  });

  @override
  State<TaskDescriptionWidget> createState() => _TaskDescriptionWidgetState();
}

class _TaskDescriptionWidgetState extends State<TaskDescriptionWidget> {
  bool _isExpanded = false;
  final int _maxLines = 3;

  bool get _shouldShowReadMore => widget.description.length > 150;

  @override
  Widget build(BuildContext context) {
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
                iconName: 'description',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Description',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Description text
          AnimatedCrossFade(
            firstChild: Text(
              widget.description,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.description,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),

          // Read more/less button
          if (_shouldShowReadMore) ...[
            SizedBox(height: 2.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded ? 'Read Less' : 'Read More',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
