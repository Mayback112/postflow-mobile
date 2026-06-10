# Mobile Zernio Integration Handoff

This document is for the Flutter mobile app agent. It explains how the app
should connect social media accounts through the PostFlow backend and Zernio.

The mobile app must not call Zernio directly and must not handle Instagram,
Facebook, TikTok, or other platform access tokens. Flutter talks only to the
PostFlow API. PostFlow talks to Zernio.

## Current Backend Status

Zernio is already wired on the backend for social account connection and sync.

Local webhook testing has been confirmed through ngrok:

```text
https://nonrepudiable-richie-nonceremonious.ngrok-free.dev/social-accounts/zernio/webhook
```

Zernio successfully sent a test webhook to that URL and the API returned:

```json
{
  "received": true,
  "duplicate": false,
  "processed": true
}
```

The mobile app does not need to call this webhook endpoint. It is only for
Zernio server-to-server events.

## Base URLs

Use the PostFlow API base URL for all mobile requests.

Android emulator:

```text
http://10.0.2.2:4000
```

iOS simulator:

```text
http://localhost:4000
```

Physical device:

```text
Use the local network IP or a tunnel URL that can reach the API.
```

All authenticated requests require:

```text
Authorization: Bearer <jwt_access_token>
Content-Type: application/json
```

The access token comes from:

```text
POST /mobile/auth/sign
```

or, for local emulator testing:

```text
POST /mobile/auth/test
```

## Supported Platform Values

Send these exact enum values to the backend:

```text
INSTAGRAM
FACEBOOK
TIKTOK
YOUTUBE
LINKEDIN
X
THREADS
```

The backend maps them to Zernio platform values internally.

## Required Mobile Flow

Example: user taps "Connect Instagram".

1. Make sure the user is signed in and you have a valid PostFlow access token.
2. Make sure the app has a `workspaceId`.
3. Call `POST /mobile/social-accounts/zernio/connect`.
4. Read `authUrl` from the response.
5. Open `authUrl` in the system browser.
6. User completes the platform login in the browser.
7. When the browser returns or the app resumes, call
   `POST /mobile/social-accounts/zernio/sync`.
8. Call `GET /mobile/social-accounts?workspaceId=<workspaceId>`.
9. Display the connected account using `displayName`, `username`,
   `profilePictureUrl`, and `isActive`.

For Instagram, the auth screen may be Meta/Facebook OAuth because Instagram
Business and Creator account permissions are handled through Meta.

## Endpoint: Start Zernio Connect

```text
POST /mobile/social-accounts/zernio/connect
```

Headers:

```text
Authorization: Bearer <jwt_access_token>
Content-Type: application/json
```

Request:

```json
{
  "workspaceId": "workspace_id",
  "platform": "INSTAGRAM"
}
```

Success response:

```json
{
  "authUrl": "https://zernio.com/...",
  "state": "..."
}
```

Mobile action:

Open `authUrl` in the external browser. Do not parse or modify it.

## Endpoint: Sync Zernio Accounts

```text
POST /mobile/social-accounts/zernio/sync
```

Headers:

```text
Authorization: Bearer <jwt_access_token>
Content-Type: application/json
```

Request:

```json
{
  "workspaceId": "workspace_id"
}
```

Success response:

```json
{
  "socialAccounts": [
    {
      "id": "local_social_account_id",
      "workspaceId": "workspace_id",
      "platform": "INSTAGRAM",
      "externalId": "zernio_account_id",
      "displayName": "Brand Instagram",
      "provider": "ZERNIO",
      "zernioProfileId": "zernio_profile_id",
      "zernioAccountId": "zernio_account_id",
      "username": "brand_handle",
      "profilePictureUrl": "https://...",
      "profileUrl": "https://...",
      "isActive": true,
      "tokenExpiresAt": null,
      "createdAt": "2026-06-10T14:00:00.000Z",
      "updatedAt": "2026-06-10T14:00:00.000Z"
    }
  ]
}
```

The backend strips `accessToken` and `refreshToken` from responses. Flutter
should never expect platform tokens.

## Endpoint: List Connected Social Accounts

```text
GET /mobile/social-accounts?workspaceId=<workspaceId>
```

Headers:

