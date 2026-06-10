import 'package:flutter/material.dart';
import 'package:postflow/screen/notifications/notification_models.dart';
import 'package:postflow/screen/notifications/widgets/notification_summary_card.dart';
import 'package:postflow/screen/notifications/widgets/notification_tile.dart';
import 'package:postflow/screen/notifications/widgets/notifications_empty_state.dart';

class NotificationsContent extends StatelessWidget {
  final List<NotificationItem> notifications;

  const NotificationsContent({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications
        .where((notification) => notification.isUnread)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NotificationSummaryCard(unreadCount: unreadCount),
        const SizedBox(height: 14),
        if (notifications.isEmpty)
          const NotificationsEmptyState()
        else
          ...notifications.map(
            (notification) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: NotificationTile(notification: notification),
            ),
          ),
      ],
    );
  }
}
