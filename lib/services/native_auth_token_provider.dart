import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class ProviderIdentity {
  const ProviderIdentity({
    required this.provider,
    required this.idToken,
    this.accessToken,
    this.name,
    this.profileImageUrl,
  });

  final AuthProvider provider;
  final String idToken;
  final String? accessToken;
  final String? name;
  final String? profileImageUrl;

  GoogleAuthRequest toGoogleAuthRequest() {
    return GoogleAuthRequest(
      idToken: idToken,
      accessToken: accessToken,
      name: name,
      profileImageUrl: profileImageUrl,
    );
  }
}

class NativeAuthTokenProvider {
  NativeAuthTokenProvider({FlutterAppAuth? appAuth, Dio? dio})
    : _appAuth = appAuth ?? const FlutterAppAuth(),
      _dio = dio ?? Dio();

  static const _googleClientId = String.fromEnvironment(
    'GOOGLE_OAUTH_CLIENT_IDS',
    defaultValue:
        '805427396737-9va66tb42nqbmue2mofdnv1df97eubp4.apps.googleusercontent.com',
  );
  static const _googleRedirectUrl = String.fromEnvironment(
    'GOOGLE_REDIRECT_URL',
    defaultValue: 'com.postflow.app:/oauth2redirect/google',
  );
  static const _googleServiceConfiguration = AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
    tokenEndpoint: 'https://oauth2.googleapis.com/token',
  );
  static const _googleUserInfoUrl =
      'https://openidconnect.googleapis.com/v1/userinfo';

  final FlutterAppAuth _appAuth;
  final Dio _dio;

  Future<ProviderIdentity> getGoogleIdentity() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _googleClientId,
          _googleRedirectUrl,
          serviceConfiguration: _googleServiceConfiguration,
          scopes: ['openid', 'email', 'profile'],
        ),
      );

      final idToken = result.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthProviderException(
          'Google did not return an ID token. Check the Google OAuth client and redirect URL configuration.',
        );
      }

      final accessToken = result.accessToken;
      final profile = accessToken == null || accessToken.isEmpty
          ? const _GoogleProfile()
          : await _loadGoogleProfile(accessToken);

      return ProviderIdentity(
        provider: AuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
        name: profile.name,
        profileImageUrl: profile.picture,
      );
    } on FlutterAppAuthUserCancelledException {
      throw const AuthProviderException('Google sign-in was cancelled.');
    } on AuthProviderException {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('AUTH Google Sign-In Error: $error');
        debugPrint('AUTH Google Sign-In StackTrace: $stackTrace');
      }
      throw AuthProviderException(_messageForGoogleError(error));
    }
  }

  Future<_GoogleProfile> _loadGoogleProfile(String accessToken) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _googleUserInfoUrl,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final data = response.data ?? const <String, dynamic>{};
    return _GoogleProfile(
      name: data['name'] as String?,
      picture: data['picture'] as String?,
    );
  }

  Future<ProviderIdentity> getAppleIdentity() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthProviderException(
          'Apple did not return an identityToken.',
        );
      }

      final fullName = [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().join(' ').trim();

      return ProviderIdentity(
        provider: AuthProvider.apple,
        idToken: idToken,
        name: fullName.isEmpty ? null : fullName,
      );
    } on AuthProviderException {
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('AUTH Apple Sign-In Error: $error');
        debugPrint('AUTH Apple Sign-In StackTrace: $stackTrace');
      }
      throw AuthProviderException(_messageForAppleError(error));
    }
  }

  String _messageForGoogleError(Object error) {
    final message = error.toString();

    if (message.contains('ApiException: 4') ||
        message.contains('SIGN_IN_REQUIRED')) {
      return 'No Google credentials are available on this device. Add a Google account in the emulator or use a device with Google Play services.';
    }

    if (message.contains('ApiException: 10') ||
        message.contains('DEVELOPER_ERROR') ||
        message.contains('invalid_request') ||
        message.contains('redirect_uri_mismatch')) {
      return 'Google sign-in is not configured for this app. Check the OAuth client ID and redirect URL in Google Cloud.';
    }

    return 'Google sign-in failed. Please try again.';
  }

  String _messageForAppleError(Object error) {
    return 'Apple sign-in failed. Please try again.';
  }
}

class _GoogleProfile {
  const _GoogleProfile({this.name, this.picture});

  final String? name;
  final String? picture;
}

class AuthProviderException implements Exception {
  const AuthProviderException(this.message);

  final String message;

  @override
  String toString() => message;
}
