import 'package:flutter/foundation.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/workspace_service.dart';
import 'package:intl/intl.dart';

class CalendarController extends ChangeNotifier {
  CalendarController({
    WorkspaceService? workspaceService,
    PostService? postService,
  }) : _workspaceService = workspaceService ?? WorkspaceService(),
       _postService = postService ?? PostService();

  final WorkspaceService _workspaceService;
  final PostService _postService;

  bool _isLoading = true;
  String? _errorMessage;
  Workspace? _workspace;
  List<ScheduleItem> _schedules = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Workspace? get workspace => _workspace;
  List<ScheduleItem> get schedules => _schedules;

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final workspace = await _workspaceService.ensureSelectedWorkspace();
      _workspace = workspace;

      final posts = await _postService.listPosts(workspaceId: workspace.id);

      _schedules = posts.map((post) => _mapPostToScheduleItem(post)).toList();
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

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'An error occurred. Please try again.';
  }
}
