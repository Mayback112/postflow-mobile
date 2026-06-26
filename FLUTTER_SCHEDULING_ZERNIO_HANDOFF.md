# Flutter Scheduling And Zernio Handoff

This document explains the scheduling changes Flutter needs to know about.

The short version: Flutter still schedules posts through the PostFlow backend. PostFlow now sends scheduled posts to Zernio immediately, and Zernio owns the real publish execution.

Flutter must not call Zernio directly.

## Base URL

Use the existing mobile API base URL:

```text
Android emulator: http://10.0.2.2:4000
iOS simulator: http://localhost:4000
Physical device: machine LAN IP or HTTPS tunnel
```

All scheduling/post endpoints require:

```text
Authorization: Bearer <accessToken>
Content-Type: application/json
```

## What Changed

Before:

- PostFlow stored `scheduledAt`.
- BullMQ woke up later and published from PostFlow.

Now:

- PostFlow still stores `scheduledAt`.
- PostFlow sends the scheduled post to Zernio immediately.
- Zernio stores the remote scheduled post and handles publish timing.
- PostFlow stores `zernioPostId`.
- Zernio webhooks update PostFlow status after scheduled/published/failed events.
- Flutter reads all display state from PostFlow, not from Zernio.

## Flutter Rule

Flutter should keep using these existing mobile endpoints:

```text
POST  /mobile/posts
PATCH /mobile/posts/:postId
POST  /mobile/posts/:postId/schedule
POST  /mobile/posts/:postId/cancel
POST  /mobile/posts/:postId/publish-now
GET   /mobile/posts?workspaceId=:workspaceId
GET   /mobile/posts/:postId
GET   /mobile/posts/:postId/publish-attempts
```

Do not add Zernio API calls to Flutter.

## Required Preconditions

Before Flutter schedules or publishes a real post:

1. User must be authenticated.
2. Flutter must have a valid `workspaceId`.
3. User must have selected connected social accounts.
4. The selected social accounts should come from:

```text
GET /mobile/social-accounts?workspaceId=:workspaceId
```

For real publishing, accounts should have:

```json
{
  "provider": "ZERNIO",
  "zernioAccountId": "zernio_account_id",
  "isActive": true
}
```

Flutter sends the local PostFlow social account `id` as `accountId`, not `zernioAccountId`.

## Create Scheduled Post

Flutter can schedule during post creation by sending `scheduledAt`.

```http
POST /mobile/posts
Authorization: Bearer <accessToken>
Content-Type: application/json
```

Request:

