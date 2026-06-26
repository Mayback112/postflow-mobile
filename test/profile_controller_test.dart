import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/controllers/profile_controller.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/auth_service.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const user = AuthUser(
    id: 'user-1',
    email: 'ada@example.com',
    name: 'Ada Lovelace',
    profileImageUrl: 'https://lh3.googleusercontent.com/a/image',
  );
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');

  test('loads current profile stats and connected accounts', () async {
    final authService = _FakeAuthService(user: user);
    final postService = _FakePostService([
      _post(id: 'post-1', status: 'SCHEDULED'),
      _post(id: 'post-2', status: 'DRAFT'),
      _post(id: 'post-3', status: 'PUBLISHED'),
    ]);
    final socialAccountService = _FakeSocialAccountService([
      const SocialAccount(
        id: 'account-1',
        workspaceId: 'workspace-1',
        platform: 'INSTAGRAM',
        displayName: 'Brand Instagram',
        provider: 'POSTFLOW',
        isActive: true,
      ),
      const SocialAccount(
        id: 'account-2',
        workspaceId: 'workspace-1',
        platform: 'YOUTUBE',
        displayName: 'Old YouTube',
        provider: 'POSTFLOW',
        isActive: false,
      ),
    ]);
    final controller = ProfileController(
      authService: authService,
      workspaceService: _FakeWorkspaceService(workspace),
      postService: postService,
      socialAccountService: socialAccountService,
    );

    await controller.loadProfile();

    expect(authService.meCallCount, 1);
    expect(postService.capturedWorkspaceId, 'workspace-1');
    expect(socialAccountService.capturedWorkspaceId, 'workspace-1');
    expect(controller.isLoading, isFalse);
    expect(controller.errorMessage, isNull);
    expect(controller.user?.email, 'ada@example.com');
    expect(controller.postCount, 3);
    expect(controller.scheduledCount, 1);
    expect(controller.connectedPlatformCount, 1);
    expect(controller.connectedAccounts.single.displayName, 'Brand Instagram');
  });

  test('surfaces auth endpoint errors', () async {
    final controller = ProfileController(
      authService: _FakeAuthService(error: const ApiException('Unauthorized')),
    );

    await controller.loadProfile();

    expect(controller.isLoading, isFalse);
    expect(controller.user, isNull);
    expect(controller.errorMessage, 'Unauthorized');
  });
}

Post _post({required String id, required String status}) {
  return Post(
    id: id,
    workspaceId: 'workspace-1',
    content: '$status post',
    status: status,
    createdAt: DateTime.utc(2026, 6, 14),
    updatedAt: DateTime.utc(2026, 6, 14),
    postTargets: const [],
  );
}

class _FakeAuthService extends AuthService {
  _FakeAuthService({this.user, this.error});

  final AuthUser? user;
  final Object? error;
  int meCallCount = 0;

  @override
  Future<AuthUser> me() async {
    meCallCount += 1;
    final capturedError = error;
    if (capturedError != null) throw capturedError;
    return user!;
  }
}

class _FakeWorkspaceService extends WorkspaceService {
  _FakeWorkspaceService(this.workspace);
  final Workspace workspace;

  @override
  Future<Workspace> ensureSelectedWorkspace() async => workspace;
}

class _FakePostService extends PostService {
  _FakePostService(this.posts);

  final List<Post> posts;
  String? capturedWorkspaceId;

  @override
  Future<List<Post>> listPosts({required String workspaceId}) async {
    capturedWorkspaceId = workspaceId;
    return posts;
  }
}

class _FakeSocialAccountService extends SocialAccountService {
  _FakeSocialAccountService(this.accounts);

  final List<SocialAccount> accounts;
  String? capturedWorkspaceId;

  @override
  Future<List<SocialAccount>> listAccounts({
    required String workspaceId,
  }) async {
    capturedWorkspaceId = workspaceId;
    return accounts;
  }
}
