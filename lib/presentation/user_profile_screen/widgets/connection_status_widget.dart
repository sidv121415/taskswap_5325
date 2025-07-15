import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final bool hasRequestSent;
  final bool hasRequestReceived;
  final Function(String) onConnectionAction;

  const ConnectionStatusWidget({
    Key? key,
    required this.isConnected,
    required this.hasRequestSent,
    required this.hasRequestReceived,
    required this.onConnectionAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: _buildConnectionContent(),
    );
  }

  Color _getBorderColor() {
    if (isConnected) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else if (hasRequestReceived) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (hasRequestSent) {
      return AppTheme.lightTheme.colorScheme.secondary;
    }
    return AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3);
  }

  Widget _buildConnectionContent() {
    if (isConnected) {
      return _buildConnectedStatus();
    } else if (hasRequestReceived) {
      return _buildRequestReceivedStatus();
    } else if (hasRequestSent) {
      return _buildRequestSentStatus();
    }
    return _buildNotConnectedStatus();
  }

  Widget _buildConnectedStatus() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'You can send tasks and messages',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => _showDisconnectDialog(),
          child: Text(
            'Disconnect',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestReceivedStatus() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'person_add',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Request Received',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'This user wants to connect with you',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onConnectionAction('accept'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Accept'),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton(
                onPressed: () => onConnectionAction('decline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline,
                  ),
                ),
                child: const Text('Decline'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequestSentStatus() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Sent',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Waiting for response',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => onConnectionAction('cancel'),
          child: Text(
            'Cancel',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotConnectedStatus() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'person_add_alt',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Not Connected',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Send a connection request to collaborate',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => onConnectionAction('connect'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          ),
          child: const Text('Connect'),
        ),
      ],
    );
  }

  void _showDisconnectDialog() {
    // This would typically show a confirmation dialog
    // For now, we'll just call the disconnect action
    onConnectionAction('disconnect');
  }
}
