import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/api/api.dart';
import 'package:postflow/services/notification_service.dart';

void main() {
  test('listNotifications reads mobile notifications endpoint', () async {
    late RequestOptions capturedRequest;
    final service = NotificationService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'notifications': [
            {
              'id': 'notification-1',
              'type': 'POST_REMINDER',
              'title': 'Post publishing soon',
              'body': 'Your scheduled post will publish soon.',
              'data': {'postId': 'post-1'},
              'readAt': null,
              'createdAt': '2026-06-15T20:00:00.000Z',
            },
          ],
          'unreadCount': 1,
        };
      }),
    );

    final response = await service.listNotifications(
      unreadOnly: true,
      limit: 25,
    );

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.uri.path, '/mobile/notifications');
    expect(capturedRequest.uri.queryParameters, {
      'unreadOnly': 'true',
      'limit': '25',
    });
    expect(response.notifications.single.id, 'notification-1');
    expect(response.unreadCount, 1);
  });

  test('registerDeviceToken sends platform token payload', () async {
    late RequestOptions capturedRequest;
    final service = NotificationService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {'id': 'token-1'};
      }),
    );

    await service.registerDeviceToken(
      token: 'fcm-token',
      platform: DeviceTokenPlatform.android,
      deviceId: 'device-1',
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.uri.path, '/mobile/device-tokens');
    expect(capturedRequest.data, {
      'token': 'fcm-token',
      'platform': 'ANDROID',
      'deviceId': 'device-1',
    });
  });

  test('markAllRead patches read-all endpoint', () async {
    late RequestOptions capturedRequest;
    final service = NotificationService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {'success': true};
      }),
    );

    await service.markAllRead();

    expect(capturedRequest.method, 'PATCH');
    expect(capturedRequest.uri.path, '/mobile/notifications/read-all');
  });
}

ApiClient _mockApiClient(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, requestHandler) {
        requestHandler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: handler(options),
          ),
        );
      },
    ),
  );

  return ApiClient(
    dio: dio,
    baseUri: Uri.parse('http://127.0.0.1:4000'),
    enableAuthInterceptor: false,
  );
}
