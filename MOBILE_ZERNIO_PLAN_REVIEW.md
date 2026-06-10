# Mobile Zernio Plan Review

Status: approved with small changes.

The Flutter plan is directionally correct. The mobile app should connect social
platforms through the PostFlow backend only. It should not call Zernio directly
and should not store any Zernio API key, webhook secret, or platform access
tokens.

## Required Change: Workspace ID Handling

The blocker is resolved.

Flutter should get `workspaceId` from the existing backend workspace endpoint:

```text
GET /mobile/workspaces
Authorization: Bearer <jwt_access_token>
```

Recommended behavior:

1. After login, call `GET /mobile/workspaces`.
2. If the app has a previously selected workspace ID in local/secure storage,
   use it only if it still exists in the returned list.
3. If no stored workspace exists, use the first workspace from the returned
   list.
4. If the list is empty, create one:

```text
POST /mobile/workspaces
Authorization: Bearer <jwt_access_token>
Content-Type: application/json
```

```json
{
  "name": "Default Workspace"
}
```

5. Store the selected workspace ID locally for convenience.
6. Revalidate the stored workspace ID on each fresh app start.

Do not hardcode a dev workspace ID except for a short manual debugging session.

## Approved Parts

The following plan items are approved:

1. Add `url_launcher` to `pubspec.yaml`.
2. Add API methods for:

```text
POST /mobile/social-accounts/zernio/connect
POST /mobile/social-accounts/zernio/sync
GET /mobile/social-accounts?workspaceId=<workspaceId>
```

3. Add `SocialAccount` model with:

```text
id
workspaceId
platform
displayName
provider
isActive
username
profilePictureUrl
profileUrl
zernioAccountId
```

4. Add platform mapping:

```text
Instagram -> INSTAGRAM
Facebook -> FACEBOOK
TikTok -> TIKTOK
YouTube -> YOUTUBE
LinkedIn -> LINKEDIN
X -> X
Threads -> THREADS
```

5. Add `SocialAccountService` that:

```text
gets access token from AuthTokenStorage
calls PostFlow connect endpoint
opens returned authUrl with url_launcher
calls sync endpoint
lists connected accounts
maps JSON into SocialAccount
```

6. Replace fake platform state with real account data.
7. Open Zernio auth URL in an external browser.
8. Sync accounts after the browser flow finishes or when the app resumes.
9. Display connected account metadata in the platform tiles.
10. Run `flutter pub get`, `dart format`, `flutter analyze`, and tests.

## Changes To Make Before Coding

### 1. Add Workspace API Support

The plan mentions workspace handling but should explicitly include API support
for:

```text
GET /mobile/workspaces
POST /mobile/workspaces
```

Add a small workspace model or helper if the app does not already have one.

Minimum model fields:

```text
id
name
ownerId
zernioProfileId
createdAt
updatedAt
```

Only `id` and `name` are required for the social connect flow.

### 2. Use External Browser, Not Embedded Credentials

The connect flow should use:

```dart
LaunchMode.externalApplication
```

Do not build any username/password login form for Instagram, Facebook, TikTok,
or other social platforms. The platform login happens inside the URL returned by
the backend.

### 3. Do Not Implement Delete Unless The UI Needs It Now

`DELETE /mobile/social-accounts/:id` exists, but it only removes the local
PostFlow record when it is not used by posts. It is not a full Zernio/platform
disconnect flow.

Recommendation: skip remove-account UI for the first wiring pass unless the
screen already has a delete action.

### 4. Refresh Strategy

Because the current Zernio callback URL returns to the backend, not a mobile
deep link, the app should support both:

```text
AppLifecycleState.resumed -> sync/list accounts
Manual Done button -> sync/list accounts
```

This avoids getting stuck if the browser ends on a backend JSON response page.

### 5. Account Matching Per Platform

When rendering platform tiles, find the account by platform:

```text
account.platform == backendPlatformEnum
```

If multiple accounts for the same platform appear later, show the active one
first. For now, one account per platform tile is fine.

## Final Implementation Order

Recommended coding order:

1. Add `url_launcher`.
2. Add workspace fetch/create support.
3. Add `SocialAccount` model.
4. Add social account API/service methods.
5. Wire Platforms screen loading state.
6. Wire Connect button to open `authUrl`.
7. Add app-resume or Done-button sync.
8. Update platform tiles with real account metadata.
9. Add retry sync button for the no-account-after-browser case.
10. Run formatting, analysis, tests, and manual emulator test.

## Acceptance Criteria

The implementation is acceptable when:

```text
local test login works
workspaceId is loaded or created from /mobile/workspaces
platforms screen loads without fake connected state
Connect Instagram calls /mobile/social-accounts/zernio/connect
browser opens with returned authUrl
returning to app triggers /mobile/social-accounts/zernio/sync
GET /mobile/social-accounts refreshes the UI
connected account shows displayName, @username, avatar, and status
Flutter does not call Zernio directly
Flutter does not store platform tokens or Zernio secrets
```

