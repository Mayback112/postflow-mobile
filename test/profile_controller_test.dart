import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/controllers/profile_controller.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/models/post_models.dart';
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
      const MobilePost(
        id: 'post-1',
        workspaceId: 'workspace-1',
        status: 'SCHEDULED',
        caption: 'Scheduled post',
        hashtags: [],
        mediaAssets: [],
        platforms: [],
      ),
      const MobilePost(
        id: 'post-2',
        workspaceId: 'workspace-1',
        status: 'DRAFT',
        caption: 'Draft post',
        hashtags: [],
        mediaAssets: [],
        platforms: [],
      ),
      const MobilePost(
        id: 'post-3',
        workspaceId: 'workspace-1',
        status: 'CANCELED',
        caption: 'Canceled post',
        hashtags: [],
        mediaAssets: [],
        platforms: [],
      ),
    ]);
    final socialAccountService = _FakeSocialAccountService([
      const SocialAccount(
        id: 'account-1',
        workspaceId: 'workspace-1',
        platform: 'INSTAGRAM',
        displayName: 'Brand Instagram',
        provider: 'ZERNIO',
        isActive: true,
      ),
      const SocialAccount(
        id: 'account-2',
        workspaceId: 'workspace-1',
        platform: 'YOUTUBE',
        displayName: 'Old YouTube',
        provider: 'ZERNIO',
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
    expect(controller.postCount, 2);
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

  final List<MobilePost> posts;
  String? capturedWorkspaceId;

  @override
  Future<List<MobilePost>> listPosts({
    required String workspaceId,
    String? status,
  }) async {
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
