class SocialAccount {
  const SocialAccount({
    required this.id,
    required this.workspaceId,
    required this.platform,
    required this.displayName,
    required this.provider,
    required this.isActive,
    this.username,
    this.profilePictureUrl,
    this.profileUrl,
    this.platformAccountId,
    this.platformMeta,
  });

  final String id;
  final String workspaceId;
  final String platform;
  final String displayName;
  final String provider;
  final bool isActive;
  final String? username;
  final String? profilePictureUrl;
  final String? profileUrl;
  final String? platformAccountId;
  final Map<String, dynamic>? platformMeta;

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    return SocialAccount(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      platform: json['platform'] as String,
      displayName: json['displayName'] as String? ?? json['platform'] as String,
      provider: json['provider'] as String? ?? 'ZERNIO',
      isActive: json['isActive'] as bool? ?? true,
      username: json['username'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      profileUrl: json['profileUrl'] as String?,
      platformAccountId: json['platformAccountId'] as String?,
      platformMeta: json['platformMeta'] is Map<String, dynamic>
          ? json['platformMeta'] as Map<String, dynamic>
          : null,
    );
  }
}
