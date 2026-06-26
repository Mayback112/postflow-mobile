enum NotificationKind { schedule, platform, ai, account }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
    this.readAt,
  });

  final String id;
  final NotificationKind kind;
  final String title;
  final String message;
  final String time;
  final bool isUnread;
  final DateTime? readAt;

  NotificationItem copyWith({DateTime? readAt}) {
    return NotificationItem(
      id: id,
      kind: kind,
      title: title,
      message: message,
      time: time,
      isUnread: readAt == null ? isUnread : false,
      readAt: readAt ?? this.readAt,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final readAt = json['readAt'] != null
        ? DateTime.tryParse(json['readAt'] as String)
        : null;
    final createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : DateTime.now();
    return NotificationItem(
      id: json['id'] as String,
      kind: _kindFromType(json['type'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      time: _formatTime(createdAt ?? DateTime.now()),
      isUnread: readAt == null,
      readAt: readAt,
    );
  }

  static NotificationKind _kindFromType(String type) {
    return switch (type.toUpperCase()) {
      'PUBLISH_SUCCESS' || 'PUBLISH_FAILURE' => NotificationKind.schedule,
      'TOKEN_EXPIRED' => NotificationKind.account,
      _ => NotificationKind.platform,
    };
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class NotificationsResponse {
  const NotificationsResponse({
    required this.notifications,
    required this.unreadCount,
  });

  final List<NotificationItem> notifications;
  final int unreadCount;

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['notifications'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList();
    return NotificationsResponse(
      notifications: items,
      unreadCount: json['unreadCount'] as int? ?? items.where((n) => n.isUnread).length,
    );
  }
}
