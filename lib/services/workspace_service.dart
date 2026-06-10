import 'package:postflow/api/api.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/workspace.dart';
import 'package:postflow/services/auth_token_storage.dart';

class WorkspaceService {
  WorkspaceService({ApiClient? apiClient, AuthTokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  Future<Workspace> ensureSelectedWorkspace() async {
    final accessToken = await _requiredAccessToken();
    final workspaces = await listWorkspaces(accessToken: accessToken);
    final storedWorkspaceId = await _tokenStorage.readSelectedWorkspaceId();

    if (storedWorkspaceId != null && storedWorkspaceId.isNotEmpty) {
      for (final workspace in workspaces) {
        if (workspace.id == storedWorkspaceId) {
          return workspace;
        }
      }
    }

    final selectedWorkspace = workspaces.isNotEmpty
        ? workspaces.first
        : await createDefaultWorkspace(accessToken: accessToken);

    await _tokenStorage.saveSelectedWorkspaceId(selectedWorkspace.id);
    return selectedWorkspace;
  }

  Future<List<Workspace>> listWorkspaces({String? accessToken}) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.workspaces,
      accessToken: accessToken ?? await _requiredAccessToken(),
    );
    final items = response['workspaces'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>().map(Workspace.fromJson).toList();
  }

  Future<Workspace> createDefaultWorkspace({String? accessToken}) async {
    final response = await _apiClient.postJson(
      ApiEndpoint.workspaces,
      {'name': 'Default Workspace'},
      accessToken: accessToken ?? await _requiredAccessToken(),
    );

    final workspaceJson =
        response['workspace'] as Map<String, dynamic>? ?? response;
    return Workspace.fromJson(workspaceJson);
  }

  Future<String> _requiredAccessToken() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw const ApiException('Please sign in again');
    }
    return accessToken;
  }
}
