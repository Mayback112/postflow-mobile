import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:postflow/models/auth_models.dart';

class AuthTokenStorage {
  AuthTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'postflow_access_token';
  static const _refreshTokenKey = 'postflow_refresh_token';

  final FlutterSecureStorage _secureStorage;

  Future<void> save(AuthTokens tokens) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: tokens.refreshToken),
    ]);
  }

  Future<void> saveSession(AuthSession session) async {
    await save(session.tokens);
  }

  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> clear() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }
}
