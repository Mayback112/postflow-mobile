import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:postflow/models/auth_models.dart';

class AuthTokenStorage {
  AuthTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'postflow_access_token';
  static const _refreshTokenKey = 'postflow_refresh_token';
  static const _userKey = 'postflow_auth_user';
  static const _selectedWorkspaceIdKey = 'postflow_selected_workspace_id';

  final FlutterSecureStorage _secureStorage;

  Future<void> save(AuthTokens tokens) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: tokens.refreshToken),
    ]);
  }

  Future<void> saveUser(AuthUser user) {
    return _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  Future<void> saveSession(AuthSession session) async {
    await Future.wait([save(session.tokens), saveUser(session.user)]);
  }

  Future<String?> readAccessToken() {
    return _secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<AuthUser?> readUser() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson == null || userJson.isEmpty) return null;

    final decoded = jsonDecode(userJson);
    if (decoded is! Map<String, dynamic>) return null;

    return AuthUser.fromJson(decoded);
  }

  Future<void> saveSelectedWorkspaceId(String workspaceId) {
    return _secureStorage.write(
      key: _selectedWorkspaceIdKey,
      value: workspaceId,
    );
  }

  Future<String?> readSelectedWorkspaceId() {
    return _secureStorage.read(key: _selectedWorkspaceIdKey);
  }

  Future<void> clear() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _userKey),
      _secureStorage.delete(key: _selectedWorkspaceIdKey),
    ]);
  }
}
