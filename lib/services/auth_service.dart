import 'package:postflow/api/api.dart';
import 'package:postflow/models/auth_models.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSession> sign(SignRequest request) async {
    final response = await _apiClient.postJson(
      ApiEndpoint.authSign,
      request.toJson(),
    );
    return AuthSession.fromJson(response);
  }

  Future<AuthSession> testSignIn() async {
    final response = await _apiClient.postJson(ApiEndpoint.authTest, null);
    return AuthSession.fromJson(response);
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _apiClient.postJson(ApiEndpoint.authRefresh, {
      'refreshToken': refreshToken,
    });
    return AuthSession.fromJson(response);
  }
}
