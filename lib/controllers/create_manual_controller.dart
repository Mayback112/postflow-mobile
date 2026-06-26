import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

enum PostContentType { text, image, video, mixed }

enum CreatePostResult { created, needsSchedule }

class CreateManualController extends ChangeNotifier {
  CreateManualController({
    WorkspaceService? workspaceService,
    SocialAccountService? socialAccountService,
    PostService? postService,
  }) : _workspaceService = workspaceService ?? WorkspaceService(),
       _socialAccountService = socialAccountService ?? SocialAccountService(),
       _postService = postService ?? PostService();

  final WorkspaceService _workspaceService;
  final SocialAccountService _socialAccountService;
  final PostService _postService;

  final Set<String> _selectedAccountIds = {};
  final List<String> _hashtags = [];
  final List<PlatformFile> _selectedResources = [];

  bool _isLoadingTargets = true;
  bool _isSubmitting = false;
  bool _tiktokAutoAddMusic = true;
  String _caption = '';
  String? _errorMessage;
  Workspace? _workspace;
  List<SocialAccount> _accounts = const [];
  DateTime? _scheduledAt;
  PostContentType _selectedType = PostContentType.text;

  bool get isLoadingTargets => _isLoadingTargets;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Workspace? get workspace => _workspace;
  List<SocialAccount> get accounts => _accounts;
  List<SocialAccount> get compatibleAccounts =>
      _accounts.where(_accountSupportsCurrentContent).toList();
  List<SocialAccount> get unavailableAccounts => _accounts
      .where((account) => !_accountSupportsCurrentContent(account))
      .toList();
  Set<String> get selectedAccountIds => _selectedAccountIds;
  List<String> get hashtags => _hashtags;
  DateTime? get scheduledAt => _scheduledAt;
  List<PlatformFile> get selectedResources => _selectedResources;
  PostContentType get selectedType => _selectedType;
  bool get tiktokAutoAddMusic => _tiktokAutoAddMusic;
  bool get showTikTokPhotoMusicOption =>
      _selectedAccounts().any(_isTikTokAccount) &&
      _mediaKind == _MediaKind.image;
  String get contentRuleSummary {
    return switch (_mediaKind) {
      _MediaKind.text =>
        'Text posts can go to Facebook, LinkedIn, X, or Threads.',
      _MediaKind.image =>
        'Images: Instagram, Facebook, and Threads allow up to 10; LinkedIn 20; TikTok 35; X 4.',
      _MediaKind.video =>
        'Videos: YouTube, Facebook, TikTok, LinkedIn, X, and Threads allow 1 video; Instagram allows up to 10.',
      _MediaKind.mixed =>
        'Mixed image and video posts can only go to Instagram, up to 10 media assets.',
    };
  }

  bool get usesMedia => _selectedType != PostContentType.text;

