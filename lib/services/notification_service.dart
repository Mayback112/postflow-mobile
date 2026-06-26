import 'package:postflow/api/api.dart';
import 'package:postflow/screen/notifications/notification_models.dart';

enum DeviceTokenPlatform { ios, android, web }

class NotificationService {
  NotificationService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<NotificationsResponse> listNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.notifications,
      query: {'unreadOnly': unreadOnly, 'limit': limit},
    );
    return NotificationsResponse.fromJson(response);
  }

  Future<NotificationItem> markRead(String notificationId) async {
    final response = await _apiClient.patchJsonPath(
      '/mobile/notifications/$notificationId/read',
      const {},
    );
    return NotificationItem.fromJson(response);
  }

  Future<void> markAllRead() async {
    await _apiClient.patchJsonPath(
      ApiEndpoint.notificationsReadAll.path,
      const {},
    );
  }

  Future<void> registerDeviceToken({
    required String token,
    required DeviceTokenPlatform platform,
    String? deviceId,
  }) async {
    await _apiClient.postJson(ApiEndpoint.deviceTokens, {
      'token': token,
      'platform': platform.apiValue,
      if (deviceId != null && deviceId.isNotEmpty) 'deviceId': deviceId,
    });
  }

  Future<void> removeDeviceToken(String token) async {
    await _apiClient.postJson(ApiEndpoint.deviceTokensRemove, {'token': token});
  }
}

extension on DeviceTokenPlatform {
  String get apiValue {
    return switch (this) {
      DeviceTokenPlatform.ios => 'IOS',
      DeviceTokenPlatform.android => 'ANDROID',
      DeviceTokenPlatform.web => 'WEB',
    };
  }
}
