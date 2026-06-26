import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:postflow/api/api.dart';
import 'package:postflow/api/api_exception.dart';
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
    final body = <String, dynamic>{
      'workspaceId': workspaceId,
      'content': content,
      'targets': targets,
    };

    if (scheduledFor != null) {
      body['scheduledFor'] = scheduledFor.toUtc().toIso8601String();
    }
    if (isDraft != null) {
      body['isDraft'] = isDraft;
    }
    if (publishNow != null) {
      body['publishNow'] = publishNow;
    }

    final response = await _apiClient.postJson(ApiEndpoint.posts, body);
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
    final body = <String, dynamic>{};

    if (content != null) {
      body['content'] = content;
    }
    if (scheduledFor != null) {
      body['scheduledFor'] = scheduledFor.toUtc().toIso8601String();
    }
    if (isDraft != null) {
      body['isDraft'] = isDraft;
    }
    if (publishNow != null) {
      body['publishNow'] = publishNow;
    }
    if (targets != null) {
      body['targets'] = targets;
    }

    final response = await _apiClient.patchJsonRaw('/mobile/posts/$postId', body);
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

  Future<String> uploadMedia({
    required PlatformFile file,
    String? workspaceId,
  }) async {
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const ApiException('Selected file data is unavailable');
    }

    final formDataMap = <String, dynamic>{
      'file': MultipartFile.fromBytes(bytes, filename: file.name),
    };
    if (workspaceId != null && workspaceId.isNotEmpty) {
      formDataMap['workspaceId'] = workspaceId;
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _apiClient.postMultipart(
      ApiEndpoint.mediaUpload,
      formData,
    );

    final url =
        response['url'] as String? ??
        response['secureUrl'] as String? ??
        response['secure_url'] as String?;

    if (url == null || url.isEmpty) {
      throw const ApiException('Backend did not return an uploaded media URL');
    }

    return url;
  }

  Future<List<String>> uploadMediaFiles({
    required String workspaceId,
    required List<PlatformFile> files,
  }) async {
    final urls = <String>[];
    for (final file in files) {
      urls.add(await uploadMedia(workspaceId: workspaceId, file: file));
    }
    return urls;
  }
}
