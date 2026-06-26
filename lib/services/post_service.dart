import 'package:file_picker/file_picker.dart';
import 'package:postflow/api/api.dart';
import 'package:postflow/models/post.dart';

class PostService {
  PostService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Post>> listPosts({required String workspaceId}) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.posts,
      query: {'workspaceId': workspaceId},
    );
    final items = response['posts'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  Future<Post> createPost({
    required String workspaceId,
    required String content,
    DateTime? scheduledFor,
    bool? isDraft,
    bool? publishNow,
    required List<Map<String, dynamic>> targets,
  }) async {
    final response = await _apiClient.postJson(ApiEndpoint.posts, {
      'workspaceId': workspaceId,
      'content': content,
      if (scheduledFor != null)
        'scheduledFor': scheduledFor.toUtc().toIso8601String(),
      if (isDraft != null) 'isDraft': isDraft,
      if (publishNow != null) 'publishNow': publishNow,
      'targets': targets,
    });
    return Post.fromJson(response['post'] as Map<String, dynamic>);
  }

  Future<Post> getPost(String postId) async {
    final response = await _apiClient.getJsonRaw('/mobile/posts/$postId');
    return Post.fromJson(response['post'] as Map<String, dynamic>);
  }

  Future<Post> updatePost(
    String postId, {
    String? content,
    DateTime? scheduledFor,
    bool? isDraft,
    bool? publishNow,
    List<Map<String, dynamic>>? targets,
  }) async {
    final response = await _apiClient.patchJsonRaw('/mobile/posts/$postId', {
      if (content != null) 'content': content,
      if (scheduledFor != null)
        'scheduledFor': scheduledFor.toUtc().toIso8601String(),
      if (isDraft != null) 'isDraft': isDraft,
      if (publishNow != null) 'publishNow': publishNow,
      if (targets != null) 'targets': targets,
    });
    return Post.fromJson(response['post'] as Map<String, dynamic>);
  }

  Future<void> deletePost(String postId) async {
    await _apiClient.deleteJsonRaw('/mobile/posts/$postId');
  }

  Future<Post> retryPost(String postId) async {
    final response = await _apiClient.postJsonRaw(
      '/mobile/posts/$postId/retry',
      null,
    );
    return Post.fromJson(response['post'] as Map<String, dynamic>);
  }

  /// Uploads [files] to the media upload endpoint and returns a list of URLs.
  /// Stub until C3 (Cloudinary upload endpoint) is built — returns empty list.
  Future<List<String>> uploadMediaFiles({
    required String workspaceId,
    required List<PlatformFile> files,
  }) async {
    // TODO(C3): implement real Cloudinary upload via POST /mobile/media/upload
    return const [];
  }
}
