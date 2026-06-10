enum NotificationKind { schedule, platform, ai, account }

class NotificationItem {
  const NotificationItem({
    required this.kind,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  final NotificationKind kind;
  final String title;
  final String message;
  final String time;
  final bool isUnread;
}