  Future<void> loadPostTargets() async {
    _isLoadingTargets = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final workspace = await _workspaceService.ensureSelectedWorkspace();
      final accounts = await _socialAccountService.listAccounts(
        workspaceId: workspace.id,
      );
      _workspace = workspace;
      _accounts = accounts.where(_isPublishableZernioAccount).toList();
      _pruneIncompatibleSelectedAccounts();
      _isLoadingTargets = false;
      notifyListeners();
    } catch (_) {
      _isLoadingTargets = false;
      _errorMessage = 'Could not load connected social accounts.';
      notifyListeners();
    }
  }

  void setCaption(String caption) {
    _caption = caption;
    notifyListeners();
  }

  void setTikTokAutoAddMusic(bool value) {
    _tiktokAutoAddMusic = value;
    notifyListeners();
  }

  void toggleAccount(String accountId) {
    final account = _accounts.where((item) => item.id == accountId).firstOrNull;
    if (account == null || !_accountSupportsCurrentContent(account)) {
      _setError('That account does not support this post type.');
      return;
    }

    if (_selectedAccountIds.contains(accountId)) {
      _selectedAccountIds.remove(accountId);
    } else {
      _selectedAccountIds.add(accountId);
    }
    _errorMessage = null;
    notifyListeners();
  }

  void selectType(PostContentType type) {
    _selectedType = type;
    _selectedResources.clear();
    _pruneIncompatibleSelectedAccounts();
    notifyListeners();
  }

  void setResources(List<PlatformFile> resources) {
    _selectedResources
      ..clear()
      ..addAll(resources);
    _pruneIncompatibleSelectedAccounts();
    notifyListeners();
  }

  void reorderResource(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final resource = _selectedResources.removeAt(oldIndex);
    _selectedResources.insert(newIndex, resource);
    notifyListeners();
  }

  void setScheduledAt(DateTime scheduledAt) {
    _scheduledAt = scheduledAt;
    notifyListeners();
  }

  bool addHashtag(String rawValue) {
    final trimmedValue = rawValue.trim();
    if (trimmedValue.isEmpty) return false;

    final tag = trimmedValue.startsWith('#') ? trimmedValue : '#$trimmedValue';
    if (_hashtags.contains(tag)) return true;

    _hashtags.add(tag);
    notifyListeners();
    return true;
  }

  void removeHashtag(String tag) {
    _hashtags.remove(tag);
    notifyListeners();
  }

  List<String> allowedExtensionsForSelectedType() {
    return switch (_selectedType) {
      PostContentType.image => ['jpg', 'jpeg', 'png', 'webp'],
      PostContentType.video => ['mp4', 'mov', 'm4v', 'webm'],
      PostContentType.mixed => [
        'jpg',
        'jpeg',
        'png',
        'webp',
        'mp4',
        'mov',
        'm4v',
        'webm',
      ],
      PostContentType.text => [],
    };
  }

  Future<CreatePostResult> submitPost({required bool schedule}) async {
    final workspace = _workspace;
    if (workspace == null) {
      _setError('Workspace is still loading.');
      return CreatePostResult.needsSchedule;
    }

    final incompatibleAccount = _selectedAccounts().firstWhere(
      (account) => !_accountSupportsCurrentContent(account),
      orElse: () => _emptyAccount,
    );
    if (incompatibleAccount.id.isNotEmpty) {
      _setError(
        '${_platformLabel(incompatibleAccount.platform)} does not support this post type.',
      );
      return CreatePostResult.needsSchedule;
    }

    final targets = selectedTargets();
    final caption = _caption.trim();

    if (targets.isEmpty) {
      _setError('Choose at least one connected account.');
      return CreatePostResult.needsSchedule;
    }
    if (!usesMedia && caption.isEmpty) {
      _setError('Write the text for this post.');
      return CreatePostResult.needsSchedule;
    }
    if (usesMedia && _selectedResources.isEmpty) {
      _setError('Add media before creating this post.');
      return CreatePostResult.needsSchedule;
    }
    if (schedule && _scheduledAt == null) {
      return CreatePostResult.needsSchedule;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final mediaAssetIds = usesMedia
          ? await _postService.uploadAndRegisterMedia(
              workspaceId: workspace.id,
              platform: targets.first.platform,
              files: _selectedResources,
            )
          : <String>[];

      await _postService.createPost(
        workspaceId: workspace.id,
        caption: caption,
        hashtags: _hashtags,
        mediaAssetIds: mediaAssetIds,
        platforms: targets,
        scheduledAt: schedule ? _scheduledAt : null,
      );

      _isSubmitting = false;
      notifyListeners();
      return CreatePostResult.created;
    } catch (error) {
      _isSubmitting = false;
      _errorMessage = error is ApiException
          ? error.message
          : 'Could not create this post. Please try again.';
      notifyListeners();
      return CreatePostResult.needsSchedule;
    }
  }

  List<PostPlatformTarget> selectedTargets() {
    return _selectedAccounts().map((account) {
      final isTikTokPhotoPost =
          _isTikTokAccount(account) && _mediaKind == _MediaKind.image;
      return PostPlatformTarget(
        platform: account.platform,
        accountId: account.id,
        publishOptions: isTikTokPhotoPost
            ? {'autoAddMusic': _tiktokAutoAddMusic}
            : null,
      );
    }).toList();
  }

  List<String> selectedTargetLabels() {
    return _selectedAccounts().map((account) => account.displayName).toList();
  }

  String compatibilityReason(SocialAccount account) {
    if (_accountSupportsCurrentContent(account)) return 'Available';

    final platform = account.platform.toUpperCase();
    final mediaKind = _mediaKind;
    final mediaCount = _selectedResources.length;

    if (mediaKind == _MediaKind.text &&
        (platform == 'INSTAGRAM' ||
            platform == 'TIKTOK' ||
            platform == 'YOUTUBE')) {
      return 'Requires media';
    }
    if (mediaKind == _MediaKind.image && platform == 'YOUTUBE') {
      return 'No image posts';
    }
    if (mediaKind == _MediaKind.mixed && platform != 'INSTAGRAM') {
      return 'No mixed media';
    }
    if (mediaKind == _MediaKind.video &&
        platform != 'INSTAGRAM' &&
        mediaCount != 1) {
      return 'One video only';
    }
    if (mediaKind == _MediaKind.image) {
      final limit = _imageLimitFor(platform);
      if (limit != null && mediaCount > limit) return 'Max $limit images';
    }
    if (platform == 'INSTAGRAM' && mediaCount > 10) return 'Max 10 media';

    return 'Not supported';
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  List<SocialAccount> _selectedAccounts() {
    return _accounts
        .where((account) => _selectedAccountIds.contains(account.id))
        .toList();
  }

  void _pruneIncompatibleSelectedAccounts() {
    _selectedAccountIds.removeWhere((accountId) {
      final account = _accounts
          .where((item) => item.id == accountId)
          .firstOrNull;
      return account == null || !_accountSupportsCurrentContent(account);
    });
  }

  bool _accountSupportsCurrentContent(SocialAccount account) {
    final platform = account.platform.toUpperCase();
    final mediaKind = _mediaKind;
    final mediaCount = _selectedResources.length;

    return switch (platform) {
      'INSTAGRAM' => switch (mediaKind) {
        _MediaKind.text => false,
        _MediaKind.image ||
        _MediaKind.video ||
        _MediaKind.mixed => mediaCount <= 10,
      },
      'FACEBOOK' => switch (mediaKind) {
        _MediaKind.text => true,
        _MediaKind.image => mediaCount <= 10,
        _MediaKind.video => mediaCount <= 1,
        _MediaKind.mixed => false,
      },
      'TIKTOK' => switch (mediaKind) {
        _MediaKind.text => false,
        _MediaKind.image => mediaCount <= 35,
        _MediaKind.video => mediaCount <= 1,
        _MediaKind.mixed => false,
      },
      'YOUTUBE' => mediaKind == _MediaKind.video && mediaCount == 1,
      'LINKEDIN' => switch (mediaKind) {
        _MediaKind.text => true,
        _MediaKind.image => mediaCount <= 20,
        _MediaKind.video => mediaCount <= 1,
        _MediaKind.mixed => false,
      },
      'X' => switch (mediaKind) {
        _MediaKind.text => true,
        _MediaKind.image => mediaCount <= 4,
        _MediaKind.video => mediaCount <= 1,
        _MediaKind.mixed => false,
      },
      'THREADS' => switch (mediaKind) {
        _MediaKind.text => true,
        _MediaKind.image => mediaCount <= 10,
        _MediaKind.video => mediaCount <= 1,
        _MediaKind.mixed => false,
      },
      _ => true,
    };
  }

  int? _imageLimitFor(String platform) {
    return switch (platform) {
      'INSTAGRAM' => 10,
      'FACEBOOK' => 10,
      'TIKTOK' => 35,
      'LINKEDIN' => 20,
      'X' => 4,
      'THREADS' => 10,
      _ => null,
    };
  }

  _MediaKind get _mediaKind {
    if (_selectedType == PostContentType.text) return _MediaKind.text;
    if (_selectedResources.isEmpty) {
      return switch (_selectedType) {
        PostContentType.text => _MediaKind.text,
        PostContentType.image => _MediaKind.image,
        PostContentType.video => _MediaKind.video,
        PostContentType.mixed => _MediaKind.image,
      };
    }

    final hasImage = _selectedResources.any(_isImageFile);
    final hasVideo = _selectedResources.any(_isVideoFile);
    if (hasImage && hasVideo) return _MediaKind.mixed;
    if (hasVideo) return _MediaKind.video;
    return _MediaKind.image;
  }

  bool _isTikTokAccount(SocialAccount account) {
    return account.platform.toUpperCase() == 'TIKTOK';
  }

  bool _isPublishableZernioAccount(SocialAccount account) {
    return account.isActive &&
        account.provider.toUpperCase() == 'ZERNIO' &&
        account.zernioAccountId?.isNotEmpty == true;
  }

  bool _isImageFile(PlatformFile file) {
    final extension = _extensionFor(file);
    return extension == 'jpg' ||
        extension == 'jpeg' ||
        extension == 'png' ||
        extension == 'webp';
  }

  bool _isVideoFile(PlatformFile file) {
    final extension = _extensionFor(file);
    return extension == 'mp4' ||
        extension == 'mov' ||
        extension == 'm4v' ||
        extension == 'webm';
  }

  String? _extensionFor(PlatformFile file) {
    final explicitExtension = file.extension?.toLowerCase();
    if (explicitExtension != null && explicitExtension.isNotEmpty) {
      return explicitExtension;
    }

    final dotIndex = file.name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == file.name.length - 1) return null;
    return file.name.substring(dotIndex + 1).toLowerCase();
  }

  String _platformLabel(String platform) {
    final lower = platform.toLowerCase();
    return lower.isEmpty
        ? platform
        : '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}

enum _MediaKind { text, image, video, mixed }

const _emptyAccount = SocialAccount(
  id: '',
  workspaceId: '',
  platform: '',
  displayName: '',
  provider: '',
  isActive: false,
);
