import 'package:google_sign_in/google_sign_in.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class ProviderIdentity {
  const ProviderIdentity({
    required this.provider,
    required this.idToken,
    this.name,
    this.profileImageUrl,
  });

  final AuthProvider provider;
  final String idToken;
  final String? name;
  final String? profileImageUrl;
}

class NativeAuthTokenProvider {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  Future<ProviderIdentity> getGoogleIdentity() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthProviderException('Google sign-in was cancelled.');
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthProviderException(
          'Google did not return an idToken. Check the Android Google Sign-In configuration and Google account on the device.',
        );
      }

      return ProviderIdentity(
        provider: AuthProvider.google,
        idToken: idToken,
        name: account.displayName,
        profileImageUrl: account.photoUrl,
      );
    } on AuthProviderException {
      rethrow;
    } catch (error) {
      throw AuthProviderException(_messageForGoogleError(error));
    }
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
    } catch (error) {
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
        message.contains('DEVELOPER_ERROR')) {
      return 'Google sign-in is not configured for this Android app. Check package name and SHA fingerprint in Google Cloud.';
    }

    return 'Google sign-in failed. Please try again.';
  }

  String _messageForAppleError(Object error) {
    return 'Apple sign-in failed. Please try again.';
  }
}

class AuthProviderException implements Exception {
  const AuthProviderException(this.message);

  final String message;

  @override
  String toString() => message;
}
