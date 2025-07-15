import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isOwnProfile;
  final VoidCallback onEditProfile;
  final VoidCallback onPhotoTap;

  const ProfileHeaderWidget({
    Key? key,
    required this.userData,
    required this.isOwnProfile,
    required this.onEditProfile,
    required this.onPhotoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          _buildProfilePhoto(),
          SizedBox(height: 3.h),
          _buildUserInfo(),
          if (userData["bio"] != null &&
              userData["bio"].toString().isNotEmpty) ...[
            SizedBox(height: 2.h),
            _buildBio(),
          ],
          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return GestureDetector(
      onTap: onPhotoTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 18.w,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              backgroundImage: userData["profilePhoto"] != null
                  ? NetworkImage(userData["profilePhoto"])
                  : null,
              child: userData["profilePhoto"] == null
                  ? CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20.w,
                    )
                  : null,
            ),
          ),
          if (isOwnProfile)
            Positioned(
              bottom: 1.w,
              right: 1.w,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.cardColor,
                    width: 2,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'edit',
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          if (!isOwnProfile && userData["isVerified"] == true)
            Positioned(
              bottom: 1.w,
              right: 1.w,
              child: Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.lightTheme.cardColor,
                    width: 2,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'verified',
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                userData["displayName"] ?? 'Unknown User',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (userData["isVerified"] == true) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'verified',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          userData["username"] ?? '@unknown',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (userData["joinedDate"] != null) ...[
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'calendar_today',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                'Joined ${_formatJoinDate(userData["joinedDate"])}',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBio() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        userData["bio"],
        style: AppTheme.lightTheme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatJoinDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return dateString;
    }
  }
}
