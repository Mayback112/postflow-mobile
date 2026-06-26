# Mobile Post List And Edit API

This file is the Flutter contract for rendering draft, scheduled, published,
failed, and canceled posts from the mobile API.

## Auth

Every request requires:

```text
Authorization: Bearer <accessToken>
```

## List Posts

```http
GET /mobile/posts?workspaceId=workspace_id
GET /mobile/posts?workspaceId=workspace_id&status=DRAFT
GET /mobile/posts?workspaceId=workspace_id&status=SCHEDULED
GET /mobile/posts?workspaceId=workspace_id&status=PUBLISHED
GET /mobile/posts?workspaceId=workspace_id&status=FAILED
GET /mobile/posts?workspaceId=workspace_id&status=CANCELED
```

`workspaceId` is required. `status` is optional.

Allowed status values:

```text
DRAFT
SCHEDULED
PUBLISHING
PUBLISHED
FAILED
CANCELED
```

Response:

```json
{
  "posts": [
    {
      "id": "post_id",
      "workspaceId": "workspace_id",
      "status": "SCHEDULED",
      "caption": "Post caption or text-only content",
      "hashtags": ["launch", "postflow"],
      "scheduledAt": "2026-06-20T15:00:00.000Z",
      "publishedAt": null,
      "createdAt": "2026-06-14T10:00:00.000Z",
      "updatedAt": "2026-06-14T10:00:00.000Z",
      "failureReason": null,
      "mediaAssets": [],
      "platforms": []
    }
  ]
}
```

## Get One Post

```http
GET /mobile/posts/:postId
```

Returns one post using the same post shape as the list endpoint.

## Media Asset Shape

Images:

```json
{
  "id": "media_id",
  "resourceType": "image",
  "secureUrl": "https://...",
  "optimizedOriginalUrl": "https://...",
  "thumbnailUrl": "https://...",
  "width": 1080,
  "height": 1080,
  "durationSec": null,
  "displayOrder": 0
}
```

Videos:

```json
{
  "id": "media_id",
  "resourceType": "video",
  "secureUrl": "https://...",
  "optimizedOriginalUrl": "https://...",
  "thumbnailUrl": "https://...",
  "width": 1080,
  "height": 1920,
  "durationSec": 12,
  "displayOrder": 0
}
```

Use `thumbnailUrl` for grid/list cards. Use `optimizedOriginalUrl` for preview
screens. Keep `secureUrl` as the original Cloudinary URL.

`mediaAssets` are always returned ordered by `displayOrder`.

## Platform Target Shape

```json
{
  "id": "post_platform_id",
  "platform": "INSTAGRAM",
  "accountId": "social_account_id",
  "accountName": "Brand Instagram",
  "accountUsername": "brand",
  "status": "SCHEDULED",
  "publishOptions": {
    "autoAddMusic": true
  },
  "errorMessage": null,
  "publishedAt": null,
  "remotePostId": null
}
```

Platform target statuses:

```text
DRAFT
SCHEDULED
PUBLISHING
PUBLISHED
FAILED
CANCELED
```

Use post-level `status` for the main card state. Use each platform target's
`status` and `errorMessage` to render platform chips and failed platform
messages.

## Create Post

```http
POST /mobile/posts
```

Text-only:

```json
{
  "workspaceId": "workspace_id",
  "caption": "Text-only post",
  "hashtags": ["launch", "postflow"],
  "platforms": [
    { "platform": "FACEBOOK", "accountId": "facebook_account_id" },
    { "platform": "LINKEDIN", "accountId": "linkedin_account_id" },
    { "platform": "X", "accountId": "x_account_id" },
    { "platform": "THREADS", "accountId": "threads_account_id" }
  ]
}
```

Media post:

```json
{
  "workspaceId": "workspace_id",
  "caption": "Optional caption",
  "hashtags": ["photo", "launch"],
  "mediaAssetIds": ["first_media_id", "second_media_id"],
  "platforms": [
    { "platform": "INSTAGRAM", "accountId": "instagram_account_id" },
    { "platform": "FACEBOOK", "accountId": "facebook_account_id" }
  ]
}
```

Scheduled on create:

