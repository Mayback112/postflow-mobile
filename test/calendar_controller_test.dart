import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/calendar_controller.dart';
import 'package:postflow/models/post.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');

  test('loads posts for selected workspace', () async {
    final service = _FakePostService([
      _post(id: 'post-1', content: 'June launch', scheduledFor: DateTime.utc(2026, 6, 20, 15)),
      _post(id: 'post-2', content: 'July launch', scheduledFor: DateTime.utc(2026, 7, 4, 15)),
    ]);
    final controller = CalendarController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: service,
    );

    await controller.loadPosts();

    expect(service.capturedWorkspaceId, 'workspace-1');
    expect(controller.isLoading, isFalse);
    expect(controller.schedules.length, 2);
  });

  test('uses first line of content as schedule title', () async {
    final controller = CalendarController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: _FakePostService([
        _post(id: 'post-1', content: 'Morning launch\nSecond line', scheduledFor: DateTime.utc(2026, 6, 20, 9)),
      ]),
    );

    await controller.loadPosts();

    expect(controller.schedules.single.title, 'Morning launch');
  });
}

Post _post({required String id, required String content, DateTime? scheduledFor}) {
  return Post(
    id: id, workspaceId: 'workspace-1', content: content,
    status: 'SCHEDULED', scheduledFor: scheduledFor,
    createdAt: DateTime.utc(2026, 6, 14), updatedAt: DateTime.utc(2026, 6, 14),
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
  final List<Post> posts;
  String? capturedWorkspaceId;
  @override
  Future<List<Post>> listPosts({required String workspaceId}) async {
    capturedWorkspaceId = workspaceId;
    return posts;
  }
}
