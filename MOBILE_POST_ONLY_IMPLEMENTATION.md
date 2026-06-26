# Mobile Post Implementation

This file covers only post creation, media upload, scheduling, platform rules,
and TikTok photo auto-music behavior for Flutter.

## Current TikTok Sound Support

The active backend publishing path uses Zernio. Zernio supports TikTok
photo-post automatic recommended music through `auto_add_music`, but it does
not support selecting a TikTok sound/music library item by song ID.

That means Flutter should show an auto-music toggle for TikTok image/photo
posts. Flutter should not show a selectable TikTok sound picker for the current
Zernio-backed publish flow.

## TikTok Image Auto Music

For TikTok image/photo posts, use:

```json
{
  "publishOptions": {
    "autoAddMusic": true
  }
}
```

This is stored on the post's TikTok platform target as:

```text
PostPlatform.publishOptions
```

For TikTok image/photo posts, `autoAddMusic` defaults to `true` when Flutter
does not send it.

Flutter can show this UI for TikTok image posts:

```text
TikTok photo music
[x] Auto-add recommended music
```

Flutter cannot preview the exact TikTok-selected automatic music, because TikTok
chooses it during posting.

Flutter should not download, cache, or play a placeholder track for this
setting. That would make the user think a specific song is guaranteed, but
Zernio/TikTok only guarantees that TikTok will try to add recommended music at
publish time.

Recommended Flutter copy:

```text
Auto-add recommended TikTok music
TikTok chooses the sound when the post is published.
```

Recommended Flutter behavior:

- Show this only when the selected platform includes TikTok and the media is
  image-only.
- Default the toggle to on.
- Send `publishOptions.autoAddMusic`.
- Hide this for TikTok video posts.
- Hide this when media mixes image and video, because TikTok mixed media is not
  allowed.
- Do not show a play button, waveform, selected song name, or cached audio file
  for this setting.

## TikTok Video Sounds

Selected TikTok video sounds are not active in the current backend because
Zernio cannot publish a selected TikTok library sound or `songClipId`. The
backend rejects `songClipId` and `soundProvider` in post `publishOptions`.

If we later want playable, selectable sounds in Flutter, we need a separate
publishing path that can actually consume that selected sound, such as
bundle.social for TikTok-specific video publishing or direct TikTok CML access.
Until then, do not show a TikTok sound picker for Zernio-backed publishing.

## Mobile Endpoints

Use these endpoints from Flutter:

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

All requests require:

```text
Authorization: Bearer <accessToken>
```

## Upload Media

If the post has images or videos, Flutter uploads originals to Cloudinary first.

Request upload signature:

```http
POST /mobile/media/upload-signature
```

```json
{
  "workspaceId": "workspace_id",
  "platform": "INSTAGRAM"
}
```

`platform` is optional. If omitted, backend uses `general`.

Backend returns the Cloudinary upload folder:

```text
postflow/accounts/{userId}/workspaces/{workspaceId}/platforms/{platform}
```

Flutter uploads the original file directly to Cloudinary with the returned
signature fields.

