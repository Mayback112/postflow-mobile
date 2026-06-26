import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/api/api.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/services/post_service.dart';

void main() {
  test('listPosts sends workspaceId query and parses posts', () async {
    late RequestOptions capturedRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'posts': [
            {
              'id': 'post-1',
              'workspaceId': 'workspace-1',
              'content': 'Scheduled content',
              'status': 'SCHEDULED',
              'scheduledFor': null,
              'publishedAt': null,
              'createdAt': '2026-06-20T10:00:00.000Z',
              'updatedAt': '2026-06-20T10:00:00.000Z',
              'postTargets': [],
            },
          ],
        };
      }),
    );

    final posts = await service.listPosts(workspaceId: 'workspace-1');

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.uri.path, '/mobile/posts');
    expect(capturedRequest.uri.queryParameters['workspaceId'], 'workspace-1');
    expect(posts.single.id, 'post-1');
    expect(posts.single.content, 'Scheduled content');
    expect(posts.single.status, 'SCHEDULED');
  });

  test('createPost sends correct payload', () async {
    late RequestOptions capturedRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'post': {
            'id': 'post-1',
            'workspaceId': 'workspace-1',
            'content': 'Hello world',
            'status': 'SCHEDULED',
            'scheduledFor': '2026-06-20T15:00:00.000Z',
            'publishedAt': null,
            'createdAt': '2026-06-20T10:00:00.000Z',
            'updatedAt': '2026-06-20T10:00:00.000Z',
            'postTargets': [],
          },
        };
      }),
    );

    final post = await service.createPost(
      workspaceId: 'workspace-1',
      content: 'Hello world',
      scheduledFor: DateTime.utc(2026, 6, 20, 15),
      targets: [
        {'socialAccountId': 'account-1', 'mediaUrls': []},
      ],
    );

    expect(post.id, 'post-1');
    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.uri.path, '/mobile/posts');
    final data = capturedRequest.data as Map<String, dynamic>;
    expect(data['workspaceId'], 'workspace-1');
    expect(data['content'], 'Hello world');
    expect((data['targets'] as List).first['socialAccountId'], 'account-1');
  });

  test('deletePost calls DELETE /mobile/posts/:id', () async {
    late RequestOptions capturedRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return const {};
      }),
    );

    await service.deletePost('post-1');

    expect(capturedRequest.method, 'DELETE');
    expect(capturedRequest.uri.path, '/mobile/posts/post-1');
  });

  test('retryPost calls POST /mobile/posts/:id/retry', () async {
    late RequestOptions capturedRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'post': {
            'id': 'post-1',
            'workspaceId': 'workspace-1',
            'content': 'Hello',
            'status': 'SCHEDULED',
            'scheduledFor': null,
            'publishedAt': null,
            'createdAt': '2026-06-20T10:00:00.000Z',
            'updatedAt': '2026-06-20T10:00:00.000Z',
            'postTargets': [],
          },
        };
      }),
    );

    final post = await service.retryPost('post-1');

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.uri.path, '/mobile/posts/post-1/retry');
    expect(post.id, 'post-1');
  });

  test('createPost throws ApiException on backend error', () async {
    final service = PostService(
      apiClient: _mockFailingApiClient({'message': 'content is required'}),
    );

    await expectLater(
      service.createPost(
        workspaceId: 'workspace-1',
        content: '',
        targets: [],
      ),
      throwsA(isA<ApiException>()),
    );
  });
}

ApiClient _mockApiClient(
  Map<String, dynamic> Function(RequestOptions options) handler,
) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, requestHandler) {
        requestHandler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: handler(options),
          ),
        );
      },
    ),
  );
  return ApiClient(
    dio: dio,
    baseUri: Uri.parse('http://127.0.0.1:4000'),
    enableAuthInterceptor: false,
  );
}

ApiClient _mockFailingApiClient(Map<String, dynamic> body) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, requestHandler) {
        requestHandler.reject(
          DioException(
            requestOptions: options,
            response: Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 400,
              data: body,
            ),
          ),
        );
      },
    ),
  );
  return ApiClient(
    dio: dio,
    baseUri: Uri.parse('http://127.0.0.1:4000'),
    enableAuthInterceptor: false,
  );
}
