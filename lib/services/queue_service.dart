import 'package:postflow/api/api.dart';
import 'package:postflow/models/queue_slot.dart';

class QueueService {
  QueueService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<QueueSlot>> listQueueSlots({required String workspaceId}) async {
    final response = await _apiClient.getJson(
      ApiEndpoint.queueSlots,
      query: {'workspaceId': workspaceId},
    );
    final items = response['queueSlots'] as List<dynamic>? ?? const [];
    return items.cast<Map<String, dynamic>>().map(QueueSlot.fromJson).toList();
  }

  Future<QueueSlot> createQueueSlot({
    required String workspaceId,
    String? socialAccountId,
    required int dayOfWeek,
    required String time,
    required String timezone,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      'workspaceId': workspaceId,
      'dayOfWeek': dayOfWeek,
      'time': time,
      'timezone': timezone,
    };

    if (socialAccountId != null) {
      body['socialAccountId'] = socialAccountId;
    }
    if (isActive != null) {
      body['isActive'] = isActive;
    }

    final response = await _apiClient.postJson(ApiEndpoint.queueSlots, body);
    return QueueSlot.fromJson(response['queueSlot'] as Map<String, dynamic>);
  }

  Future<QueueSlot> updateQueueSlot(
    String slotId, {
    String? socialAccountId,
    int? dayOfWeek,
    String? time,
    String? timezone,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};

    if (socialAccountId != null) {
      body['socialAccountId'] = socialAccountId;
    }
    if (dayOfWeek != null) {
      body['dayOfWeek'] = dayOfWeek;
    }
    if (time != null) {
      body['time'] = time;
    }
    if (timezone != null) {
      body['timezone'] = timezone;
    }
    if (isActive != null) {
      body['isActive'] = isActive;
    }

    final response = await _apiClient.patchJsonRaw(
      '/mobile/queue/slots/$slotId',
      body,
    );
    return QueueSlot.fromJson(response['queueSlot'] as Map<String, dynamic>);
  }

  Future<void> deleteQueueSlot(String slotId) async {
    await _apiClient.deleteJsonRaw('/mobile/queue/slots/$slotId');
  }

  Future<List<QueuePreviewSlot>> previewQueueSlots({
    required String workspaceId,
    int count = 10,
    DateTime? from,
  }) async {
    final query = <String, dynamic>{
      'workspaceId': workspaceId,
      'count': count,
    };
    if (from != null) {
      query['from'] = from.toUtc().toIso8601String();
    }

    final response = await _apiClient.getJson(
      ApiEndpoint.queuePreview,
      query: query,
    );
    final items = response['queuePreview'] as List<dynamic>? ?? const [];
    return items
        .cast<Map<String, dynamic>>()
        .map(QueuePreviewSlot.fromJson)
        .toList();
  }
}