Then register the upload:

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
  "durationSec": 12
}
```

Keep the returned `id`. That is the `mediaAssetId`.

## Create Text Post

Text-only posts require `caption`.

```http
POST /mobile/posts
```

```json
{
  "workspaceId": "workspace_id",
  "caption": "Text-only post",
  "hashtags": ["postflow", "launch"],
  "platforms": [
    { "platform": "FACEBOOK", "accountId": "facebook_account_id" },
    { "platform": "LINKEDIN", "accountId": "linkedin_account_id" },
    { "platform": "X", "accountId": "x_account_id" },
    { "platform": "THREADS", "accountId": "threads_account_id" }
  ]
}
```

Text-only is not valid for Instagram, TikTok, or YouTube.

## Create Image Post

Image posts can have optional `caption` and optional `hashtags`.

```json
{
  "workspaceId": "workspace_id",
  "caption": "Optional image caption",
  "hashtags": ["photo", "brand"],
  "mediaAssetIds": ["image_media_id_1", "image_media_id_2"],
  "platforms": [
    { "platform": "INSTAGRAM", "accountId": "instagram_account_id" },
    { "platform": "FACEBOOK", "accountId": "facebook_account_id" },
    { "platform": "THREADS", "accountId": "threads_account_id" }
  ]
}
```

Flutter must submit `mediaAssetIds` in the final display order selected by the
user. Backend stores the order as `displayOrder`.

## Create TikTok Image Post With Auto Music

```json
{
  "workspaceId": "workspace_id",
  "caption": "TikTok photo mode post",
  "hashtags": ["photo", "tiktok"],
  "mediaAssetIds": ["image_media_id_1", "image_media_id_2"],
  "platforms": [
    {
      "platform": "TIKTOK",
      "accountId": "tiktok_account_id",
      "publishOptions": {
        "autoAddMusic": true
      }
    }
  ]
}
```

If `autoAddMusic` is omitted for a TikTok image post, backend stores it as
`true`.

## Create Video Post

```json
{
  "workspaceId": "workspace_id",
  "caption": "Optional video caption",
  "hashtags": ["video"],
  "mediaAssetIds": ["video_media_id"],
  "platforms": [
    { "platform": "TIKTOK", "accountId": "tiktok_account_id" },
    { "platform": "YOUTUBE", "accountId": "youtube_account_id" },
    { "platform": "INSTAGRAM", "accountId": "instagram_account_id" }
  ]
}
```

YouTube requires exactly one video and rejects images.

## Schedule On Create

```json
{
  "workspaceId": "workspace_id",
  "caption": "Scheduled post",
  "mediaAssetIds": ["media_id"],
  "platforms": [
    { "platform": "INSTAGRAM", "accountId": "instagram_account_id" }
  ],
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

## Schedule Existing Draft

```http
POST /mobile/posts/:postId/schedule
```

```json
{
  "scheduledAt": "2026-06-20T15:00:00.000Z"
}
```

## Platform Validation Matrix

| Platform | Text only | Images | Videos | Mixed image/video |
|---|---:|---:|---:|---:|
| Instagram | No | 1-10 | 1-10 | Yes, up to 10 total |
| Facebook | Yes | Up to 10 | 1 video | No |
| TikTok | No | 1-35 | 1 video | No |
| YouTube | No | No | 1 video | No |
| LinkedIn | Yes | Up to 20 | 1 video | No |
| X | Yes | Up to 4 | 1 video | No |
| Threads | Yes | Up to 10 | 1 video | No |

Flutter should mirror these rules in the UI before calling the backend.

These rules were checked against Zernio platform docs for the platforms PostFlow
currently accepts: Instagram, Facebook, TikTok, YouTube, LinkedIn, X/Twitter,
and Threads.

## Zernio Fields Still Needed For Real Publishing

The current create-post API stores the draft, media order, target platforms,
schedule, hashtags, and TikTok photo `autoAddMusic`. When wiring actual Zernio
publishing, add a platform-options layer for fields Zernio requires or strongly
expects:

| Platform | Needed later |
|---|---|
| TikTok | creator info lookup, account-specific `privacy_level`, consent flags, comment/duet/stitch toggles, `media_type: "photo"` for photo posts, `auto_add_music` for photo posts |
| YouTube | title, visibility, thumbnail, made-for-kids/COPPA, tags/category if required by product |
| Instagram | content type selection for feed/story/reels, reel feed sharing, optional first comment, thumbnails/audio name where applicable |
| Facebook | optional page-specific settings, carousel card metadata if product-style link carousels are added |
| LinkedIn | optional organization targeting, first comment, document settings if document posts are added |
| X | caption shortening/custom content for 280-character free accounts, GIF-vs-image distinction if GIF posting is added |
| Threads | 500-character caption limit, thread sequence support if multi-post threads are added |

Media URLs sent to Zernio must be public direct media URLs. Cloudinary URLs from
our media registration flow satisfy that requirement; Google Drive, Dropbox,
OneDrive, and similar preview-page links should not be sent as media URLs.

## Flutter UI Rules

- Text-only post: disable Instagram, TikTok, and YouTube.
- If selected media includes images: disable YouTube.
- If selected media mixes image and video: disable TikTok, Facebook, LinkedIn, X, and Threads.
- If platform is X: allow max 4 images or 1 video.
- If platform is Facebook or Threads: allow max 10 images or 1 video.
- If platform is LinkedIn: allow max 20 images or 1 video.
- If platform is Instagram: allow max 10 media assets and may mix images/videos.
- If platform is TikTok image post: allow max 35 images and show auto music toggle.
- If platform is YouTube: allow exactly 1 video.

## Optimized Preview

Use:

```http
GET /mobile/media/:mediaAssetId/variants
```

Use `optimizedOriginalUrl` for general previews. Use `variants` for
platform-specific preview screens. The original Cloudinary upload is preserved.
