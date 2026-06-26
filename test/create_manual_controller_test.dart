import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/create_manual_controller.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');

  const instagramAccount = SocialAccount(
    id: 'account-ig', workspaceId: 'workspace-1', platform: 'INSTAGRAM',
    displayName: 'Brand IG', provider: 'POSTFLOW', isActive: true,
  );
  const facebookAccount = SocialAccount(
    id: 'account-fb', workspaceId: 'workspace-1', platform: 'FACEBOOK',
    displayName: 'Brand FB', provider: 'POSTFLOW', isActive: true,
  );
  const tiktokAccount = SocialAccount(
    id: 'account-tt', workspaceId: 'workspace-1', platform: 'TIKTOK',
    displayName: 'Brand TT', provider: 'POSTFLOW', isActive: true,
  );
  const youtubeAccount = SocialAccount(
    id: 'account-yt', workspaceId: 'workspace-1', platform: 'YOUTUBE',
    displayName: 'Brand YT', provider: 'POSTFLOW', isActive: true,
  );
  const linkedInAccount = SocialAccount(
    id: 'account-li', workspaceId: 'workspace-1', platform: 'LINKEDIN',
    displayName: 'Brand LI', provider: 'POSTFLOW', isActive: true,
  );
  const xAccount = SocialAccount(
    id: 'account-x', workspaceId: 'workspace-1', platform: 'X',
    displayName: 'Brand X', provider: 'POSTFLOW', isActive: true,
  );
  const threadsAccount = SocialAccount(
    id: 'account-th', workspaceId: 'workspace-1', platform: 'THREADS',
    displayName: 'Brand TH', provider: 'POSTFLOW', isActive: true,
  );

  test('loads all active accounts regardless of provider', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        instagramAccount,
        const SocialAccount(
          id: 'account-inactive', workspaceId: 'workspace-1', platform: 'TIKTOK',
          displayName: 'Inactive', provider: 'POSTFLOW', isActive: false,
        ),
      ]),
    );

    await controller.loadPostTargets();

    expect(controller.accounts, [instagramAccount]);
  });

  test('requires text for text-only posts', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([facebookAccount]),
      postService: _FakePostService(),
    );

    await controller.loadPostTargets();
    controller.toggleAccount('account-fb');

    final result = await controller.submitPost(schedule: false);

    expect(result, CreatePostResult.needsSchedule);
    expect(controller.errorMessage, 'Write the text for this post.');
  });

  test('submitPost sends correct content and targets to PostService', () async {
    final postService = _FakePostService();
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([facebookAccount]),
      postService: postService,
    );

    await controller.loadPostTargets();
    controller.toggleAccount('account-fb');
    controller.setCaption('Hello world');
    controller.addHashtag('launch');

    final result = await controller.submitPost(schedule: false);

    expect(result, CreatePostResult.created);
    expect(postService.capturedContent, 'Hello world #launch');
    expect(postService.capturedTargets.single['socialAccountId'], 'account-fb');
  });

  test('text-only posts: Facebook supported, Instagram/TikTok/YouTube not', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        instagramAccount, facebookAccount, tiktokAccount, youtubeAccount,
      ]),
    );

    await controller.loadPostTargets();

    expect(controller.compatibleAccounts, [facebookAccount]);
  });

  test('mixed image+video only supported by Instagram', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        instagramAccount, facebookAccount, tiktokAccount, youtubeAccount,
        linkedInAccount, xAccount, threadsAccount,
      ]),
    );

    await controller.loadPostTargets();
    controller.selectType(PostContentType.mixed);
    controller.setResources([
      PlatformFile(name: 'photo.png', size: 1, bytes: Uint8List.fromList([1])),
      PlatformFile(name: 'clip.mp4', size: 1, bytes: Uint8List.fromList([2])),
    ]);

    expect(controller.compatibleAccounts, [instagramAccount]);
  });

  test('image limits match platform rules', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        instagramAccount, facebookAccount, tiktokAccount, linkedInAccount, xAccount, threadsAccount,
      ]),
    );

    await controller.loadPostTargets();
    controller.selectType(PostContentType.image);

    controller.setResources(_imageFiles(5));
    expect(controller.compatibleAccounts, containsAll([instagramAccount, facebookAccount, tiktokAccount, linkedInAccount]));

    controller.setResources(_imageFiles(11));
    expect(controller.compatibleAccounts, containsAll([tiktokAccount, linkedInAccount]));
    expect(controller.compatibleAccounts, isNot(contains(instagramAccount)));
  });

  test('YouTube requires exactly one video', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([instagramAccount, youtubeAccount]),
    );

    await controller.loadPostTargets();
    controller.selectType(PostContentType.video);

    controller.setResources([
      PlatformFile(name: 'clip.mp4', size: 1, bytes: Uint8List.fromList([1])),
    ]);
    expect(controller.compatibleAccounts, containsAll([instagramAccount, youtubeAccount]));

    controller.setResources([
      PlatformFile(name: 'clip1.mp4', size: 1, bytes: Uint8List.fromList([1])),
      PlatformFile(name: 'clip2.mp4', size: 1, bytes: Uint8List.fromList([2])),
    ]);
    expect(controller.compatibleAccounts, [instagramAccount]);
    expect(controller.compatibleAccounts, isNot(contains(youtubeAccount)));
  });
}

List<PlatformFile> _imageFiles(int count) => List.generate(
  count,
  (i) => PlatformFile(name: 'photo-$i.png', size: 1, bytes: Uint8List.fromList([i])),
);

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
  String? capturedContent;
  List<Map<String, dynamic>> capturedTargets = const [];

  @override
  Future<List<String>> uploadMediaFiles({
    required String workspaceId,
    required List<PlatformFile> files,
  }) async => const [];

  @override
  Future<Post> createPost({
    required String workspaceId,
    required String content,
    DateTime? scheduledFor,
    bool? isDraft,
    bool? publishNow,
    required List<Map<String, dynamic>> targets,
  }) async {
    capturedContent = content;
    capturedTargets = targets;
    return Post(
      id: 'post-1', workspaceId: workspaceId, content: content,
      status: 'DRAFT', createdAt: DateTime.utc(2026, 6, 14),
      updatedAt: DateTime.utc(2026, 6, 14), postTargets: const [],
    );
  }
}
