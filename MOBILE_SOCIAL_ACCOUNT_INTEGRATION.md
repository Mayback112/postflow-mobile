# Mobile Social Account Integration Guide (V2)

This document outlines the consolidated social account API routes after removing obsolete providers. All social account connection and synchronization now route through **Postproxy** handlers.

## Summary of Changes
- Zernio and Postiz alias routes have been removed.
- All social account operations are now consolidated under the Postproxy API handlers.
- Specific `connect` and `sync` actions have been made public to support the initial OAuth flow.

## API Endpoint Reference

| Method | Endpoint | Auth Required | Handler |
| :--- | :--- | :--- | :--- |
| **POST** | `/mobile/social-accounts/zernio/connect` | **No** | `postproxyConnect` |
| **POST** | `/mobile/social-accounts/zernio/sync` | **No** | `postproxySync` |
| **POST** | `/mobile/social-accounts/postiz/connect` | **No** | `postproxyConnect` |
| **POST** | `/mobile/social-accounts/postiz/sync` | **No** | `postproxySync` |
| **POST** | `/mobile/social-accounts/postproxy/connect` | **No** | `postproxyConnect` |
| **POST** | `/mobile/social-accounts/postproxy/sync` | **No** | `postproxySync` |
| **GET** | `/mobile/social-accounts/` | **Yes** | `list` |
| **POST** | `/mobile/social-accounts/mock` | **Yes** | `mockConnect` |
| **GET** | `/mobile/social-accounts/postproxy/connection` | **Yes** | `postproxyConnection` |
| **GET** | `/mobile/social-accounts/:socialAccountId` | **Yes** | `get` |
| **DELETE** | `/mobile/social-accounts/:socialAccountId` | **Yes** | `remove` |

## Implementation Guidelines for Flutter

### 1. Request Headers
- **Public Routes:** Requests to the `/connect` and `/sync` endpoints listed as "No" in the Auth Required column **MUST NOT** include an `Authorization` header.
- **Authenticated Routes:** Requests to all other endpoints **MUST** include the `Authorization: Bearer <token>` header.

### 2. Implementation Example (Public Flow)

Use your networking client (e.g., Dio) to make these calls without the auth interceptor.

```dart
// Example using Dio
Future<void> connectSocialAccount(String workspaceId, String platform) async {
  // Use one of the public endpoints (e.g., postproxyConnect)
  // Ensure the Dio instance for this call does NOT use an auth interceptor.
  final response = await dioClient.post(
    '/mobile/social-accounts/postproxy/connect',
    data: {
      'workspaceId': workspaceId,
      'platform': platform,
    },
  );
  return response.data;
}
```

### 3. Implementation Example (Authenticated Flow)

```dart
// Example using Dio with Auth
Future<void> listSocialAccounts() async {
  // Ensure the Dio instance for this call USES the auth interceptor.
  final response = await authDioClient.get(
    '/mobile/social-accounts/',
  );
  return response.data;
}
```