```text
Authorization: Bearer <jwt_access_token>
```

Success response:

```json
{
  "socialAccounts": [
    {
      "id": "local_social_account_id",
      "workspaceId": "workspace_id",
      "platform": "INSTAGRAM",
      "externalId": "zernio_account_id",
      "displayName": "Brand Instagram",
      "provider": "ZERNIO",
      "zernioProfileId": "zernio_profile_id",
      "zernioAccountId": "zernio_account_id",
      "username": "brand_handle",
      "profilePictureUrl": "https://...",
      "profileUrl": "https://...",
      "isActive": true,
      "tokenExpiresAt": null,
      "createdAt": "2026-06-10T14:00:00.000Z",
      "updatedAt": "2026-06-10T14:00:00.000Z"
    }
  ]
}
```

Display rules:

```text
Primary title: displayName
Secondary text: @username when available
Avatar: profilePictureUrl when available
Status: Connected when isActive is true
Status: Disconnected / Reconnect needed when isActive is false
```

## Endpoint: Get One Social Account

```text
GET /mobile/social-accounts/<socialAccountId>
```

Use this only when a detail screen needs one account. Most screens can use the
list endpoint.

## Endpoint: Remove Local Social Account

```text
DELETE /mobile/social-accounts/<socialAccountId>
```

This removes the local PostFlow record if it is not used by existing posts.
It does not replace a full platform disconnect flow through Zernio.

If the backend returns `400` with:

```text
Social account is used by existing posts
```

show a clear error and keep the account visible.

## Flutter Dependencies

Expected dependencies:

```yaml
dependencies:
  http: ^1.2.0
  url_launcher: ^6.3.0
  flutter_secure_storage: ^9.2.0
```

Use whatever state management the app already uses. The examples below are
plain Dart service examples and can be wrapped by Provider, Bloc, Riverpod, or
the current app pattern.

## Dart Model

```dart
class SocialAccount {
  const SocialAccount({
    required this.id,
    required this.workspaceId,
    required this.platform,
    required this.displayName,
    required this.provider,
    required this.isActive,
    this.username,
    this.profilePictureUrl,
    this.profileUrl,
    this.zernioAccountId,
  });

  final String id;
  final String workspaceId;
  final String platform;
  final String displayName;
  final String provider;
  final bool isActive;
  final String? username;
  final String? profilePictureUrl;
  final String? profileUrl;
  final String? zernioAccountId;

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      platform: json['platform'] as String,
      displayName: json['displayName'] as String,
      provider: json['provider'] as String? ?? 'MOCK',
      isActive: json['isActive'] as bool? ?? true,
      username: json['username'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      profileUrl: json['profileUrl'] as String?,
      zernioAccountId: json['zernioAccountId'] as String?,
    );
  }
}
```

