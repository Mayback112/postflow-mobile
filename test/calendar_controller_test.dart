import 'package:flutter_test/flutter_test.dart';
import 'package:postflow/controllers/calendar_controller.dart';
import 'package:postflow/models/post_models.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/post_service.dart';
import 'package:postflow/services/workspace_service.dart';

void main() {
  const workspace = Workspace(id: 'workspace-1', name: 'Workspace');

  test('loads scheduled days for focused month', () async {
    final postService = _FakePostService([
      _post(
        id: 'post-1',
        caption: 'June launch',
        scheduledAt: DateTime.utc(2026, 6, 20, 15),
      ),
      _post(
        id: 'post-2',
        caption: 'July launch',
        scheduledAt: DateTime.utc(2026, 7, 4, 15),
      ),
    ]);
    final controller = CalendarController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: postService,
      initialMonth: DateTime(2026, 6),
    );

    await controller.loadCalendar();

    expect(postService.capturedWorkspaceId, 'workspace-1');
    expect(controller.scheduledDays, {20});
  });

  test('selects schedules for selected day', () async {
    final controller = CalendarController(
      workspaceService: _FakeWorkspaceService(workspace),
      postService: _FakePostService([
        _post(
          id: 'post-1',
          caption: 'Morning launch',
          scheduledAt: DateTime.utc(2026, 6, 20, 9),
        ),
        _post(
          id: 'post-2',
          caption: 'Evening launch',
          scheduledAt: DateTime.utc(2026, 6, 20, 18),
        ),
      ]),
      initialMonth: DateTime(2026, 6),
    );

    await controller.loadCalendar();
    controller.selectDay(20);

    expect(controller.selectedSchedules.map((schedule) => schedule.title), [
      'Morning launch',
      'Evening launch',
    ]);
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

  @override
  Future<List<MobilePost>> listPosts({
    required String workspaceId,
    String? status,
  }) async {
    capturedWorkspaceId = workspaceId;
    return posts;
  }
}

MobilePost _post({
  required String id,
  required String caption,
  required DateTime scheduledAt,
}) {
  return MobilePost(
    id: id,
    workspaceId: 'workspace-1',
    status: 'SCHEDULED',
    caption: caption,
    hashtags: const [],
    scheduledAt: scheduledAt,
    mediaAssets: const [],
    platforms: const [],
  );
}
