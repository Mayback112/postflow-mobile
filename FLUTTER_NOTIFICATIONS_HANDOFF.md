# Flutter Notifications Handoff

This document explains the backend changes Flutter needs to integrate for post reminders, publish status notifications, push tokens, and in-app notifications.

Use only the PostFlow API. Flutter should not call Zernio for notifications.

## Base URL

Use the existing mobile API base URL:

```text
Android emulator: http://10.0.2.2:4000
iOS simulator: http://localhost:4000
Physical device: machine LAN IP or HTTPS tunnel
```

All notification endpoints require:

```text
Authorization: Bearer <accessToken>
Content-Type: application/json
```

The access token comes from the existing mobile auth flow.

## What Backend Does

The backend now:

- Stores Flutter device push tokens.
- Creates in-app notification records.
- Schedules post reminder jobs when posts are scheduled.
- Sends reminder notifications before publish time.
- Sends notification records for Zernio post published/failed webhooks.
- Dispatches push notifications through FCM when `FCM_SERVER_KEY` is configured.
- Dispatches email through SMTP when SMTP env vars are configured.

Flutter does not calculate reminder times. The backend owns reminder timing because the app may be closed.

## Flutter Responsibilities

Flutter should:

1. Ask the user for notification permission.
2. Get the Firebase Messaging token.
3. Register the token with the backend after login.
4. Re-register when Firebase rotates the token.
5. Remove/deactivate the token on logout when possible.
6. Fetch in-app notifications from the backend.
7. Mark notifications as read.
8. Deep-link notification taps to the related post screen when `postId` exists.

## Device Token Registration

Call this after login and whenever FCM returns/refreshed a token.

```http
POST /mobile/device-tokens
Authorization: Bearer <accessToken>
Content-Type: application/json
```

Request:

```json
{
  "token": "firebase_messaging_token",
  "platform": "ANDROID",
  "deviceId": "optional-stable-device-id"
}
```

Allowed `platform` values:

```text
IOS
ANDROID
WEB
```

Success response:

```json
{
  "id": "device_token_id",
  "userId": "user_id",
  "token": "firebase_messaging_token",
  "platform": "ANDROID",
  "deviceId": "optional-stable-device-id",
  "active": true,
  "lastSeenAt": "2026-06-15T20:00:00.000Z",
  "createdAt": "2026-06-15T20:00:00.000Z",
  "updatedAt": "2026-06-15T20:00:00.000Z"
}
```

## Remove Device Token

Call this on logout if Flutter still has the token.

```http
POST /mobile/device-tokens/remove
Authorization: Bearer <accessToken>
Content-Type: application/json
```

Request:

```json
{
  "token": "firebase_messaging_token"
}
```

Success response:

```text
204 No Content
```

## List Notifications

Use this for the notification inbox/list screen and unread badge.

```http
GET /mobile/notifications
Authorization: Bearer <accessToken>
```

Optional query params:

```text
unreadOnly=true
limit=50
```

Example:

```http
GET /mobile/notifications?unreadOnly=false&limit=50
```

Success response:

```json
{
  "notifications": [
    {
      "id": "notification_id",
      "userId": "user_id",
      "workspaceId": "workspace_id",
      "postId": "post_id",
      "type": "POST_REMINDER",
      "title": "Post publishing soon",
      "body": "Your scheduled post will publish at 2026-06-20T15:00:00.000Z.",
      "data": {
        "postId": "post_id",
        "workspaceId": "workspace_id",
        "type": "POST_REMINDER"
      },
      "readAt": null,
      "sentEmailAt": null,
      "sentPushAt": null,
      "createdAt": "2026-06-15T20:00:00.000Z"
    }
  ],
  "unreadCount": 1
}
```

Notification `type` values:

```text
POST_REMINDER
POST_PUBLISHED
POST_FAILED
```

## Mark One Notification Read

```http
PATCH /mobile/notifications/:notificationId/read
Authorization: Bearer <accessToken>
```

Success response:

```json
{
  "id": "notification_id",
  "readAt": "2026-06-15T20:05:00.000Z"
}
```

The response includes the full notification row.

## Mark All Notifications Read

```http
PATCH /mobile/notifications/read-all
Authorization: Bearer <accessToken>
```

Success response:

```json
{
  "success": true
}
```

## Push Payload Shape

The backend sends push notifications with:

```json
{
  "notification": {
    "title": "Post publishing soon",
    "body": "Your scheduled post will publish at 2026-06-20T15:00:00.000Z."
  },
  "data": {
    "postId": "post_id",
    "workspaceId": "workspace_id",
    "type": "POST_REMINDER"
  }
}
```

Flutter should use `data.postId` to open the post detail screen.

If `postId` is missing, open the notifications screen.

## Recommended Flutter Flow

On app startup after auth restore:

1. Call `GET /mobile/auth/me`.
2. Initialize Firebase Messaging.
3. Request notification permission.
4. Get FCM token.
5. Call `POST /mobile/device-tokens`.
6. Call `GET /mobile/notifications?limit=50`.
7. Display unread count in app shell.

On token refresh:

1. Listen to Firebase Messaging token refresh.
2. Call `POST /mobile/device-tokens` with the new token.

On logout:

1. Get current token if available.
2. Call `POST /mobile/device-tokens/remove`.
3. Clear local auth/session state.

On notification tap:

1. Read `data.postId`.
2. If present, navigate to post detail.
3. Call `PATCH /mobile/notifications/:notificationId/read` if the notification exists in the in-app list.

## Dart Request Examples

Register token:

```dart
Future<void> registerDeviceToken({
  required String apiBaseUrl,
  required String accessToken,
  required String fcmToken,
  required String platform,
  String? deviceId,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/mobile/device-tokens'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'token': fcmToken,
      'platform': platform,
      if (deviceId != null) 'deviceId': deviceId,
    }),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Failed to register device token: ${response.body}');
  }
}
```

List notifications:

```dart
Future<Map<String, dynamic>> fetchNotifications({
  required String apiBaseUrl,
  required String accessToken,
}) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/mobile/notifications?limit=50'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch notifications: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}
```

Mark read:

```dart
Future<void> markNotificationRead({
  required String apiBaseUrl,
  required String accessToken,
  required String notificationId,
}) async {
  final response = await http.patch(
    Uri.parse('$apiBaseUrl/mobile/notifications/$notificationId/read'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to mark notification read: ${response.body}');
  }
}
```

## Backend Env Needed

Backend notification env keys:

```env
POST_REMINDER_LEAD_MINUTES=60
SMTP_HOST=
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=
SMTP_PASS=
NOTIFICATION_EMAIL_FROM="PostFlow <notifications@example.com>"
FCM_SERVER_KEY=
```

Email will be skipped until SMTP values are configured.
Push will be skipped until `FCM_SERVER_KEY` is configured.

In-app notifications still work even when email/push providers are not configured.
