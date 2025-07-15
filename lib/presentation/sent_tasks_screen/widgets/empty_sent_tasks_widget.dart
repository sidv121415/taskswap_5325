import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptySentTasksWidget extends StatelessWidget {
  final VoidCallback onCreateTask;

  const EmptySentTasksWidget({
    super.key,
    required this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 60.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'assignment',
                    color: AppTheme.primaryLight.withValues(alpha: 0.6),
                    size: 80,
                  ),
                  SizedBox(height: 2.h),
                  CustomIconWidget(
                    iconName: 'arrow_forward',
                    color: AppTheme.primaryLight.withValues(alpha: 0.4),
                    size: 40,
                  ),
                  SizedBox(height: 2.h),
                  CustomIconWidget(
                    iconName: 'people',
                    color: AppTheme.primaryLight.withValues(alpha: 0.6),
                    size: 60,
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'No Sent Tasks Yet',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Create your first task and assign it to your connections. Start collaborating and getting things done together!',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondaryLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Create Task Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCreateTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Create Your First Task',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Connection suggestions
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'lightbulb',
                        color: AppTheme.warningLight,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Pro Tips',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildTipItem(
                    'Connect with colleagues, friends, or family members',
                    'people_outline',
                  ),
                  _buildTipItem(
                    'Set clear priorities and due dates for better results',
                    'schedule',
                  ),
                  _buildTipItem(
                    'Use task descriptions to provide detailed instructions',
                    'description',
                  ),
                  _buildTipItem(
                    'Send reminders to keep tasks on track',
                    'notifications',
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Secondary action
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/home-dashboard'),
              child: Text(
                'Explore Connections',
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
    );
  }

  Widget _buildTipItem(String text, String iconName) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.textSecondaryLight,
            size: 16,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondaryLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
