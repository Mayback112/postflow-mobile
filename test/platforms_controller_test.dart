import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/platforms_controller.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/models/social_connect_models.dart';
import 'package:postflow/models/workspace.dart';
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
  const tiktok = SocialAccount(
    id: 'account-2',
    workspaceId: 'workspace-1',
    platform: 'TIKTOK',
    displayName: 'Brand TikTok',
    provider: 'ZERNIO',
    isActive: true,
    username: 'brandtok',
  );

  test('loads workspace and social accounts', () async {
    final controller = PlatformsController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: _FakeSocialAccountService(
        listedAccounts: const [instagram],
      ),
    );

    await controller.loadAccounts();

    expect(controller.isLoading, isFalse);
    expect(controller.workspace?.id, workspace.id);
    expect(controller.accounts, const [instagram]);
    expect(controller.accountForPlatform('INSTAGRAM'), instagram);
  });

  test(
    'keeps pending connect notice until requested platform is active',
    () async {
      final socialService = _FakeSocialAccountService(
        listedAccounts: const [instagram],
        syncedAccounts: const [instagram],
      );
      final controller = PlatformsController(
        workspaceService: _FakeWorkspaceService(workspace: workspace),
        socialAccountService: socialService,
      );

      await controller.loadAccounts();
      await controller.connectPlatform('TikTok');

      expect(controller.connectStarted, isTrue);
      expect(socialService.connectedPlatform, 'TIKTOK');

      await controller.syncAccountsAfterConnect();

      expect(controller.connectStarted, isTrue);
      expect(controller.accounts, const [instagram]);

      socialService.syncedAccounts = const [instagram, tiktok];
      await controller.syncAccountsAfterConnect();

      expect(controller.connectStarted, isFalse);
      expect(
        controller.successMessage,
        'Social account connected successfully.',
      );
      expect(controller.accountForPlatform('TIKTOK'), tiktok);
    },
  );

  test('handles denied mobile callback as visible error', () async {
    final socialService = _FakeSocialAccountService(
      listedAccounts: const [instagram],
    );
    final controller = PlatformsController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: socialService,
    );

    await controller.loadAccounts();
    await controller.connectPlatform('Facebook');
    await controller.handleConnectCallback(
      Uri.parse(
        'postflow://social-accounts/zernio/callback?error=oauth_denied&platform=facebook',
      ),
    );

    expect(controller.connectStarted, isFalse);
    expect(controller.successMessage, isNull);
    expect(controller.errorMessage, contains('facebook connection'));
    expect(controller.errorMessage, contains('cancelled or denied'));
  });

  test('polls connect status before syncing accounts', () async {
    final socialService = _FakeSocialAccountService(
      listedAccounts: const [instagram],
      syncedAccounts: const [instagram, tiktok],
      statusResult: const SocialConnectStatusResult(
        status: SocialConnectStatus.success,
        platform: 'TIKTOK',
      ),
    );
    final controller = PlatformsController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: socialService,
    );

    await controller.loadAccounts();
    await controller.connectPlatform('TikTok');
    await controller.syncAccountsAfterConnect();

    expect(socialService.checkedState, 'connect-state-1');
    expect(socialService.syncCount, 1);
    expect(controller.connectStarted, isFalse);
    expect(controller.accountForPlatform('TIKTOK'), tiktok);
  });

  test('shows status error without syncing accounts', () async {
    final socialService = _FakeSocialAccountService(
      listedAccounts: const [instagram],
      statusResult: const SocialConnectStatusResult(
        status: SocialConnectStatus.error,
        error: 'oauth_denied',
        platform: 'FACEBOOK',
      ),
    );
    final controller = PlatformsController(
      workspaceService: _FakeWorkspaceService(workspace: workspace),
      socialAccountService: socialService,
    );

    await controller.loadAccounts();
    await controller.connectPlatform('Facebook');
    await controller.syncAccountsAfterConnect();

    expect(socialService.syncCount, 0);
    expect(controller.connectStarted, isFalse);
    expect(controller.errorMessage, contains('facebook connection'));
    expect(controller.errorMessage, contains('cancelled or denied'));
  });

  test('maps backend CONNECTED status to success', () {
    final result = SocialConnectStatusResult.fromJson({
      'status': 'CONNECTED',
      'platform': 'INSTAGRAM',
    });

    expect(result.status, SocialConnectStatus.success);
    expect(result.platform, 'INSTAGRAM');
  });
}

class _FakeWorkspaceService extends WorkspaceService {
  _FakeWorkspaceService({required this.workspace});

  final Workspace workspace;

  @override
  Future<Workspace> ensureSelectedWorkspace() async => workspace;
}

class _FakeSocialAccountService extends SocialAccountService {
  _FakeSocialAccountService({
    this.listedAccounts = const [],
    this.syncedAccounts = const [],
    this.statusResult,
  });

  List<SocialAccount> listedAccounts;
  List<SocialAccount> syncedAccounts;
  SocialConnectStatusResult? statusResult;
  String? connectedPlatform;
  String? checkedState;
  int syncCount = 0;

  @override
  Future<SocialConnectStart> connectPlatform({
    required String workspaceId,
    required String platform,
  }) async {
    connectedPlatform = platform;
    return const SocialConnectStart(state: 'connect-state-1');
  }

  @override
  Future<SocialConnectStatusResult> connectStatus({
    required String state,
  }) async {
    checkedState = state;
    return statusResult ??
        const SocialConnectStatusResult(status: SocialConnectStatus.unknown);
  }

  @override
  Future<List<SocialAccount>> listAccounts({
    required String workspaceId,
  }) async {
    return listedAccounts;
  }

  @override
  Future<List<SocialAccount>> syncAccounts({
    required String workspaceId,
  }) async {
    syncCount += 1;
    return syncedAccounts;
  }
}
