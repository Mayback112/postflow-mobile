# Mobile Post Creation Handoff

This is the current Flutter contract for manually creating and scheduling posts.
Use only `/mobile` endpoints from the app.

## Endpoints

```text
POST /mobile/media/upload-signature
POST /mobile/media
GET  /mobile/media/:mediaAssetId/variants
POST /mobile/posts
PATCH /mobile/posts/:postId
POST /mobile/posts/:postId/schedule
POST /mobile/posts/:postId/cancel
POST /mobile/posts/:postId/publish-now
```

All endpoints require:

```text
Authorization: Bearer <accessToken>
```

## Create Flow

1. User chooses platform/account targets.
2. User chooses content type:
   - text only
   - image/images
   - video
   - mixed media where the target platforms allow it
3. If media exists, Flutter uploads originals to Cloudinary.
4. Flutter registers each upload with the backend.
5. Flutter lets the user reorder selected media.
6. Flutter creates the post with ordered `mediaAssetIds`.
7. Flutter either sends `scheduledAt` in create or calls `/schedule` later.

## Media Upload

Request a Cloudinary upload signature:

```json
{
  "workspaceId": "workspace_id",
  "platform": "INSTAGRAM"
}
```

`platform` is optional. If omitted, backend uses `general`.

Cloudinary folder structure:

```text
postflow/accounts/{userId}/workspaces/{workspaceId}/platforms/{platform}
```

Flutter uploads the original image/video directly to Cloudinary using the returned signature and upload params. The backend preserves the original asset and generates optimized delivery variants with automatic quality/format transforms.

Register each uploaded media asset:

```json
{
  "workspaceId": "workspace_id",
  "cloudinaryId": "postflow/accounts/user_id/workspaces/workspace_id/platforms/instagram/public_id",
  "secureUrl": "https://res.cloudinary.com/.../upload/...",
  "resourceType": "image",
  "width": 1080,
  "height": 1080,
  "durationSec": 12
}
```

Keep each returned media `id`. Those IDs become `mediaAssetIds`.

## Create Post

Text-only:

```json
{
  "workspaceId": "workspace_id",
  "caption": "Today we launched something new.",
  "hashtags": ["launch", "smallbusiness"],
  "platforms": [
    { "platform": "FACEBOOK", "accountId": "social_account_id" }
  ]
}
```

Media post:

```json
{
  "workspaceId": "workspace_id",
  "caption": "Optional caption",
  "hashtags": ["launch", "postflow"],
  "mediaAssetIds": ["media_1", "media_2", "media_3"],
  "platforms": [
    { "platform": "INSTAGRAM", "accountId": "social_account_id" }
  ]
}
```

Create and schedule in one call:

```json
{
  "workspaceId": "workspace_id",
  "caption": "Scheduled launch post",
  "mediaAssetIds": ["media_1"],
  "platforms": [
    { "platform": "INSTAGRAM", "accountId": "social_account_id" }
  ],
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

Schedule an existing draft:

```json
{
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

Send that to:

```text
POST /mobile/posts/:postId/schedule
```

## Hashtags

`hashtags` is optional.

If Flutter has a separate hashtags field, send:

```json
{
  "hashtags": ["launch", "postflow"]
}
```

If Flutter does not use a separate hashtags field, leave `hashtags` out and keep hashtags inside `caption`.

## Media Ordering

Flutter should let users reorder selected media before submitting.

Submit final order as:

```json
{
  "mediaAssetIds": ["first_media_id", "second_media_id", "third_media_id"]
}
```

Backend stores that order as `displayOrder`.

## Platform Rules

Backend enforces these rules on create and update:

| Platform | Text only | Images | Videos | Mixed image/video |
|---|---:|---:|---:|---:|
| Instagram | No | 1-10 | 1-10 | Yes, up to 10 total |
| Facebook | Yes | Up to 10 | 1 video | No |
| TikTok | No | 1-35 | 1 video | No |
| YouTube | No | No | 1 video | No |
| LinkedIn | Yes | Up to 20 | 1 video | No |
| X | Yes | Up to 4 | 1 video | No |
| Threads | Yes | Up to 10 | 1 video | No |

Flutter should mirror this in the UI:

- Disable Instagram, TikTok, and YouTube for text-only posts.
- Disable YouTube when any selected media is an image.
- Disable TikTok, Facebook, LinkedIn, X, and Threads when selected media mixes images and videos.
- Limit X image selection to 4.
- Limit Facebook and Threads image selection to 10.
- Limit LinkedIn image selection to 20.
- Limit Instagram carousel selection to 10; Instagram can mix images and videos.
- Limit TikTok image selection to 35.
- Limit YouTube, Facebook, LinkedIn, X, and TikTok video posts to one video.

## TikTok Photo Music

For TikTok image/photo posts, backend supports:

```json
{
  "platform": "TIKTOK",
  "accountId": "social_account_id",
  "publishOptions": {
    "autoAddMusic": true
  }
}
```

`autoAddMusic` defaults to `true` for TikTok image posts if omitted.

Important: Zernio supports automatic recommended music for TikTok photo posts through `auto_add_music`, but it does not support selecting a TikTok sound/music library item by song ID. That means Flutter cannot preview or choose the exact TikTok-selected sound for the current Zernio-backed publish flow.

Flutter UI should show this as a toggle, not a sound picker:

```text
TikTok photo music
[x] Auto-add recommended music
```

Flutter should not download, cache, or play a placeholder music file for this
toggle. Zernio/TikTok chooses the recommended sound at publish time, so a local
preview would not be a guaranteed match.

If we want users to preview and select sounds inside Flutter, that needs a separate future publishing path that can actually consume the selected sound, such as bundle.social for TikTok-specific video publishing or direct TikTok CML access. That is not active in the Zernio-backed flow.

## Optimized Media Preview

To preview optimized media:

```text
GET /mobile/media/:mediaAssetId/variants
```

Response includes:

- `originalUrl`
- `optimizedOriginalUrl`
- platform-sized `variants`

Use `optimizedOriginalUrl` for general previews and platform variants for platform preview screens.
