import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskCommentsWidget extends StatelessWidget {
  final List comments;
  final TextEditingController commentController;
  final FocusNode commentFocusNode;
  final Function(String) onCommentAdded;

  const TaskCommentsWidget({
    super.key,
    required this.comments,
    required this.commentController,
    required this.commentFocusNode,
    required this.onCommentAdded,
  });

  String _formatTimestamp(String timestamp) {
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildComment(BuildContext context, Map<String, dynamic> comment,
      {bool isReply = false}) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 8.w : 0,
        bottom: 2.h,
      ),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isReply
            ? AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomImageWidget(
                  imageUrl: comment["userAvatar"] as String,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(width: 2.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment["userName"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatTimestamp(comment["timestamp"] as String),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Comment actions
              PopupMenuButton<String>(
                icon: CustomIconWidget(
                  iconName: 'more_vert',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                onSelected: (value) {
                  if (value == 'copy') {
                    // Copy comment functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Comment copied to clipboard')),
                    );
                  } else if (value == 'reply') {
                    // Reply functionality
                    commentFocusNode.requestFocus();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'copy',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 16),
                        SizedBox(width: 8),
                        Text('Copy'),
                      ],
                    ),
                  ),
                  if (!isReply)
                    const PopupMenuItem(
                      value: 'reply',
                      child: Row(
                        children: [
                          Icon(Icons.reply, size: 16),
                          SizedBox(width: 8),
                          Text('Reply'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          SizedBox(height: 2.w),

          // Comment content
          Text(
            comment["content"] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),

          // Replies
          if (!isReply &&
              comment["replies"] != null &&
              (comment["replies"] as List).isNotEmpty) ...[
            SizedBox(height: 2.h),
            ...(comment["replies"] as List).map((reply) => _buildComment(
                context, reply as Map<String, dynamic>,
                isReply: true)),
          ],
        ],
      ),
    );
  }

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
                iconName: 'chat_bubble_outline',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Comments',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${comments.length}',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Comments list
          if (comments.isNotEmpty) ...[
            ...comments.map((comment) =>
                _buildComment(context, comment as Map<String, dynamic>)),
          ] else ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'chat_bubble_outline',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.5),
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No comments yet',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Be the first to add a comment',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Add comment input
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomImageWidget(
                    imageUrl:
                        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=face",
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    focusNode: commentFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle:
                          AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: onCommentAdded,
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: () => onCommentAdded(commentController.text),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'send',
                      color: Colors.white,
                      size: 16,
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
