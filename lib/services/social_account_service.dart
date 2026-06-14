import 'package:postflow/api/api.dart';
import 'package:postflow/api/api_exception.dart';
import 'package:postflow/models/social_connect_models.dart';
import 'package:postflow/models/social_account.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialAccountService {
  SocialAccountService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<SocialConnectStart> connectPlatform({
    required String workspaceId,
    required String platform,
  }) async {
    final response = await _apiClient.postJson(
      ApiEndpoint.socialZernioConnect,
      {'workspaceId': workspaceId, 'platform': platform},
    );

    final authUrl = response['authUrl'] as String?;
    if (authUrl == null || authUrl.isEmpty) {
      throw const ApiException('Backend did not return authUrl');
    }

    final state = response['state'] as String?;
    if (state == null || state.isEmpty) {
      throw const ApiException('Backend did not return connect state');
    }

    final launched = await launchUrl(
      Uri.parse(authUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw const ApiException('Could not open social connect browser');
    }

    return SocialConnectStart(state: state);
  }

  Future<SocialConnectStatusResult> connectStatus({
    required String state,
  }) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.socialZernioConnectStatus,
      query: {'state': state},
    );
    return SocialConnectStatusResult.fromJson(response);
  }

  Future<List<SocialAccount>> syncAccounts({
    required String workspaceId,
  }) async {
    final response = await _apiClient.postJson(ApiEndpoint.socialZernioSync, {
      'workspaceId': workspaceId,
    });
    return _accountsFromResponse(response);
  }

  Future<List<SocialAccount>> listAccounts({
    required String workspaceId,
  }) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.socialAccounts,
      query: {'workspaceId': workspaceId},
    );
    return _accountsFromResponse(response);
  }

  List<SocialAccount> _accountsFromResponse(Map<String, dynamic> response) {
    final items = response['socialAccounts'] as List<dynamic>? ?? const [];
    return items
        .cast<Map<String, dynamic>>()
        .map(SocialAccount.fromJson)
        .toList();
  }
}
