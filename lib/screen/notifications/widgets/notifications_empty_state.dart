import 'package:flutter/material.dart';
import 'package:postflow/components/app_empty_state.dart';

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.notifications_none_rounded,
      title: 'No notifications yet',
      message:
          'Publishing alerts, account updates, and AI results will appear here.',
      primaryLabel: 'Create a post',
      onPrimaryPressed: () => Navigator.of(context).pushNamed('/CreateWithAi'),
    );
  }
}
