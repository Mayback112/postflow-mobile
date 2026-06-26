import 'package:postflow/models/social_account.dart';

class QueueSlot {
  final String id;
  final String workspaceId;
  final String? socialAccountId;
  final int dayOfWeek;
  final String time;
  final String timezone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SocialAccount? socialAccount;

  const QueueSlot({
    required this.id,
    required this.workspaceId,
    this.socialAccountId,
    required this.dayOfWeek,
    required this.time,
    required this.timezone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.socialAccount,
  });

  factory QueueSlot.fromJson(Map<String, dynamic> json) {
    return QueueSlot(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      socialAccountId: json['socialAccountId'] as String?,
      dayOfWeek: json['dayOfWeek'] as int,
      time: json['time'] as String,
      timezone: json['timezone'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      socialAccount: json['socialAccount'] != null
          ? SocialAccount.fromJson(
              json['socialAccount'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class QueuePreviewSlot {
  final String id;
  final String workspaceId;
  final String? socialAccountId;
  final int dayOfWeek;
  final String time;
  final String timezone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SocialAccount? socialAccount;
  final DateTime scheduledFor;

  const QueuePreviewSlot({
    required this.id,
    required this.workspaceId,
    this.socialAccountId,
    required this.dayOfWeek,
    required this.time,
    required this.timezone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.socialAccount,
    required this.scheduledFor,
  });

  factory QueuePreviewSlot.fromJson(Map<String, dynamic> json) {
    return QueuePreviewSlot(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      socialAccountId: json['socialAccountId'] as String?,
      dayOfWeek: json['dayOfWeek'] as int,
      time: json['time'] as String,
      timezone: json['timezone'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      socialAccount: json['socialAccount'] != null
          ? SocialAccount.fromJson(
              json['socialAccount'] as Map<String, dynamic>,
            )
          : null,
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
    );
  }
}
