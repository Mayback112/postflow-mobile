import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/notifications_controller.dart';
import 'package:postflow/screen/notifications/notification_models.dart';
import 'package:postflow/services/notification_service.dart';

void main() {
  test('loads notifications and unread count', () async {
    final service = _FakeNotificationService(
      response: NotificationsResponse(
        notifications: [_notification(id: 'notification-1')],
        unreadCount: 1,
      ),
    );
    final controller = NotificationsController(notificationService: service);

    await controller.loadNotifications();

    expect(controller.isLoading, isFalse);
    expect(controller.notifications.single.id, 'notification-1');
    expect(controller.unreadCount, 1);
    expect(controller.hasUnread, isTrue);
  });

  test('markRead updates unread count', () async {
    final unread = _notification(id: 'notification-1');
    final service = _FakeNotificationService(
      response: NotificationsResponse(notifications: [unread], unreadCount: 1),
      markReadResponse: unread.copyWith(readAt: DateTime.utc(2026, 6, 15, 20)),
    );
    final controller = NotificationsController(notificationService: service);

    await controller.loadNotifications();
    await controller.markRead('notification-1');

    expect(service.markedNotificationId, 'notification-1');
    expect(controller.notifications.single.isUnread, isFalse);
    expect(controller.unreadCount, 0);
  });

  test('markAllRead clears all unread notifications', () async {
    final service = _FakeNotificationService(
      response: NotificationsResponse(
        notifications: [
          _notification(id: 'notification-1'),
          _notification(id: 'notification-2'),
        ],
        unreadCount: 2,
      ),
    );
    final controller = NotificationsController(notificationService: service);

    await controller.loadNotifications();
    await controller.markAllRead();

    expect(service.didMarkAllRead, isTrue);
    expect(controller.notifications.every((item) => !item.isUnread), isTrue);
    expect(controller.unreadCount, 0);
  });
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({
    required this.response,
    NotificationItem? markReadResponse,
  }) : markReadResponse = markReadResponse ?? response.notifications.first;

  final NotificationsResponse response;
  final NotificationItem markReadResponse;
  String? markedNotificationId;
  bool didMarkAllRead = false;

  @override
  Future<NotificationsResponse> listNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    return response;
  }

  @override
  Future<NotificationItem> markRead(String notificationId) async {
    markedNotificationId = notificationId;
    return markReadResponse;
  }

  @override
  Future<void> markAllRead() async {
    didMarkAllRead = true;
  }
}

NotificationItem _notification({required String id}) {
  return NotificationItem(
    id: id,
    type: 'POST_REMINDER',
    kind: NotificationKind.reminder,
    title: 'Post publishing soon',
    message: 'Your scheduled post will publish soon.',
    createdAt: DateTime.utc(2026, 6, 15, 20),
    data: const {'postId': 'post-1'},
  );
}
