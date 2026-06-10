import 'package:flutter/material.dart';
import 'package:postflow/components/app_empty_state.dart';

class ScheduledEmptyState extends StatelessWidget {
  const ScheduledEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.event_busy_rounded,
      title: 'No scheduled posts',
      message: 'Create a post and choose a publish time to see it here.',
      primaryLabel: 'Create post',
      onPrimaryPressed: () => Navigator.of(context).pushNamed('/CreateWithAi'),
    );
  }
}
