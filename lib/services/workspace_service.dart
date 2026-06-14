import 'package:postflow/api/api.dart';
import 'package:postflow/models/workspace.dart';

class WorkspaceService {
  WorkspaceService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Workspace> ensureSelectedWorkspace() async {
    final workspaces = await listWorkspaces();

    return workspaces.isNotEmpty
        ? workspaces.first
        : await createDefaultWorkspace();
  }

  Future<List<Workspace>> listWorkspaces() async {
    final response = await _apiClient.getJson(ApiEndpoint.workspaces);
    final items = response['workspaces'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>().map(Workspace.fromJson).toList();
  }

  Future<Workspace> createDefaultWorkspace() async {
    final response = await _apiClient.postJson(ApiEndpoint.workspaces, {
      'name': 'Default Workspace',
    });

    final workspaceJson =
        response['workspace'] as Map<String, dynamic>? ?? response;
    return Workspace.fromJson(workspaceJson);
  }
}
