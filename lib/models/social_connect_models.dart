class SocialConnectStart {
  const SocialConnectStart({required this.state});

  final String state;
}

enum SocialConnectStatus { pending, success, error, unknown }

class SocialConnectStatusResult {
  const SocialConnectStatusResult({
    required this.status,
    this.error,
    this.platform,
  });

  final SocialConnectStatus status;
  final String? error;
  final String? platform;

  factory SocialConnectStatusResult.fromJson(Map<String, dynamic> json) {
    final statusJson = json['connectStatus'] is Map<String, dynamic>
        ? json['connectStatus'] as Map<String, dynamic>
        : json;

    return SocialConnectStatusResult(
      status: _statusFromJson(statusJson['status']),
      error: statusJson['error'] as String?,
      platform: (statusJson['platform'] as String?)?.toUpperCase(),
    );
  }

  static SocialConnectStatus _statusFromJson(Object? value) {
    final normalized = value?.toString().toUpperCase();
    return switch (normalized) {
      'PENDING' => SocialConnectStatus.pending,
      'SUCCESS' || 'CONNECTED' => SocialConnectStatus.success,
      'ERROR' || 'FAILED' => SocialConnectStatus.error,
      _ => SocialConnectStatus.unknown,
    };
  }
}
