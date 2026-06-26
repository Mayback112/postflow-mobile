import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/api/api.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/services/post_service.dart';

void main() {
  test('listPosts sends workspace and status query', () async {
    late RequestOptions capturedRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'posts': [
            {
              'id': 'post-1',
              'workspaceId': 'workspace-1',
              'status': 'SCHEDULED',
              'caption': 'Scheduled caption',
              'hashtags': ['launch'],
              'mediaAssets': [],
              'platforms': [],
            },
          ],
        };
      }),
    );

    final posts = await service.listPosts(
      workspaceId: 'workspace-1',
      status: 'SCHEDULED',
    );

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.uri.path, '/mobile/posts');
    expect(capturedRequest.uri.queryParameters, {
      'workspaceId': 'workspace-1',
      'status': 'SCHEDULED',
    });
    expect(posts.single.id, 'post-1');
    expect(posts.single.hashtags, ['launch']);
  });

  test(
    'createPost sends mobile draft payload with ordered media ids',
    () async {
      late RequestOptions capturedRequest;
      final service = PostService(
        apiClient: _mockApiClient((options) {
          capturedRequest = options;
          return {
            'post': {'id': 'post-1'},
          };
        }),
      );

      final post = await service.createPost(
        workspaceId: 'workspace-1',
        caption: 'Optional caption',
        hashtags: ['#launch', 'postflow'],
        mediaAssetIds: ['media-2', 'media-1'],
        platforms: const [
          PostPlatformTarget(
            platform: 'TIKTOK',
            accountId: 'account-1',
            publishOptions: {'autoAddMusic': true},
          ),
        ],
        scheduledAt: DateTime.utc(2026, 6, 20, 15),
      );

      expect(post.id, 'post-1');
      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.uri.path, '/mobile/posts');
      expect(capturedRequest.data, {
        'workspaceId': 'workspace-1',
        'caption': 'Optional caption',
        'hashtags': ['launch', 'postflow'],
        'mediaAssetIds': ['media-2', 'media-1'],
        'platforms': [
          {
            'platform': 'TIKTOK',
            'accountId': 'account-1',
            'publishOptions': {'autoAddMusic': true},
          },
        ],
        'scheduledAt': '2026-06-20T15:00:00.000Z',
      });
    },
  );

  test('uploadAndRegisterMedia signs, uploads, and registers media', () async {
    final backendRequests = <RequestOptions>[];
    late RequestOptions cloudinaryRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        backendRequests.add(options);
        if (options.uri.path == '/mobile/media/upload-signature') {
          return {
            'cloudName': 'demo-cloud',
            'apiKey': 'cloud-api-key',
            'folder': 'postflow/accounts/user-1/workspaces/workspace-1',
            'timestamp': 1781977200,
            'signature': 'signed-value',
            'useFilename': true,
            'uniqueFilename': true,
            'overwrite': false,
          };
        }

        return {
          'mediaAsset': {'id': 'media-1'},
        };
      }),
      cloudinaryDio: _mockCloudinaryDio((options) {
        cloudinaryRequest = options;
        return {
          'public_id':
              'postflow/accounts/user-1/workspaces/workspace-1/image-1',
          'secure_url': 'https://res.cloudinary.com/demo/image/upload/image-1',
          'resource_type': 'image',
          'width': 1080,
          'height': 1080,
        };
      }),
    );

    final mediaAssetIds = await service.uploadAndRegisterMedia(
      workspaceId: 'workspace-1',
      platform: 'INSTAGRAM',
      files: [
        PlatformFile(
          name: 'image-1.png',
          size: 3,
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
      ],
    );

    expect(mediaAssetIds, ['media-1']);
    expect(backendRequests[0].uri.path, '/mobile/media/upload-signature');
    expect(backendRequests[0].data, {
      'workspaceId': 'workspace-1',
      'platform': 'INSTAGRAM',
    });
    expect(cloudinaryRequest.uri.host, 'api.cloudinary.com');
    expect(cloudinaryRequest.uri.path, '/v1_1/demo-cloud/auto/upload');
    expect(backendRequests[1].uri.path, '/mobile/media');
    expect(backendRequests[1].data, {
      'workspaceId': 'workspace-1',
      'cloudinaryId': 'postflow/accounts/user-1/workspaces/workspace-1/image-1',
      'secureUrl': 'https://res.cloudinary.com/demo/image/upload/image-1',
      'resourceType': 'image',
      'width': 1080,
      'height': 1080,
    });
  });

  test('uploadAndRegisterMedia blocks invalid Instagram image ratio', () async {
    final backendRequests = <RequestOptions>[];
    final service = PostService(
      apiClient: _mockApiClient((options) {
        backendRequests.add(options);
        return {
          'cloudName': 'demo-cloud',
          'apiKey': 'cloud-api-key',
          'folder': 'postflow/accounts/user-1/workspaces/workspace-1',
          'timestamp': 1781977200,
          'signature': 'signed-value',
          'useFilename': true,
          'uniqueFilename': true,
          'overwrite': false,
        };
      }),
      cloudinaryDio: _mockCloudinaryDio((options) {
        return {
          'public_id':
              'postflow/accounts/user-1/workspaces/workspace-1/story-image',
          'secure_url':
              'https://res.cloudinary.com/demo/image/upload/story-image',
          'resource_type': 'image',
          'width': 720,
          'height': 1280,
        };
      }),
    );

    await expectLater(
      service.uploadAndRegisterMedia(
        workspaceId: 'workspace-1',
        platform: 'INSTAGRAM',
        files: [
          PlatformFile(
            name: 'story.png',
            size: 3,
            bytes: Uint8List.fromList([1, 2, 3]),
          ),
        ],
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          contains('Crop it to 4:5 or 3:4'),
        ),
      ),
    );
    expect(backendRequests.length, 1);
  });

  test('updatePost patches only changed fields', () async {
    late RequestOptions capturedRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'post': {
            'id': 'post-1',
            'workspaceId': 'workspace-1',
            'status': 'DRAFT',
            'caption': 'Updated caption',
            'hashtags': ['updated'],
            'mediaAssets': [],
            'platforms': [],
          },
        };
      }),
    );

    final post = await service.updatePost(
      postId: 'post-1',
      caption: 'Updated caption',
      hashtags: ['#updated'],
      scheduledAt: null,
    );

    expect(capturedRequest.method, 'PATCH');
    expect(capturedRequest.uri.path, '/mobile/posts/post-1');
    expect(capturedRequest.data, {
      'caption': 'Updated caption',
      'hashtags': ['updated'],
      'scheduledAt': null,
    });
    expect(post.caption, 'Updated caption');
  });

  test('schedulePost sends future scheduledAt to backend', () async {
    late RequestOptions capturedRequest;
    final service = PostService(
      apiClient: _mockApiClient((options) {
        capturedRequest = options;
        return {
          'post': {
            'id': 'post-1',
            'workspaceId': 'workspace-1',
            'status': 'SCHEDULED',
            'caption': 'Scheduled caption',
            'hashtags': [],
            'mediaAssets': [],
            'platforms': [],
            'scheduledAt': '2026-06-20T15:00:00.000Z',
          },
        };
      }),
    );

    final post = await service.schedulePost(
      postId: 'post-1',
      scheduledAt: DateTime.utc(2026, 6, 20, 15),
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.uri.path, '/mobile/posts/post-1/schedule');
    expect(capturedRequest.data, {'scheduledAt': '2026-06-20T15:00:00.000Z'});
    expect(post.status, 'SCHEDULED');
  });

  test('deletePost calls delete mobile post endpoint', () async {
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

  test('ApiClient cleans nested backend error JSON', () async {
    final service = PostService(
      apiClient: _mockFailingApiClient({
        'message':
            "Zernio request failed (400): {\"error\":\"Instagram Image 1: Aspect ratio 0.56:1 is outside Instagram's allowed range.\"}",
      }),
    );

    await expectLater(
      service.createPost(
        workspaceId: 'workspace-1',
        caption: 'Caption',
        hashtags: const [],
        mediaAssetIds: const [],
        platforms: const [
          PostPlatformTarget(platform: 'INSTAGRAM', accountId: 'account-1'),
        ],
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          "Instagram Image 1: Aspect ratio 0.56:1 is outside Instagram's allowed range.",
        ),
      ),
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

Dio _mockCloudinaryDio(
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
  return dio;
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
