import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/social_connect_models.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/screen/platforms/platform_models.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

class PlatformsController extends ChangeNotifier {
  PlatformsController({
    WorkspaceService? workspaceService,
    SocialAccountService? socialAccountService,
  }) : _workspaceService = workspaceService ?? WorkspaceService(),
       _socialAccountService = socialAccountService ?? SocialAccountService();

  final WorkspaceService _workspaceService;
  final SocialAccountService _socialAccountService;

  bool _isLoading = true;
  bool _isSyncing = false;
  String? _connectingPlatform;
  String? _pendingConnectPlatform;
  String? _pendingConnectState;
  String? _errorMessage;
  String? _successMessage;
  Workspace? _workspace;
  List<SocialAccount> _accounts = const [];

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get connectStarted => _pendingConnectPlatform != null;
  String? get connectingPlatform => _connectingPlatform;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Workspace? get workspace => _workspace;
  List<SocialAccount> get accounts => _accounts;

  Future<void> loadAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final workspace = await _workspaceService.ensureSelectedWorkspace();
      final accounts = await _socialAccountService.listAccounts(
        workspaceId: workspace.id,
      );
      _workspace = workspace;
      _accounts = accounts;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  Future<void> connectPlatform(String platformName) async {
    if (_workspace == null) {
      await loadAccounts();
      if (_workspace == null) return;
    }

    final backendPlatform = backendPlatformForName(platformName);
    _connectingPlatform = backendPlatform;
    _pendingConnectPlatform = backendPlatform;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final connectStart = await _socialAccountService.connectPlatform(
        workspaceId: _workspace!.id,
        platform: backendPlatform,
      );
      _pendingConnectState = connectStart.state;
      _connectingPlatform = null;
      notifyListeners();
    } catch (error) {
      _connectingPlatform = null;
      _pendingConnectPlatform = null;
      _pendingConnectState = null;
      _errorMessage = _messageFor(error);
      _successMessage = null;
      notifyListeners();
    }
  }

  Future<void> handleConnectCallback(Uri uri) async {
    if (!_isSocialConnectCallback(uri)) {
      return;
    }

    final callbackPlatform =
        uri.queryParameters['connected'] ?? uri.queryParameters['platform'];
    final callbackPlatformEnum = callbackPlatform?.toUpperCase();
    final status = uri.queryParameters['status']?.toLowerCase();
    final error = uri.queryParameters['error'];
    final state = uri.queryParameters['state'];

    if (callbackPlatformEnum != null && callbackPlatformEnum.isNotEmpty) {
      _pendingConnectPlatform = callbackPlatformEnum;
    }

    if (state != null && state.isNotEmpty) {
      _pendingConnectState = state;
    }

    if (status == 'error' || (error != null && error.isNotEmpty)) {
      final callbackError = error == null || error.isEmpty
          ? 'connection_failed'
          : error;
      _connectingPlatform = null;
      _pendingConnectPlatform = null;
      _pendingConnectState = null;
      _isSyncing = false;
      _successMessage = null;
      _errorMessage = _messageForCallbackError(callbackError, callbackPlatform);
      notifyListeners();
      await _refreshAccountsWithoutLoading();
      return;
    }

    await syncAccountsAfterConnect();
  }

  bool _isSocialConnectCallback(Uri uri) {
    if (uri.scheme != 'postflow') return false;
    return uri.host == 'social-connect' ||
        uri.path.startsWith('/social-connect');
  }

  Future<void> syncAccountsAfterConnect() async {
    final workspace = _workspace;
    final platform = _pendingConnectPlatform;
    if (workspace == null || _isSyncing || platform == null) return;

    _isSyncing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final connectStatus = await _loadConnectStatusIfAvailable();
      if (connectStatus?.status == SocialConnectStatus.error) {
        final errorPlatform =
            connectStatus?.platform ?? _pendingConnectPlatform;
        _isSyncing = false;
        _connectingPlatform = null;
        _pendingConnectPlatform = null;
        _pendingConnectState = null;
        _successMessage = null;
        _errorMessage = _messageForCallbackError(
          connectStatus?.error ?? 'connection_failed',
          errorPlatform,
        );
        notifyListeners();
        await _refreshAccountsWithoutLoading();
        return;
      }

      if (connectStatus?.status == SocialConnectStatus.pending) {
        _isSyncing = false;
        _successMessage = null;
        _errorMessage =
            'The platform connection is still pending. Finish the browser flow, then try Done again.';
        notifyListeners();
        return;
      }

      var accounts = await _socialAccountService.syncAccounts(
        workspaceId: workspace.id,
        platform: platform,
      );
      if (accounts.isEmpty) {
        accounts = await _socialAccountService.listAccounts(
          workspaceId: workspace.id,
        );
      }

      _accounts = accounts;
      _isSyncing = false;
      if (_pendingConnectPlatform == null ||
          activeAccountForPlatform(accounts, _pendingConnectPlatform!) !=
              null) {
        _pendingConnectPlatform = null;
        _pendingConnectState = null;
        _successMessage = 'Social account connected successfully.';
      }
      notifyListeners();
    } catch (error) {
      _isSyncing = false;
      _errorMessage = _messageFor(error);
      _successMessage = null;
      notifyListeners();
    }
  }

  SocialAccount? accountForPlatform(String backendPlatform) {
    return preferredAccountForPlatform(_accounts, backendPlatform);
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401) return 'Please sign in again.';
      if (error.statusCode == 404) {
        return 'Workspace not found. Please retry.';
      }
      if (error.statusCode == 500) {
        return 'Social account connection is temporarily unavailable.';
      }
      return error.message;
    }
    return 'Could not update social accounts. Please try again.';
  }

  Future<void> _refreshAccountsWithoutLoading() async {
    final workspace = _workspace;
    if (workspace == null) return;

    try {
      _accounts = await _socialAccountService.listAccounts(
        workspaceId: workspace.id,
      );
      notifyListeners();
    } catch (_) {
      // Preserve the callback error. The user can retry account loading.
    }
  }

  Future<SocialConnectStatusResult?> _loadConnectStatusIfAvailable() async {
    final state = _pendingConnectState;
    final platform = _pendingConnectPlatform;
    if (state == null ||
        state.isEmpty ||
        platform == null ||
        platform.isEmpty) {
      return null;
    }
    try {
      return await _socialAccountService.connectStatus(
        platform: platform,
        state: state,
      );
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  String _messageForCallbackError(String error, String? platform) {
    final platformLabel = platform == null || platform.isEmpty
        ? 'platform'
        : platform.toLowerCase();
    return switch (error) {
      'oauth_denied' =>
        'The $platformLabel connection was cancelled or denied. Please try again.',
      'access_denied' =>
        'The $platformLabel connection was denied. Please try again.',
      _ => 'The $platformLabel connection failed. Please try again.',
    };
  }
}
