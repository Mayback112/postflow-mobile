import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/notifications_controller.dart';
import 'package:postflow/screen/notifications/notification_models.dart';
import 'package:postflow/services/notification_service.dart';

void main() {
  test('loads notifications and unread count', () async {
    final service = _FakeNotificationService(
      response: NotificationsResponse(
        notifications: [_notification(id: 'n-1')],
        unreadCount: 1,
      ),
    );
    final controller = NotificationsController(notificationService: service);

    await controller.loadNotifications();

    expect(controller.isLoading, isFalse);
    expect(controller.notifications.single.id, 'n-1');
    expect(controller.unreadCount, 1);
    expect(controller.hasUnread, isTrue);
  });

  test('markRead updates notification optimistically', () async {
    final unread = _notification(id: 'n-1');
    final read = unread.copyWith(readAt: DateTime.utc(2026, 6, 15, 20));
    final service = _FakeNotificationService(
      response: NotificationsResponse(notifications: [unread], unreadCount: 1),
      markReadResponse: read,
    );
    final controller = NotificationsController(notificationService: service);

    await controller.loadNotifications();
    await controller.markRead('n-1');

    expect(service.markedId, 'n-1');
    expect(controller.notifications.single.isUnread, isFalse);
    expect(controller.unreadCount, 0);
  });

  test('markAllRead clears all unread', () async {
    final service = _FakeNotificationService(
      response: NotificationsResponse(
        notifications: [_notification(id: 'n-1'), _notification(id: 'n-2')],
        unreadCount: 2,
      ),
    );
    final controller = NotificationsController(notificationService: service);

    await controller.loadNotifications();
    await controller.markAllRead();

    expect(service.didMarkAllRead, isTrue);
    expect(controller.notifications.every((n) => !n.isUnread), isTrue);
    expect(controller.unreadCount, 0);
  });
}

NotificationItem _notification({required String id}) {
  return NotificationItem(
    id: id,
    kind: NotificationKind.schedule,
    title: 'Post published',
    message: 'Your post was published successfully.',
    time: '1m ago',
    isUnread: true,
  );
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({required this.response, NotificationItem? markReadResponse})
      : markReadResponse = markReadResponse ?? response.notifications.first;

  final NotificationsResponse response;
  final NotificationItem markReadResponse;
  String? markedId;
  bool didMarkAllRead = false;

  @override
  Future<NotificationsResponse> listNotifications({bool unreadOnly = false, int limit = 50}) async => response;

  @override
  Future<NotificationItem> markRead(String notificationId) async {
    markedId = notificationId;
    return markReadResponse;
  }

  @override
  Future<void> markAllRead() async {
    didMarkAllRead = true;
  }
}
