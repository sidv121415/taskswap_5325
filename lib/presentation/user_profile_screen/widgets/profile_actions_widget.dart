import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileActionsWidget extends StatelessWidget {
  final bool isOwnProfile;
  final bool isConnected;
  final VoidCallback onEditProfile;
  final VoidCallback onSendTask;
  final VoidCallback onMessage;
  final VoidCallback onSendRequest;

  const ProfileActionsWidget({
    Key? key,
    required this.isOwnProfile,
    required this.isConnected,
    required this.onEditProfile,
    required this.onSendTask,
    required this.onMessage,
    required this.onSendRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOwnProfile) {
      return _buildOwnProfileActions();
    } else {
      return _buildOtherProfileActions();
    }
  }

  Widget _buildOwnProfileActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onEditProfile,
          icon: CustomIconWidget(
            iconName: 'edit',
            color: Colors.white,
            size: 20,
          ),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 1.5.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtherProfileActions() {
    if (isConnected) {
      return _buildConnectedActions();
    } else {
      return _buildNotConnectedActions();
    }
  }

  Widget _buildConnectedActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onSendTask,
              icon: CustomIconWidget(
                iconName: 'assignment',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Send Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onMessage,
              icon: CustomIconWidget(
                iconName: 'message',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              label: const Text('Message'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotConnectedActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSendRequest,
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Send Connection Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Connect to send tasks and messages',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
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
