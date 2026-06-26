import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/scheduled_controller.dart';
import 'package:postflow/models/post.dart';
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
    expect(controller.schedules.length, 2);
  });

  test('deletePost calls service and reloads', () async {
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
  });

  test('retryPost calls service and reloads', () async {
    final service = _FakePostService([
      _post(id: 'failed-1', status: 'FAILED'),
    ]);
    final controller = ScheduledController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: service,
    );

    await controller.loadPosts();
    await controller.retryPost('failed-1');

    expect(service.retriedPostId, 'failed-1');
  });
}

Post _post({required String id, required String status, DateTime? scheduledFor}) {
  return Post(
    id: id,
    workspaceId: 'workspace-1',
    content: '$status post',
    status: status,
    scheduledFor: scheduledFor,
    createdAt: DateTime.utc(2026, 6, 14),
    updatedAt: DateTime.utc(2026, 6, 14),
    postTargets: const [],
  );
}

class _FakeWorkspaceService extends WorkspaceService {
  _FakeWorkspaceService(this.workspace);
  final Workspace workspace;

  @override
  Future<Workspace> ensureSelectedWorkspace() async => workspace;
}

class _FakePostService extends PostService {
  _FakePostService(this.posts);

  List<Post> posts;
  String? capturedWorkspaceId;
  String? deletedPostId;
  String? retriedPostId;

  @override
  Future<List<Post>> listPosts({required String workspaceId}) async {
    capturedWorkspaceId = workspaceId;
    return posts;
  }

  @override
  Future<void> deletePost(String postId) async {
    deletedPostId = postId;
    posts = posts.where((p) => p.id != postId).toList();
  }

  @override
  Future<Post> retryPost(String postId) async {
    retriedPostId = postId;
    return _post(id: postId, status: 'SCHEDULED');
  }
}
