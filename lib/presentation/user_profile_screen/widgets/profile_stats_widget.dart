import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileStatsWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool showConnectionCount;
  final Function(String) onStatTap;

  const ProfileStatsWidget({
    Key? key,
    required this.userData,
    required this.showConnectionCount,
    required this.onStatTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: 'check_circle',
              label: 'Completion',
              value: '${userData["taskCompletionRate"] ?? 0}%',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              onTap: () => onStatTap('completion'),
            ),
          ),
          Container(
            width: 1,
            height: 8.h,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              icon: 'assignment',
              label: 'Active Tasks',
              value: '${userData["activeTasks"] ?? 0}',
              color: AppTheme.lightTheme.colorScheme.primary,
              onTap: () => onStatTap('active'),
            ),
          ),
          Container(
            width: 1,
            height: 8.h,
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: showConnectionCount
                ? _buildStatItem(
                    icon: 'people',
                    label: 'Connections',
                    value: '${userData["connectionCount"] ?? 0}',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    onTap: () => onStatTap('connections'),
                  )
                : _buildPrivateStatItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              value,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateStatItem() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          SizedBox(height: 1.5.h),
          Text(
            '---',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Private',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
