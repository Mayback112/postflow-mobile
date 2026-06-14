import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/api/api.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/services/auth_service.dart';

void main() {
  test('Google sign-in sends provider tokens and profile fields', () async {
    late RequestOptions capturedRequest;
    final service = AuthService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'user': {
            'id': 'user-1',
            'email': 'ada@example.com',
            'name': 'Ada Lovelace',
            'profileImageUrl': 'https://lh3.googleusercontent.com/a/image',
          },
          'tokens': {
            'accessToken': 'jwt-access-token',
            'refreshToken': 'jwt-refresh-token',
          },
        };
      }),
    );

    final session = await service.signInWithGoogle(
      const GoogleAuthRequest(
        idToken: 'google-identity-token',
        accessToken: 'google-access-token',
        name: 'Ada Lovelace',
        profileImageUrl: 'https://lh3.googleusercontent.com/a/image',
      ),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.uri.path, '/mobile/auth/google');
    expect(capturedRequest.data, {
      'idToken': 'google-identity-token',
      'accessToken': 'google-access-token',
      'name': 'Ada Lovelace',
      'profileImageUrl': 'https://lh3.googleusercontent.com/a/image',
    });
    expect(session.user.email, 'ada@example.com');
    expect(session.tokens.accessToken, 'jwt-access-token');
  });

  test('refresh parses backend session response', () async {
    late RequestOptions capturedRequest;
    final service = AuthService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'user': {
            'id': 'user-1',
            'email': 'ada@example.com',
            'name': 'Ada Lovelace',
            'profileImageUrl': null,
          },
          'tokens': {
            'accessToken': 'new-jwt-access-token',
            'refreshToken': 'new-jwt-refresh-token',
          },
        };
      }),
    );

    final session = await service.refresh('old-jwt-refresh-token');

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.uri.path, '/mobile/auth/refresh');
    expect(capturedRequest.data, {'refreshToken': 'old-jwt-refresh-token'});
    expect(session.user.email, 'ada@example.com');
    expect(session.tokens.accessToken, 'new-jwt-access-token');
    expect(session.tokens.refreshToken, 'new-jwt-refresh-token');
  });

  test('logout sends refresh token to backend', () async {
    late RequestOptions capturedRequest;
    final service = AuthService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return const <String, dynamic>{};
      }),
    );

    await service.logout('jwt-refresh-token');

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.uri.path, '/mobile/auth/logout');
    expect(capturedRequest.data, {'refreshToken': 'jwt-refresh-token'});
  });
}

ApiClient _mockApiClient(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, requestHandler) {
        requestHandler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: handler(options),
          ),
        );
      },
    ),
  );

  return ApiClient(
    dio: dio,
    baseUri: Uri.parse('http://127.0.0.1:4000'),
    enableAuthInterceptor: false,
  );
}
