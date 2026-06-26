import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/screen/platforms/platform_models.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

class CreatePostController extends ChangeNotifier {
  CreatePostController({
    WorkspaceService? workspaceService,
    SocialAccountService? socialAccountService,
    PostService? postService,
  }) : _workspaceService = workspaceService ?? WorkspaceService(),
       _socialAccountService = socialAccountService ?? SocialAccountService(),
       _postService = postService ?? PostService();

  final WorkspaceService _workspaceService;
  final SocialAccountService _socialAccountService;
  final PostService _postService;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  Workspace? _workspace;
  List<SocialAccount> _accounts = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Workspace? get workspace => _workspace;
  List<SocialAccount> get accounts => _accounts;

  Future<void> loadInitialData() async {
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
      _accounts = accounts.where((a) => a.isActive).toList();
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  Future<Post?> submitPost({
    required String baseContent,
    required List<String> selectedPlatformNames,
    required bool hasMedia,
    required bool isVideo,
    DateTime? scheduledFor,
    bool? isDraft,
    bool? publishNow,
  }) async {
    if (_workspace == null) {
      _errorMessage = 'Workspace not loaded. Please try again.';
      notifyListeners();
      return null;
    }

    if (baseContent.trim().isEmpty) {
      _errorMessage = 'Post content cannot be empty.';
      notifyListeners();
      return null;
    }

    if (selectedPlatformNames.isEmpty) {
      _errorMessage = 'At least one platform must be selected.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> targets = [];

      for (final platformName in selectedPlatformNames) {
        final backendPlatform = backendPlatformForName(platformName);
        final account = activeAccountForPlatform(_accounts, backendPlatform);

        if (account == null) {
          throw Exception(
            'No active connected account found for $platformName',
          );
        }

        final List<String> mediaUrls = [];
        if (hasMedia) {
          if (isVideo) {
            mediaUrls.add(
              'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
            );
          } else {
            mediaUrls.add('https://picsum.photos/800/800');
          }
        }

        final Map<String, dynamic> platformSpecificData = {};
        if (backendPlatform == 'INSTAGRAM') {
          platformSpecificData['accountType'] = 'BUSINESS';
          platformSpecificData['postType'] = 'FEED';
        } else if (backendPlatform == 'LINKEDIN') {
          platformSpecificData['accountType'] = 'PERSONAL';
        } else if (backendPlatform == 'FACEBOOK') {
          platformSpecificData['pageId'] = 'mock-page-id';
        }

        final Map<String, dynamic> tiktokSettings = {};
        if (backendPlatform == 'TIKTOK') {
          tiktokSettings['privacyLevel'] = 'PUBLIC';
          tiktokSettings['content_preview_confirmed'] = true;
          tiktokSettings['express_consent_given'] = true;
        }

        targets.add({
          'socialAccountId': account.id,
          'mediaUrls': mediaUrls,
          if (platformSpecificData.isNotEmpty)
            'platformSpecificData': platformSpecificData,
          if (tiktokSettings.isNotEmpty) 'tiktokSettings': tiktokSettings,
        });
      }

      final post = await _postService.createPost(
        workspaceId: _workspace!.id,
        content: baseContent,
        scheduledFor: scheduledFor,
        isDraft: isDraft,
        publishNow: publishNow,
        targets: targets,
      );

      _successMessage = 'Post created successfully.';
      _isLoading = false;
      notifyListeners();
      return post;
    } catch (error) {
      _isLoading = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
      return null;
    }
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    if (error is Exception) {
      final msg = error.toString();
      if (msg.startsWith('Exception: ')) {
        return msg.substring(11);
      }
      return msg;
    }
    return 'An error occurred. Please try again.';
  }
}
