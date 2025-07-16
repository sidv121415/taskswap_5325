import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double size;

  const CustomIconWidget({
    Key? key,
    required this.iconName,
    this.color,
    this.size = 24.0,
  }) : super(key: key);

  IconData _getIconData(String iconName) {
    switch (iconName) {
      // Navigation icons
      case 'home':
        return Icons.home;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'arrow_forward_ios':
        return Icons.arrow_forward_ios;
      case 'keyboard_arrow_down':
        return Icons.keyboard_arrow_down;
      case 'keyboard_arrow_up':
        return Icons.keyboard_arrow_up;
      case 'expand_less':
        return Icons.expand_less;
      case 'expand_more':
        return Icons.expand_more;
      case 'chevron_right':
        return Icons.chevron_right;
      
      // Task and assignment icons
      case 'assignment':
        return Icons.assignment;
      case 'task_alt':
        return Icons.task_alt;
      case 'check_circle':
        return Icons.check_circle;
      case 'check_circle_outline':
        return Icons.check_circle_outline;
      case 'pending_actions':
        return Icons.pending_actions;
      case 'schedule':
        return Icons.schedule;
      case 'today':
        return Icons.today;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'event':
        return Icons.event;
      case 'priority_high':
        return Icons.priority_high;
      case 'flag':
        return Icons.flag;
      
      // User and social icons
      case 'person':
        return Icons.person;
      case 'person_add':
        return Icons.person_add;
      case 'person_add_alt':
        return Icons.person_add_alt;
      case 'people':
        return Icons.people;
      case 'people_outline':
        return Icons.people_outline;
      case 'verified':
        return Icons.verified;
      
      // Communication icons
      case 'notifications':
        return Icons.notifications;
      case 'notifications_off':
        return Icons.notifications_off;
      case 'message':
        return Icons.message;
      case 'send':
        return Icons.send;
      case 'chat_bubble_outline':
        return Icons.chat_bubble_outline;
      case 'reply':
        return Icons.reply;
      
      // Action icons
      case 'add':
        return Icons.add;
      case 'edit':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'share':
        return Icons.share;
      case 'copy':
        return Icons.copy;
      case 'content_copy':
        return Icons.content_copy;
      case 'archive':
        return Icons.archive;
      case 'more_vert':
        return Icons.more_vert;
      case 'settings':
        return Icons.settings;
      case 'close':
        return Icons.close;
      case 'clear':
        return Icons.clear;
      
      // Search and filter icons
      case 'search':
        return Icons.search;
      case 'search_off':
        return Icons.search_off;
      case 'filter_list':
        return Icons.filter_list;
      case 'sort':
        return Icons.sort;
      case 'sort_by_alpha':
        return Icons.sort_by_alpha;
      
      // Status and feedback icons
      case 'info':
        return Icons.info;
      case 'info_outline':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'help_outline':
        return Icons.help_outline;
      case 'lightbulb':
        return Icons.lightbulb;
      
      // Media and content icons
      case 'visibility':
        return Icons.visibility;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'photo_library':
        return Icons.photo_library;
      case 'description':
        return Icons.description;
      
      // UI elements
      case 'remove':
        return Icons.remove;
      case 'radio_button_checked':
        return Icons.radio_button_checked;
      case 'radio_button_unchecked':
        return Icons.radio_button_unchecked;
      case 'check':
        return Icons.check;
      case 'lock':
        return Icons.lock;
      case 'timeline':
        return Icons.timeline;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'play_circle_outline':
        return Icons.play_circle_outline;
      case 'inbox_outlined':
        return Icons.inbox_outlined;
      case 'send_outlined':
        return Icons.send_outlined;
      
      // Default fallback
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(iconName),
      color: color,
      size: size,
    );
  }
}