```json
{
  "workspaceId": "workspace_id",
  "caption": "Scheduled caption",
  "mediaAssetIds": ["media_id"],
  "platforms": [
    { "platform": "INSTAGRAM", "accountId": "instagram_account_id" }
  ],
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

`scheduledAt` must be a future ISO date.

## TikTok Image Auto Music

For TikTok image-only posts:

```json
{
  "platform": "TIKTOK",
  "accountId": "tiktok_account_id",
  "publishOptions": {
    "autoAddMusic": true
  }
}
```

If omitted for TikTok image posts, backend defaults `autoAddMusic` to `true`.

Flutter should show this as a toggle only:

```text
Auto-add recommended TikTok music
TikTok chooses the sound when the post is published.
```

Do not show a sound picker, play button, cached audio, `songClipId`, or
`soundProvider` for the current Zernio flow. The backend rejects unsupported
sound picker fields.

## Edit Post

```http
PATCH /mobile/posts/:postId
```

Editable fields:

```json
{
  "caption": "Updated caption",
  "hashtags": ["updated", "postflow"],
  "mediaAssetIds": ["media_id_2", "media_id_1"],
  "platforms": [
    { "platform": "INSTAGRAM", "accountId": "instagram_account_id" }
  ],
  "scheduledAt": "2026-06-21T15:00:00.000Z"
}
```

Send only fields that changed. If `mediaAssetIds` is sent, the order in the
array becomes the new `displayOrder`.

To remove scheduling and return to draft:

```json
{
  "scheduledAt": null
}
```

Published or publishing posts cannot be edited.

## Schedule Existing Draft

```http
POST /mobile/posts/:postId/schedule
```

```json
{
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

Backend rejects past dates. Published and canceled posts cannot be scheduled.

## Cancel Scheduled Post

```http
POST /mobile/posts/:postId/cancel
```

Published posts cannot be canceled. Canceling updates the post and platform
targets to `CANCELED`.

## Publish Now

```http
POST /mobile/posts/:postId/publish-now
```

Publishing/canceled/published posts cannot be published again. The response
returns the updated post shape with platform statuses and errors.

## Media Upload Flow

1. Ask backend for a Cloudinary signature:

```http
POST /mobile/media/upload-signature
```

```json
{
  "workspaceId": "workspace_id",
  "platform": "INSTAGRAM"
}
```

2. Upload the file directly from Flutter to Cloudinary.
3. Register the upload:

```http
POST /mobile/media
```

```json
{
  "workspaceId": "workspace_id",
  "cloudinaryId": "postflow/accounts/user_id/workspaces/workspace_id/platforms/instagram/public_id",
  "secureUrl": "https://res.cloudinary.com/.../upload/...",
  "resourceType": "image",
  "width": 1080,
  "height": 1080,
  "durationSec": null
}
```

4. Use the returned media `id` in `mediaAssetIds`.

## Extra Media Variants

```http
GET /mobile/media/:mediaAssetId/variants
```

Use this when Flutter needs platform-specific preview crops beyond the list
thumbnail and optimized original URLs already returned in post responses.

## Backend Validation Flutter Should Mirror

- `workspaceId` is required.
- At least one platform target is required.
- Each `accountId` must belong to the workspace.
- Each `accountId` must match the submitted platform.
- Text-only posts require `caption`.
- Text-only is invalid for Instagram, TikTok, and YouTube.
- Media posts require valid `mediaAssetIds`.
- `mediaAssetIds` must belong to the workspace.
- YouTube requires exactly one video and no images.
- TikTok requires media, allows up to 35 images or one video, and does not allow mixed image/video media.
- Instagram requires media and allows up to 10 image/video/mixed media items.
- Facebook allows text, up to 10 images or one video, and does not allow mixed media.
- LinkedIn allows text, up to 20 images or one video, and does not allow mixed media.
- X allows text, up to 4 images or one video, and does not allow mixed media.
- Threads allows text, up to 10 images or one video, and does not allow mixed media.
- `scheduledAt` must be a future ISO date.
- TikTok image `autoAddMusic` defaults to `true`.
- `songClipId` and `soundProvider` are unsupported for the current Zernio flow.