## Dart API Service

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ZernioSocialApi {
  ZernioSocialApi({
    required this.apiBaseUrl,
    required this.accessTokenProvider,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String apiBaseUrl;
  final Future<String> Function() accessTokenProvider;
  final http.Client _httpClient;

  Future<Map<String, String>> _headers() async {
    final accessToken = await accessTokenProvider();
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<Uri> createConnectUrl({
    required String workspaceId,
    required String platform,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$apiBaseUrl/mobile/social-accounts/zernio/connect'),
      headers: await _headers(),
      body: jsonEncode({
        'workspaceId': workspaceId,
        'platform': platform,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to start social connect: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final authUrl = data['authUrl'] as String?;

    if (authUrl == null || authUrl.isEmpty) {
      throw Exception('Backend did not return authUrl');
    }

    return Uri.parse(authUrl);
  }

  Future<List<SocialAccount>> syncAccounts({
    required String workspaceId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$apiBaseUrl/mobile/social-accounts/zernio/sync'),
      headers: await _headers(),
      body: jsonEncode({
        'workspaceId': workspaceId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync social accounts: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['socialAccounts'] as List<dynamic>? ?? const [];

    return items
        .cast<Map<String, dynamic>>()
        .map(SocialAccount.fromJson)
        .toList();
  }

  Future<List<SocialAccount>> listAccounts({
    required String workspaceId,
  }) async {
    final uri = Uri.parse('$apiBaseUrl/mobile/social-accounts').replace(
      queryParameters: {
        'workspaceId': workspaceId,
      },
    );

    final response = await _httpClient.get(
      uri,
      headers: await _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load social accounts: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['socialAccounts'] as List<dynamic>? ?? const [];

    return items
        .cast<Map<String, dynamic>>()
        .map(SocialAccount.fromJson)
        .toList();
  }

  Future<void> connectPlatform({
    required String workspaceId,
    required String platform,
  }) async {
    final authUrl = await createConnectUrl(
      workspaceId: workspaceId,
      platform: platform,
    );

    final launched = await launchUrl(
      authUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      throw Exception('Could not open social connect browser');
    }
  }
}
```

## Suggested UI Flow

The callback URL currently points to the backend, not a mobile deep link. That
means the browser may finish on a backend JSON response page. The mobile app
should refresh accounts when the app resumes or when the user taps a "Done"
button after completing the browser flow.

Example stateful screen behavior:

```dart
class ConnectSocialController with WidgetsBindingObserver {
  ConnectSocialController({
    required this.api,
    required this.workspaceId,
  });

  final ZernioSocialApi api;
  final String workspaceId;
  bool _connectStarted = false;

  Future<void> connectInstagram() async {
    _connectStarted = true;

    await api.connectPlatform(
      workspaceId: workspaceId,
      platform: 'INSTAGRAM',
    );
  }

  Future<List<SocialAccount>> refreshAfterConnectIfNeeded() async {
    if (!_connectStarted) {
      return api.listAccounts(workspaceId: workspaceId);
    }

    final synced = await api.syncAccounts(workspaceId: workspaceId);
    _connectStarted = false;

    if (synced.isNotEmpty) {
      return synced;
    }

    return api.listAccounts(workspaceId: workspaceId);
  }
}
```

In a real widget, call `refreshAfterConnectIfNeeded()` from:

```text
AppLifecycleState.resumed
```

or after the user returns from the browser and taps "Done".

## Basic Account Tile Example

```dart
import 'package:flutter/material.dart';

class SocialAccountTile extends StatelessWidget {
  const SocialAccountTile({
    super.key,
    required this.account,
  });

  final SocialAccount account;

  @override
  Widget build(BuildContext context) {
    final username = account.username;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: account.profilePictureUrl == null
            ? null
            : NetworkImage(account.profilePictureUrl!),
        child: account.profilePictureUrl == null
            ? Text(account.platform.substring(0, 1))
            : null,
      ),
      title: Text(account.displayName),
      subtitle: Text(
        username == null || username.isEmpty
            ? account.platform
            : '@$username',
      ),
      trailing: account.isActive
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.error_outline, color: Colors.orange),
    );
  }
}
```

## Error Handling

Handle these cases in the mobile app:

```text
401 Unauthorized
```

Refresh the PostFlow access token or send the user back to login.

```text
404 Workspace not found
```

The `workspaceId` is missing, stale, or not owned by the signed-in user.

```text
500 Zernio API key is not configured
```

Backend environment issue. Show a generic error and report it.

```text
Browser opened but account does not appear after sync
```

Show a retry action that calls `/mobile/social-accounts/zernio/sync`, then
reloads `/mobile/social-accounts`.

## What Not To Do

Do not call:

```text
https://zernio.com/api/...
```

from Flutter.

Do not store:

```text
Instagram access token
Facebook access token
TikTok access token
Zernio API key
Zernio webhook secret
```

in the mobile app.

Do not send platform login credentials to PostFlow. The user logs into the
platform inside the browser flow generated by Zernio.

## Next Backend Work For Publishing

Social account connection and sync are ready. Publishing through Zernio is the
next backend step.

When that is implemented, the mobile app should continue selecting local
`SocialAccount.id` values. The backend will use each account's
`zernioAccountId` to publish through Zernio.

Expected later behavior:

```text
Create or schedule post in PostFlow
Backend sends post to Zernio
Zernio publishes to selected platforms
Zernio sends post.* webhooks
Backend updates PostFlow post status
Flutter refreshes post status from PostFlow
```

The mobile app should not send `zernioAccountId` directly unless a future
PostFlow endpoint explicitly requires it.
