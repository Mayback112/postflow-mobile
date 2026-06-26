import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/screen/notifications/notification_models.dart';
import 'package:postflow/services/notification_service.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  final NotificationService _notificationService;

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isMarkingAllRead = false;
  String? _errorMessage;
  List<NotificationItem> _notifications = const [];
  int _unreadCount = 0;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isMarkingAllRead => _isMarkingAllRead;
  String? get errorMessage => _errorMessage;
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _notificationService.listNotifications();
      _applyResponse(response);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _notificationService.listNotifications();
      _applyResponse(response);
      _isRefreshing = false;
      notifyListeners();
    } catch (error) {
      _isRefreshing = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  Future<void> markRead(String notificationId) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (index == -1 || !_notifications[index].isUnread) return;

    final previous = _notifications;
    final optimistic = [..._notifications];
    optimistic[index] = optimistic[index].copyWith(readAt: DateTime.now());
    _notifications = optimistic;
    _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
    notifyListeners();

    try {
      final updated = await _notificationService.markRead(notificationId);
      _replaceNotification(updated);
    } catch (error) {
      _notifications = previous;
      _unreadCount = previous.where((item) => item.isUnread).length;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    if (_isMarkingAllRead || !hasUnread) return;

    _isMarkingAllRead = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _notificationService.markAllRead();
      final now = DateTime.now();
      _notifications = _notifications
          .map((notification) => notification.copyWith(readAt: now))
          .toList();
      _unreadCount = 0;
      _isMarkingAllRead = false;
      notifyListeners();
    } catch (error) {
      _isMarkingAllRead = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  void _applyResponse(NotificationsResponse response) {
    _notifications = response.notifications;
    _unreadCount = response.unreadCount;
  }

  void _replaceNotification(NotificationItem updated) {
    final index = _notifications.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;

    final next = [..._notifications];
    next[index] = updated;
    _notifications = next;
    _unreadCount = _notifications.where((item) => item.isUnread).length;
    notifyListeners();
  }

  String _messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'Could not load notifications. Please try again.';
  }
}
