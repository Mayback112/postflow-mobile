import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/services/auth_service.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({
    AuthService? authService,
    WorkspaceService? workspaceService,
    PostService? postService,
    SocialAccountService? socialAccountService,
  }) : _authService = authService ?? AuthService(),
       _workspaceService = workspaceService ?? WorkspaceService(),
       _postService = postService ?? PostService(),
       _socialAccountService = socialAccountService ?? SocialAccountService();

  final AuthService _authService;
  final WorkspaceService _workspaceService;
  final PostService _postService;
  final SocialAccountService _socialAccountService;

  bool _isLoading = true;
  String? _errorMessage;
  AuthUser? _user;
  List<Post> _posts = const [];
  List<SocialAccount> _accounts = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUser? get user => _user;
  List<SocialAccount> get connectedAccounts =>
      _accounts.where((account) => account.isActive).toList();
  int get postCount =>
      _posts.where((post) => post.status.toUpperCase() != 'CANCELED').length;
  int get scheduledCount =>
      _posts.where((post) => post.status.toUpperCase() == 'SCHEDULED').length;
  int get connectedPlatformCount => connectedAccounts.length;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.me();
      final workspace = await _workspaceService.ensureSelectedWorkspace();
      final results = await Future.wait([
        _postService.listPosts(workspaceId: workspace.id),
        _socialAccountService.listAccounts(workspaceId: workspace.id),
      ]);

      _user = user;
      _posts = results[0] as List<Post>;
      _accounts = results[1] as List<SocialAccount>;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  Future<void> refresh() => loadProfile();

  String _messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'Could not load your profile. Please try again.';
  }
}
