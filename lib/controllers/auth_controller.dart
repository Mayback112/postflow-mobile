import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/services/auth_service.dart';
import 'package:postflow/services/auth_token_storage.dart';
import 'package:postflow/services/native_auth_token_provider.dart';
import 'package:postflow/services/workspace_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthService? authService,
    AuthTokenStorage? tokenStorage,
    NativeAuthTokenProvider? nativeAuthTokenProvider,
    WorkspaceService? workspaceService,
  }) : _authService = authService ?? AuthService(),
       _tokenStorage = tokenStorage ?? AuthTokenStorage(),
       _nativeAuthTokenProvider =
           nativeAuthTokenProvider ?? NativeAuthTokenProvider(),
       _workspaceService = workspaceService ?? WorkspaceService();

  final AuthService _authService;
  final AuthTokenStorage _tokenStorage;
  final NativeAuthTokenProvider _nativeAuthTokenProvider;
  final WorkspaceService _workspaceService;

  AuthUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> signInWithGoogle() async {
    _setLoading();

    try {
      final identity = await _nativeAuthTokenProvider.getGoogleIdentity();
      final session = await _authService.signInWithGoogle(
        identity.toGoogleAuthRequest(),
      );
      await _applySession(session);
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AUTH operation failed: $error');
      }
      _setError(_messageFor(error));
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    return _signWithProvider(_nativeAuthTokenProvider.getAppleIdentity);
  }

  Future<bool> signWithIdentity(ProviderIdentity identity) {
    if (identity.provider == AuthProvider.google) {
      return _signInWithGoogleIdentity(identity);
    }

    return _sign(
      SignRequest(
        provider: identity.provider,
        idToken: identity.idToken,
        name: identity.name,
        profileImageUrl: identity.profileImageUrl,
      ),
    );
  }

  Future<bool> refreshSession() async {
    _setLoading();

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const ApiException('No refresh token is stored');
      }

      final session = await _authService.refresh(refreshToken);
      await _tokenStorage.saveSession(session);
      await _workspaceService.ensureSelectedWorkspace();

      _user = session.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AUTH operation failed: $error');
      }
      _setError(_messageFor(error));
      return false;
    }
  }

  Future<String?> accessToken() {
    return _tokenStorage.readAccessToken();
  }

  Future<AuthUser?> storedUser() {
    return Future.value(_user);
  }

  Future<void> signOut() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authService.logout(refreshToken);
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AUTH logout failed: $error');
      }
    } finally {
      await _tokenStorage.clear();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> _signWithProvider(
    Future<ProviderIdentity> Function() identityLoader,
  ) async {
    _setLoading();

    try {
      final identity = await identityLoader();
      return _sign(
        SignRequest(
          provider: identity.provider,
          idToken: identity.idToken,
          name: identity.name,
          profileImageUrl: identity.profileImageUrl,
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AUTH operation failed: $error');
      }
      _setError(_messageFor(error));
      return false;
    }
  }

  Future<bool> _sign(SignRequest request) async {
    _setLoading();

    try {
      final session = await _authService.sign(request);
      await _applySession(session);
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AUTH operation failed: $error');
      }
      _setError(_messageFor(error));
      return false;
    }
  }

  Future<bool> _signInWithGoogleIdentity(ProviderIdentity identity) async {
    _setLoading();

    try {
      final session = await _authService.signInWithGoogle(
        identity.toGoogleAuthRequest(),
      );
      await _applySession(session);
      return true;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('AUTH operation failed: $error');
      }
      _setError(_messageFor(error));
      return false;
    }
  }

  Future<void> _applySession(AuthSession session) async {
    if (kDebugMode) {
      debugPrint('AUTH saving tokens');
    }
    await _tokenStorage.saveSession(session);
    if (kDebugMode) {
      debugPrint('AUTH tokens saved');
    }
    await _workspaceService.ensureSelectedWorkspace();
    _user = session.user;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error is AuthProviderException) {
      return error.message;
    }
    if (error is UnsupportedError) {
      return error.message ?? 'Sign-in unavailable';
    }
    return 'Authentication failed. Please try again.';
  }
}
