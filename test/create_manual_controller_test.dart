import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/create_manual_controller.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/social_account_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');
  const instagramAccount = SocialAccount(
    id: 'account-1',
    workspaceId: 'workspace-1',
    platform: 'INSTAGRAM',
    displayName: 'Postflow IG',
    provider: 'ZERNIO',
    isActive: true,
    zernioAccountId: 'zernio-instagram',
  );
  const youtubeAccount = SocialAccount(
    id: 'account-youtube',
    workspaceId: 'workspace-1',
    platform: 'YOUTUBE',
    displayName: 'Postflow YouTube',
    provider: 'ZERNIO',
    isActive: true,
    zernioAccountId: 'zernio-youtube',
  );
  const facebookAccount = SocialAccount(
    id: 'account-facebook',
    workspaceId: 'workspace-1',
    platform: 'FACEBOOK',
    displayName: 'Postflow Facebook',
    provider: 'ZERNIO',
    isActive: true,
    zernioAccountId: 'zernio-facebook',
  );
  const tiktokAccount = SocialAccount(
    id: 'account-tiktok',
    workspaceId: 'workspace-1',
    platform: 'TIKTOK',
    displayName: 'Postflow TikTok',
    provider: 'ZERNIO',
    isActive: true,
    zernioAccountId: 'zernio-tiktok',
  );
  const linkedInAccount = SocialAccount(
    id: 'account-linkedin',
    workspaceId: 'workspace-1',
    platform: 'LINKEDIN',
    displayName: 'Postflow LinkedIn',
    provider: 'ZERNIO',
    isActive: true,
    zernioAccountId: 'zernio-linkedin',
  );
  const xAccount = SocialAccount(
    id: 'account-x',
    workspaceId: 'workspace-1',
    platform: 'X',
    displayName: 'Postflow X',
    provider: 'ZERNIO',
    isActive: true,
    zernioAccountId: 'zernio-x',
  );
  const threadsAccount = SocialAccount(
    id: 'account-threads',
    workspaceId: 'workspace-1',
    platform: 'THREADS',
    displayName: 'Postflow Threads',
    provider: 'ZERNIO',
    isActive: true,
    zernioAccountId: 'zernio-threads',
  );

  test('loads active post targets', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        instagramAccount,
        const SocialAccount(
          id: 'account-2',
          workspaceId: 'workspace-1',
          platform: 'TIKTOK',
          displayName: 'Inactive TikTok',
          provider: 'ZERNIO',
          isActive: false,
        ),
        const SocialAccount(
          id: 'account-unlinked',
          workspaceId: 'workspace-1',
          platform: 'FACEBOOK',
          displayName: 'Unlinked Facebook',
          provider: 'ZERNIO',
          isActive: true,
        ),
        const SocialAccount(
          id: 'account-native',
          workspaceId: 'workspace-1',
          platform: 'LINKEDIN',
          displayName: 'Native LinkedIn',
          provider: 'NATIVE',
          isActive: true,
          zernioAccountId: 'zernio-native',
        ),
      ]),
    );

    await controller.loadPostTargets();

    expect(controller.isLoadingTargets, isFalse);
    expect(controller.accounts, [instagramAccount]);
  });

  test('requires text for text-only posts', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([facebookAccount]),
      postService: _FakePostService(),
    );

    await controller.loadPostTargets();
    controller.toggleAccount('account-facebook');

    final result = await controller.submitPost(schedule: false);

    expect(result, CreatePostResult.needsSchedule);
    expect(controller.errorMessage, 'Write the text for this post.');
  });

  test('submits ordered media asset ids with selected account', () async {
    final postService = _FakePostService(
      uploadedMediaIds: ['media-2', 'media-1'],
    );
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([instagramAccount]),
      postService: postService,
    );

    await controller.loadPostTargets();
    controller.selectType(PostContentType.mixed);
    controller.toggleAccount('account-1');
    controller.setCaption('Optional caption');
    controller.setResources([
      PlatformFile(name: 'second.png', size: 1, bytes: Uint8List.fromList([2])),
      PlatformFile(name: 'first.png', size: 1, bytes: Uint8List.fromList([1])),
    ]);

    final result = await controller.submitPost(schedule: false);

    expect(result, CreatePostResult.created);
    expect(postService.capturedWorkspaceId, 'workspace-1');
    expect(postService.capturedPlatform, 'INSTAGRAM');
    expect(postService.capturedFileNames, ['second.png', 'first.png']);
    expect(postService.capturedMediaAssetIds, ['media-2', 'media-1']);
    expect(postService.capturedPlatforms.single.accountId, 'account-1');
  });

  test('hides YouTube unless exactly one video is selected', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        instagramAccount,
        youtubeAccount,
      ]),
    );

    await controller.loadPostTargets();

    expect(controller.compatibleAccounts, isEmpty);

    controller.selectType(PostContentType.video);
    expect(controller.compatibleAccounts, [instagramAccount]);

    controller.setResources([
      PlatformFile(name: 'clip.mp4', size: 1, bytes: Uint8List.fromList([1])),
    ]);
    expect(controller.compatibleAccounts, [instagramAccount, youtubeAccount]);

    controller.setResources([
      PlatformFile(name: 'clip-1.mp4', size: 1, bytes: Uint8List.fromList([1])),
      PlatformFile(name: 'clip-2.mp4', size: 1, bytes: Uint8List.fromList([2])),
    ]);
    expect(controller.compatibleAccounts, [instagramAccount]);

    controller.selectType(PostContentType.image);
    expect(controller.compatibleAccounts, [instagramAccount]);

    controller.selectType(PostContentType.mixed);
    expect(controller.compatibleAccounts, [instagramAccount]);
  });

  test(
    'removes selected YouTube account when content changes to image',
    () async {
      final controller = CreateManualController(
        workspaceService: _FakeWorkspaceService(workspace),
        socialAccountService: _FakeSocialAccountService([
          instagramAccount,
          youtubeAccount,
        ]),
      );

      await controller.loadPostTargets();
      controller.selectType(PostContentType.video);
      controller.setResources([
        PlatformFile(name: 'clip.mp4', size: 1, bytes: Uint8List.fromList([1])),
      ]);
      controller.toggleAccount('account-youtube');

      expect(controller.selectedAccountIds, contains('account-youtube'));

      controller.selectType(PostContentType.image);

      expect(controller.selectedAccountIds, isNot(contains('account-youtube')));
      expect(controller.compatibleAccounts, [instagramAccount]);
    },
  );

  test(
    'text-only supports Facebook but not Instagram TikTok or YouTube',
    () async {
      final controller = CreateManualController(
        workspaceService: _FakeWorkspaceService(workspace),
        socialAccountService: _FakeSocialAccountService([
          instagramAccount,
          facebookAccount,
          tiktokAccount,
          youtubeAccount,
        ]),
      );

      await controller.loadPostTargets();

      expect(controller.compatibleAccounts, [facebookAccount]);
    },
  );

  test('TikTok image post sends auto music publish option', () async {
    final postService = _FakePostService(uploadedMediaIds: ['media-1']);
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([tiktokAccount]),
      postService: postService,
    );

    await controller.loadPostTargets();
    controller.selectType(PostContentType.image);
    controller.setResources([
      PlatformFile(name: 'photo.png', size: 1, bytes: Uint8List.fromList([1])),
    ]);
    controller.toggleAccount('account-tiktok');

    expect(controller.showTikTokPhotoMusicOption, isTrue);

    final result = await controller.submitPost(schedule: false);

    expect(result, CreatePostResult.created);
    expect(postService.capturedPlatforms.single.publishOptions, {
      'autoAddMusic': true,
    });
  });

  test('mixed image and video only supports Instagram', () async {
    final controller = CreateManualController(
      workspaceService: _FakeWorkspaceService(workspace),
      socialAccountService: _FakeSocialAccountService([
        instagramAccount,
        facebookAccount,
        tiktokAccount,
        youtubeAccount,
        linkedInAccount,
        xAccount,
        threadsAccount,
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
        instagramAccount,
        facebookAccount,
        tiktokAccount,
        linkedInAccount,
        xAccount,
        threadsAccount,
      ]),
    );

    await controller.loadPostTargets();
    controller.selectType(PostContentType.image);

    controller.setResources(_imageFiles(5));
    expect(controller.compatibleAccounts, [
      instagramAccount,
      facebookAccount,
      tiktokAccount,
      linkedInAccount,
      threadsAccount,
    ]);

    controller.setResources(_imageFiles(11));
    expect(controller.compatibleAccounts, [tiktokAccount, linkedInAccount]);

    controller.setResources(_imageFiles(21));
    expect(controller.compatibleAccounts, [tiktokAccount]);

    controller.setResources(_imageFiles(36));
    expect(controller.compatibleAccounts, isEmpty);
  });
}