```json
{
  "workspaceId": "workspace_id",
  "caption": "Scheduled launch post",
  "hashtags": ["launch", "postflow"],
  "mediaAssetIds": ["media_id_1"],
  "platforms": [
    {
      "platform": "INSTAGRAM",
      "accountId": "local_social_account_id"
    }
  ],
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

Success response includes:

```json
{
  "id": "post_id",
  "workspaceId": "workspace_id",
  "zernioPostId": "zernio_post_id",
  "status": "SCHEDULED",
  "caption": "Scheduled launch post",
  "hashtags": ["launch", "postflow"],
  "scheduledAt": "2026-06-20T15:00:00.000Z",
  "publishedAt": null,
  "failureReason": null,
  "mediaAssets": [],
  "platforms": [
    {
      "id": "post_platform_id",
      "platform": "INSTAGRAM",
      "accountId": "local_social_account_id",
      "accountName": "Brand Instagram",
      "accountUsername": "brand",
      "status": "SCHEDULED",
      "publishOptions": null,
      "errorMessage": null,
      "publishedAt": null,
      "remotePostId": null,
      "platformPostUrl": null
    }
  ]
}
```

`zernioPostId` can be shown in debug/admin tools, but normal UI does not need to display it.

## Schedule Existing Draft

```http
POST /mobile/posts/:postId/schedule
Authorization: Bearer <accessToken>
Content-Type: application/json
```

Request:

```json
{
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

Success response is the updated post object.

Backend behavior:

- Validates `scheduledAt` is in the future.
- Cancels any previous remote Zernio scheduled post for that local post.
- Creates a new scheduled post in Zernio.
- Stores the new `zernioPostId`.
- Schedules local reminder notification jobs.

## Edit Scheduled Post

Use the existing update endpoint:

```http
PATCH /mobile/posts/:postId
Authorization: Bearer <accessToken>
Content-Type: application/json
```

Example:

```json
{
  "caption": "Updated scheduled caption",
  "hashtags": ["updated"],
  "mediaAssetIds": ["media_id_1", "media_id_2"],
  "platforms": [
    {
      "platform": "INSTAGRAM",
      "accountId": "local_social_account_id"
    }
  ],
  "scheduledAt": "2026-06-21T15:00:00.000Z"
}
```

Backend behavior:

- Cancels the old Zernio scheduled post if one exists.
- Updates the local post.
- Creates a new Zernio scheduled post.
- Updates local `zernioPostId`.
- Reschedules the reminder job.

Flutter does not need special Zernio handling for edit.

## Unschedule Post

To turn a scheduled post back into a draft:

```http
PATCH /mobile/posts/:postId
Authorization: Bearer <accessToken>
Content-Type: application/json
```

Request:

```json
{
  "scheduledAt": null
}
```

Backend behavior:

- Cancels the remote Zernio scheduled post.
- Clears local `scheduledAt`.
- Clears local `zernioPostId`.
- Marks local post as `DRAFT`.
- Cancels the reminder job.

## Cancel Scheduled Post

If the user explicitly cancels instead of returning to draft:

```http
POST /mobile/posts/:postId/cancel
Authorization: Bearer <accessToken>
```

Backend behavior:

- Cancels the remote Zernio post when one exists.
- Sets local post status to `CANCELED`.
- Clears local `scheduledAt`.
- Cancels the reminder job.

Use this when the user chooses a destructive/cancel action.

Use `PATCH scheduledAt: null` when the user wants to keep editing the post as a draft.

## Publish Now

```http
POST /mobile/posts/:postId/publish-now
Authorization: Bearer <accessToken>
```

Backend behavior:

- Cancels existing remote scheduled post if one exists.
- Cancels local reminder job.
- Sends `publishNow: true` to Zernio.
- Updates local status from the Zernio response.
- Webhooks later reconcile final status.

## Delete Post

```http
DELETE /mobile/posts/:postId
Authorization: Bearer <accessToken>
```

Backend behavior:

- Cancels remote Zernio scheduled post if one exists.
- Cancels local reminder job.
- Deletes the local PostFlow post.

Published or publishing posts cannot be deleted.

## Status Values Flutter Should Handle

Post-level `status`:

```text
DRAFT
SCHEDULED
PUBLISHING
PUBLISHED
FAILED
CANCELED
```

Platform-level `platforms[].status`:

```text
DRAFT
SCHEDULED
PUBLISHING
PUBLISHED
FAILED
CANCELED
```

Recommended UI:

- `DRAFT`: editable draft.
- `SCHEDULED`: show scheduled time, allow edit/reschedule/cancel.
- `PUBLISHING`: show progress/loading state, disable destructive edits.
- `PUBLISHED`: show published timestamp and platform links when available.
- `FAILED`: show `failureReason` or platform `errorMessage`, allow retry later when backend exposes retry.
- `CANCELED`: show canceled state, usually read-only or allow duplicate/create-new.

## Platform URLs

After Zernio publishes, platform rows may include:

```json
{
  "remotePostId": "platform_native_post_id",
  "platformPostUrl": "https://platform.example/post/123",
  "publishedAt": "2026-06-20T15:00:05.000Z"
}
```

Flutter should display `platformPostUrl` as an "Open post" action when present.

Do not assume it is available immediately for scheduled posts. It is usually populated after publish time through Zernio response or webhook.

## Scheduled List

To show scheduled posts:

```http
GET /mobile/posts?workspaceId=workspace_id&status=SCHEDULED
Authorization: Bearer <accessToken>
```

To show drafts:

```http
GET /mobile/posts?workspaceId=workspace_id&status=DRAFT
Authorization: Bearer <accessToken>
```

To show published:

```http
GET /mobile/posts?workspaceId=workspace_id&status=PUBLISHED
Authorization: Bearer <accessToken>
```

## Refreshing Status

Flutter should refresh post data:

- after creating/scheduling/editing/canceling/publish-now
- when returning to the post list
- when opening a post detail
- after receiving a push notification with `postId`

The backend receives Zernio webhooks and updates local status. Flutter only reads PostFlow.

## Error Cases Flutter Should Handle

Past scheduled time:

```json
{
  "message": "scheduledAt must be a future date"
}
```

Missing or mismatched account:

```json
{
  "message": "One or more social accounts were not found"
}
```

Account platform mismatch:

```json
{
  "message": "Social account platform does not match post platform"
}
```

Zernio not configured:

```json
{
  "message": "Zernio API key is not configured"
}
```

Zernio rejected post:

```json
{
  "message": "Zernio request failed (...)"
}
```

Flutter should show a human-readable error and let the user retry after editing the post/account selection.

## Important UX Notes

- Always show times in the user's local timezone.
- Send `scheduledAt` to the backend as ISO 8601 UTC or a valid ISO datetime.
- Do not show `zernioPostId` in normal user UI.
- Use local PostFlow `post.id` for navigation and state management.
- Use local PostFlow social account `id` when creating/scheduling.
- Do not send `zernioAccountId` from Flutter unless a future backend contract says so.
- For scheduled posts, platform URLs may be null until after publish.
- For failed posts, read both post `failureReason` and platform `errorMessage`.

## Request Examples

Create scheduled post:

```dart
Future<Map<String, dynamic>> createScheduledPost({
  required String apiBaseUrl,
  required String accessToken,
  required String workspaceId,
  required String caption,
  required List<String> mediaAssetIds,
  required List<Map<String, dynamic>> platforms,
  required DateTime scheduledAt,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/mobile/posts'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'workspaceId': workspaceId,
      'caption': caption,
      'mediaAssetIds': mediaAssetIds,
      'platforms': platforms,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to create scheduled post: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}
```

Schedule existing draft:

```dart
Future<Map<String, dynamic>> schedulePost({
  required String apiBaseUrl,
  required String accessToken,
  required String postId,
  required DateTime scheduledAt,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/mobile/posts/$postId/schedule'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to schedule post: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}
```

Cancel scheduled post:

```dart
Future<Map<String, dynamic>> cancelPost({
  required String apiBaseUrl,
  required String accessToken,
  required String postId,
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/mobile/posts/$postId/cancel'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to cancel post: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}
```

List scheduled posts:

```dart
Future<List<dynamic>> fetchScheduledPosts({
  required String apiBaseUrl,
  required String accessToken,
  required String workspaceId,
}) async {
  final response = await http.get(
    Uri.parse('$apiBaseUrl/mobile/posts?workspaceId=$workspaceId&status=SCHEDULED'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch scheduled posts: ${response.body}');
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return body['posts'] as List<dynamic>;
}
```
