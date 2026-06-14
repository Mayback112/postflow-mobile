import 'package:postflow/api/api.dart';
import 'package:postflow/models/auth_models.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSession> signInWithGoogle(GoogleAuthRequest request) async {
    final response = await _apiClient.postJson(
      ApiEndpoint.authGoogle,
      request.toJson(),
      skipAuth: true,
    );
    return AuthSession.fromJson(response);
  }

  Future<AuthSession> sign(SignRequest request) async {
    final response = await _apiClient.postJson(
      ApiEndpoint.authSign,
      request.toJson(),
      skipAuth: true,
    );
    return AuthSession.fromJson(response);
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _apiClient.postJson(ApiEndpoint.authRefresh, {
      'refreshToken': refreshToken,
    }, skipAuth: true);
    return AuthSession.fromJson(response);
  }

  Future<void> logout(String refreshToken) async {
    await _apiClient.postJson(ApiEndpoint.authLogout, {
      'refreshToken': refreshToken,
    }, skipAuth: true);
  }

  Future<AuthUser> me() async {
    final response = await _apiClient.getJson(ApiEndpoint.authMe);
    return AuthUser.fromJson(response['user'] as Map<String, dynamic>);
  }
}