List<PlatformFile> _imageFiles(int count) {
  return List.generate(
    count,
    (index) => PlatformFile(
      name: 'photo-$index.png',
      size: 1,
      bytes: Uint8List.fromList([index]),
    ),
  );
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
  _FakePostService({this.uploadedMediaIds = const []});

  final List<String> uploadedMediaIds;
  String? capturedWorkspaceId;
  String? capturedPlatform;
  List<String> capturedFileNames = const [];
  List<String> capturedMediaAssetIds = const [];
  List<PostPlatformTarget> capturedPlatforms = const [];

  @override
  Future<List<String>> uploadAndRegisterMedia({
    required String workspaceId,
    required String platform,
    required List<PlatformFile> files,
  }) async {
    capturedWorkspaceId = workspaceId;
    capturedPlatform = platform;
    capturedFileNames = files.map((file) => file.name).toList();
    return uploadedMediaIds;
  }

  @override
  Future<PostDraft> createPost({
    required String workspaceId,
    required String caption,
    required List<String> hashtags,
    required List<String> mediaAssetIds,
    required List<PostPlatformTarget> platforms,
    DateTime? scheduledAt,
  }) async {
    capturedMediaAssetIds = mediaAssetIds;
    capturedPlatforms = platforms;
    return const PostDraft(id: 'post-1');
  }
}
