import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/home_controller.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');

  test('loads home posts and connected accounts', () async {
    final postService = _FakePostService([
      Post(
        id: 'post-1', workspaceId: 'workspace-1',
        content: 'Launch day', status: 'SCHEDULED',
        scheduledFor: DateTime.utc(2026, 6, 20, 15),
        createdAt: DateTime.utc(2026, 6, 14), updatedAt: DateTime.utc(2026, 6, 14),
        postTargets: [
          PostTarget(
            id: 'pt-1', postId: 'post-1', socialAccountId: 'account-1',
            platform: 'INSTAGRAM', mediaUrls: ['https://example.com/image.jpg'],
            status: 'PENDING', retryCount: 0,
            createdAt: DateTime.utc(2026, 6, 14), updatedAt: DateTime.utc(2026, 6, 14),
            socialAccount: SocialAccountSummary(
              id: 'account-1', platform: 'INSTAGRAM', status: 'ACTIVE', displayName: 'Brand IG',
            ),
          ),
        ],
      ),
    ]);
    final controller = HomeController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        const SocialAccount(
          id: 'account-1', workspaceId: 'workspace-1', platform: 'INSTAGRAM',
          displayName: 'Brand Instagram', provider: 'POSTFLOW', isActive: true,
        ),
      ]),
      postService: postService,
    );

    await controller.loadHomeData();

    expect(postService.capturedWorkspaceId, 'workspace-1');
    expect(controller.isLoading, isFalse);
    expect(controller.upcomingPost?.title, 'Launch day');
    expect(controller.schedules.single.title, 'Launch day');
    expect(controller.connectedPlatforms.single.name, 'Instagram');
  });

  test('no upcoming post when list is empty', () async {
    final controller = HomeController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService(const []),
      postService: _FakePostService(const []),
    );

    await controller.loadHomeData();

    expect(controller.upcomingPost, isNull);
    expect(controller.schedules, isEmpty);
  });
}

class _FakeWorkspaceService extends WorkspaceService {
  _FakeWorkspaceService(this.workspace);
  final Workspace workspace;
  @override
  Future<Workspace> ensureSelectedWorkspace() async => workspace;
}

class _FakeSocialAccountService extends SocialAccountService {
  _FakeSocialAccountService(this.accounts);
  final List<SocialAccount> accounts;
  @override
  Future<List<SocialAccount>> listAccounts({required String workspaceId}) async => accounts;
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
