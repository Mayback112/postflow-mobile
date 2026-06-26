import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';
import 'package:intl/intl.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    WorkspaceService? workspaceService,
    SocialAccountService? socialAccountService,
    PostService? postService,
  }) : _workspaceService = workspaceService ?? WorkspaceService(),
       _socialAccountService = socialAccountService ?? SocialAccountService(),
       _postService = postService ?? PostService();

  final WorkspaceService _workspaceService;
  final SocialAccountService _socialAccountService;
  final PostService _postService;

  bool _isLoading = true;
  String? _errorMessage;
  Workspace? _workspace;
  List<PlatformItem> _connectedPlatforms = const [];
  List<ScheduleItem> _schedules = const [];
  UpcomingPost? _upcomingPost;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Workspace? get workspace => _workspace;
  List<PlatformItem> get connectedPlatforms => _connectedPlatforms;
  List<ScheduleItem> get schedules => _schedules;
  UpcomingPost? get upcomingPost => _upcomingPost;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final workspace = await _workspaceService.ensureSelectedWorkspace();
      _workspace = workspace;

      final accounts = await _socialAccountService.listAccounts(
        workspaceId: workspace.id,
      );

      final posts = await _postService.listPosts(workspaceId: workspace.id);

      // Map platforms
      _connectedPlatforms = accounts
          .where((acc) => acc.isActive)
          .map(
            (acc) => PlatformItem(name: _normalizePlatformName(acc.platform)),
          )
          .toList();

      // Map schedules (sort and map posts)
      final allSchedules = posts
          .map((post) => _mapPostToScheduleItem(post))
          .toList();

      // Store all scheduled and draft posts in _schedules
      _schedules = allSchedules;

      // Find upcoming post (first queued post)
      final queuedPosts = allSchedules
          .where((item) => item.status == 'queued')
          .toList();
      if (queuedPosts.isNotEmpty) {
        // Sort by date/time to find the earliest
        queuedPosts.sort((a, b) {
          final aDate = _parseDateTime(a.date, a.time);
          final bDate = _parseDateTime(b.date, b.time);
          return aDate.compareTo(bDate);
        });

        final earliest = queuedPosts.first;
        _upcomingPost = UpcomingPost(
          id: earliest.id,
          title: earliest.title,
          subtitle: earliest.subtitle,
          scheduledText: '${earliest.date} at ${earliest.time}',
          imageUrl: earliest.imageUrl,
          originalPost: earliest.originalPost,
        );
      } else {
        _upcomingPost = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = _messageFor(error);
      notifyListeners();
    }
  }

  String _normalizePlatformName(String platform) {
    switch (platform.toUpperCase()) {
      case 'INSTAGRAM':
        return 'Instagram';
      case 'FACEBOOK':
        return 'Facebook';
      case 'TIKTOK':
        return 'TikTok';
      case 'YOUTUBE':
        return 'YouTube';
      case 'LINKEDIN':
        return 'LinkedIn';
      case 'X':
        return 'X';
      case 'THREADS':
        return 'Threads';
      default:
        return platform;
    }
  }

  ScheduleItem _mapPostToScheduleItem(Post post) {
    final platforms = post.postTargets
        .map((t) => _normalizePlatformName(t.platform))
        .toSet()
        .join(', ');

    String contentType = 'Text';
    String imageUrl = '';
    if (post.postTargets.isNotEmpty) {
      final firstTarget = post.postTargets.first;
      if (firstTarget.mediaUrls.isNotEmpty) {
        imageUrl = firstTarget.mediaUrls.first;
        final urlLower = imageUrl.toLowerCase();
        if (urlLower.endsWith('.mp4') ||
            urlLower.endsWith('.mov') ||
            urlLower.endsWith('.webm')) {
          contentType = 'Video';
        } else {
          contentType = 'Image';
        }
      }
    }

    String status = 'draft';
    if (post.status == 'SCHEDULED' || post.status == 'PUBLISHING') {
      status = 'queued';
    } else if (post.status == 'PUBLISHED' || post.status == 'PARTIAL') {
      status = 'posted';
    } else if (post.status == 'FAILED') {
      status = 'failed';
    }

    final displayTime = post.scheduledFor ?? post.publishedAt ?? post.createdAt;
    final dateStr = DateFormat('MMM d, yyyy').format(displayTime);
    final timeStr = DateFormat('h:mm a').format(displayTime);

    return ScheduleItem(
      id: post.id,
      title: post.content.split('\n').first,
      subtitle: post.content,
      date: dateStr,
      time: timeStr,
      imageUrl: imageUrl,
      platform: platforms,
      status: status,
      contentType: contentType,
      originalPost: post,
    );
  }

  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      final format = DateFormat('MMM d, yyyy h:mm a');
      return format.parse('$dateStr $timeStr');
    } catch (_) {
      return DateTime.now();
    }
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to load home data. Please try again.';
  }
}
