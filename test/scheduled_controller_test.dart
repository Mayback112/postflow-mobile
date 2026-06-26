import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/scheduled_controller.dart';
import 'package:postflow/models/post_models.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');

  test('loads posts for selected workspace', () async {
    final service = _FakePostService([
      _post(id: 'draft-1', status: 'DRAFT'),
      _post(id: 'scheduled-1', status: 'SCHEDULED'),
    ]);
    final controller = ScheduledController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: service,
    );

    await controller.loadPosts();

    expect(service.capturedWorkspaceId, 'workspace-1');
    expect(controller.isLoading, isFalse);
    expect(controller.posts.length, 2);
    expect(controller.countFor('DRAFT'), 1);
    expect(controller.countFor('SCHEDULED'), 1);
  });

  test('filters scheduled posts', () async {
    final controller = ScheduledController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: _FakePostService([
        _post(id: 'draft-1', status: 'DRAFT'),
        _post(id: 'scheduled-1', status: 'SCHEDULED'),
      ]),
    );

    await controller.loadPosts();
    controller.setFilter(ScheduledPostFilter.scheduled);

    expect(controller.visiblePosts.map((post) => post.id), ['scheduled-1']);
  });

  test('schedulePost replaces draft with scheduled post', () async {
    final service = _FakePostService([_post(id: 'draft-1', status: 'DRAFT')]);
    final controller = ScheduledController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: service,
    );

    await controller.loadPosts();
    await controller.schedulePost('draft-1', DateTime.utc(2026, 6, 20, 15));

    expect(service.scheduledPostId, 'draft-1');
    expect(controller.posts.single.status, 'SCHEDULED');
    expect(controller.posts.single.scheduledAt, DateTime.utc(2026, 6, 20, 15));
  });

  test('deletePost removes post from list', () async {
    final service = _FakePostService([
      _post(id: 'draft-1', status: 'DRAFT'),
      _post(id: 'scheduled-1', status: 'SCHEDULED'),
    ]);
    final controller = ScheduledController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: service,
    );

    await controller.loadPosts();
    await controller.deletePost('draft-1');

    expect(service.deletedPostId, 'draft-1');
    expect(controller.posts.map((post) => post.id), ['scheduled-1']);
  });
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
  String? scheduledPostId;
  String? deletedPostId;

  @override
  Future<List<MobilePost>> listPosts({
    required String workspaceId,
    String? status,
  }) async {
    capturedWorkspaceId = workspaceId;
    return posts;
  }

  @override
  Future<MobilePost> schedulePost({
    required String postId,
    required DateTime scheduledAt,
  }) async {
    scheduledPostId = postId;
    return _post(id: postId, status: 'SCHEDULED', scheduledAt: scheduledAt);
  }

  @override
  Future<void> deletePost(String postId) async {
    deletedPostId = postId;
  }
}

MobilePost _post({
  required String id,
  required String status,
  DateTime? scheduledAt,
}) {
  return MobilePost(
    id: id,
    workspaceId: 'workspace-1',
    status: status,
    caption: '$status post',
    hashtags: const [],
    mediaAssets: const [],
    platforms: const [],
    scheduledAt: scheduledAt,
    createdAt: DateTime.utc(2026, 6, 14),
  );
}
