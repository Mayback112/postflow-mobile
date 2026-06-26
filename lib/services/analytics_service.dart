import 'package:postflow/api/api.dart';
import 'package:postflow/models/post_analytics.dart';

class AnalyticsService {
  AnalyticsService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PostAnalytics?> getPostAnalytics(String postId) async {
    try {
      final response = await _apiClient.getJsonRaw(
        '/mobile/posts/$postId/analytics',
      );
      if (response['postAnalytics'] == null) return null;
      return PostAnalytics.fromJson(
        response['postAnalytics'] as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<WorkspaceAnalyticsSummary> getWorkspaceSummary({
    required String workspaceId,
    String range = '30d',
  }) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.analyticsSummary,
      query: {'workspaceId': workspaceId, 'range': range},
    );
    return WorkspaceAnalyticsSummary.fromJson(
      response['summary'] as Map<String, dynamic>,
    );
  }

  Future<BestTimeToPost> getBestTime({
    required String workspaceId,
    String range = '30d',
  }) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.analyticsBestTime,
      query: {'workspaceId': workspaceId, 'range': range},
    );
    return BestTimeToPost.fromJson(
      response['bestTime'] as Map<String, dynamic>,
    );
  }
}
