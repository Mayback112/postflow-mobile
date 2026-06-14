# Environment Configuration

Use Flutter's native define file support for mobile-safe app configuration:

```sh
flutter run --dart-define-from-file=env/mobile.dev.json
```

`env/mobile.dev.json` may contain public mobile values such as `API_BASE_URL`,
`GOOGLE_OAUTH_CLIENT_IDS`, and `GOOGLE_REDIRECT_URL`.

The Google OAuth client ID used by the app must match:

```text
env/client_secret_805427396737-9va66tb42nqbmue2mofdnv1df97eubp4.apps.googleusercontent.com(3).json
```

That file is a Google installed/mobile OAuth client JSON. Its
`installed.client_id` is:

```text
805427396737-9va66tb42nqbmue2mofdnv1df97eubp4.apps.googleusercontent.com
```

For the Android debug build, the Google OAuth client should be configured with:

- Package name: `com.postflow.app`
- SHA-1: `00:80:0A:79:3A:32:E6:AA:BD:9C:2C:9F:6F:0E:EF:7E:A4:43:BE:2D`
- Redirect URL used by AppAuth: `com.postflow.app:/oauth2redirect/google`

Do not put `GOOGLE_OAUTH_CLIENT_SECRET` in Flutter config. Mobile apps are
public clients, so anything included in a `.env`, JSON define file, asset, or
compiled binary can be extracted from the app. Keep the Google OAuth client
secret only in the backend environment. The current Google installed/mobile
client JSON does not include a `client_secret`.
