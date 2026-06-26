import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/create_post_controller.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Default Workspace');
  const instagram = SocialAccount(
    id: 'account-1',
    workspaceId: 'workspace-1',
    platform: 'INSTAGRAM',
    displayName: 'Brand Instagram',
    provider: 'ZERNIO',
    isActive: true,
    username: 'brand',
  );

  test('loads initial workspace and active accounts', () async {
    final controller = CreatePostController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: _FakeSocialAccountService(
        listedAccounts: const [instagram],
      ),
    );

    await controller.loadInitialData();

    expect(controller.isLoading, isFalse);
    expect(controller.workspace?.id, workspace.id);
    expect(controller.accounts, const [instagram]);
  });

  test('validates empty content', () async {
    final controller = CreatePostController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: _FakeSocialAccountService(
        listedAccounts: const [instagram],
      ),
    );

    await controller.loadInitialData();

    final post = await controller.submitPost(
      baseContent: '   ',
      selectedPlatformNames: const ['Instagram'],
      hasMedia: false,
      isVideo: false,
    );

    expect(post, isNull);
    expect(controller.errorMessage, 'Post content cannot be empty.');
  });

  test('validates no platforms selected', () async {
    final controller = CreatePostController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: _FakeSocialAccountService(
        listedAccounts: const [instagram],
      ),
    );

    await controller.loadInitialData();

    final post = await controller.submitPost(
      baseContent: 'Hello world',
      selectedPlatformNames: const [],
      hasMedia: false,
      isVideo: false,
    );

    expect(post, isNull);
    expect(controller.errorMessage, 'At least one platform must be selected.');
  });

  test('submits post with valid parameters', () async {
    final postService = _FakePostService();
    final controller = CreatePostController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: _FakeSocialAccountService(
        listedAccounts: const [instagram],
      ),
      postService: postService,
    );

    await controller.loadInitialData();

    final date = DateTime.now().add(const Duration(days: 1));
    final post = await controller.submitPost(
      baseContent: 'Hello world',
      selectedPlatformNames: const ['Instagram'],
      hasMedia: true,
      isVideo: false,
      scheduledFor: date,
    );

    expect(post, isNotNull);
    expect(post!.content, 'Hello world');
    expect(postService.createdWorkspaceId, workspace.id);
    expect(postService.createdContent, 'Hello world');
    expect(postService.createdScheduledFor, date);
    expect(postService.createdTargets.length, 1);
    expect(postService.createdTargets.first['socialAccountId'], instagram.id);
    expect(
      (postService.createdTargets.first['mediaUrls'] as List).first,
      'https://picsum.photos/800/800',
    );
  });
}

class _FakeWorkspaceService extends WorkspaceService {
  _FakeWorkspaceService({required this.workspace});

  final Workspace workspace;

  @override
  Future<Workspace> ensureSelectedWorkspace() async => workspace;
}

class _FakeSocialAccountService extends SocialAccountService {
  _FakeSocialAccountService({this.listedAccounts = const []});

  final List<SocialAccount> listedAccounts;

  @override
  Future<List<SocialAccount>> listAccounts({
    required String workspaceId,
  }) async {
    return listedAccounts;
  }
}

class _FakePostService extends PostService {
  String? createdWorkspaceId;
  String? createdContent;
  DateTime? createdScheduledFor;
  List<Map<String, dynamic>> createdTargets = const [];

  @override
  Future<Post> createPost({
    required String workspaceId,
    required String content,
    DateTime? scheduledFor,
    bool? isDraft,
    bool? publishNow,
    required List<Map<String, dynamic>> targets,
  }) async {
    createdWorkspaceId = workspaceId;
    createdContent = content;
    createdScheduledFor = scheduledFor;
    createdTargets = targets;

    return Post(
      id: 'post-1',
      workspaceId: workspaceId,
      content: content,
      status: 'SCHEDULED',
      scheduledFor: scheduledFor,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      postTargets: const [],
    );
  }
}
