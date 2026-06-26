import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/home_controller.dart';
import 'package:postflow/models/post_models.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');

  test('loads home posts and connected accounts', () async {
    final postService = _FakePostService([
      MobilePost(
        id: 'post-1',
        workspaceId: 'workspace-1',
        status: 'SCHEDULED',
        caption: 'Launch day',
        hashtags: const ['launch'],
        scheduledAt: DateTime.utc(2026, 6, 20, 15),
        mediaAssets: const [
          PostMediaAsset(
            id: 'media-1',
            resourceType: 'image',
            displayOrder: 0,
            thumbnailUrl: 'https://cdn.example.com/thumb.jpg',
          ),
        ],
        platforms: const [
          PostPlatform(
            id: 'platform-1',
            platform: 'INSTAGRAM',
            accountId: 'account-1',
            status: 'SCHEDULED',
            publishOptions: {},
          ),
        ],
      ),
    ]);
    final controller = HomeController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        const SocialAccount(
          id: 'account-1',
          workspaceId: 'workspace-1',
          platform: 'INSTAGRAM',
          displayName: 'Brand Instagram',
          provider: 'ZERNIO',
          isActive: true,
        ),
      ]),
      postService: postService,
    );

    await controller.loadHome();

    expect(postService.capturedWorkspaceId, 'workspace-1');
    expect(controller.isLoading, isFalse);
    expect(controller.upcomingPost?.title, 'Launch day');
    expect(
      controller.upcomingPost?.imageUrl,
      'https://cdn.example.com/thumb.jpg',
    );
    expect(controller.schedules.single.title, 'Launch day');
    expect(controller.connectedPlatforms.single.name, 'Instagram');
    expect(controller.scheduledCount, 1);
  });

  test('uses a Cloudinary video thumbnail for upcoming video posts', () async {
    final controller = HomeController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        const SocialAccount(
          id: 'account-1',
          workspaceId: 'workspace-1',
          platform: 'INSTAGRAM',
          displayName: 'Brand Instagram',
          provider: 'ZERNIO',
          isActive: true,
        ),
      ]),
      postService: _FakePostService([
        MobilePost(
          id: 'post-1',
          workspaceId: 'workspace-1',
          status: 'SCHEDULED',
          caption: 'Video launch',
          hashtags: const [],
          scheduledAt: DateTime.utc(2026, 6, 20, 15),
          mediaAssets: const [
            PostMediaAsset(
              id: 'media-1',
              resourceType: 'video',
              displayOrder: 0,
              secureUrl:
                  'https://res.cloudinary.com/demo/video/upload/sample.mp4',
            ),
          ],
          platforms: const [],
        ),
      ]),
    );

    await controller.loadHome();

    expect(
      controller.upcomingPost?.imageUrl,
      'https://res.cloudinary.com/demo/video/upload/so_0/sample.jpg',
    );
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
  Future<List<SocialAccount>> listAccounts({
    required String workspaceId,
  }) async {
    return accounts;
  }
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
