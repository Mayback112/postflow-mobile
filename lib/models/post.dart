class PostTarget {
  final String id;
  final String postId;
  final String socialAccountId;
  final String platform;
  final String? customContent;
  final List<String> mediaUrls;
  final Map<String, dynamic>? platformSpecificData;
  final Map<String, dynamic>? tiktokSettings;
  final String status;
  final String? platformPostId;
  final String? publishedUrl;
  final String? error;
  final int retryCount;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SocialAccountSummary socialAccount;

  const PostTarget({
    required this.id,
    required this.postId,
    required this.socialAccountId,
    required this.platform,
    this.customContent,
    required this.mediaUrls,
    this.platformSpecificData,
    this.tiktokSettings,
    required this.status,
    this.platformPostId,
    this.publishedUrl,
    this.error,
    required this.retryCount,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.socialAccount,
  });

  factory PostTarget.fromJson(Map<String, dynamic> json) {
    return PostTarget(
      id: json['id'] as String,
      postId: json['postId'] as String,
      socialAccountId: json['socialAccountId'] as String,
      platform: json['platform'] as String,
      customContent: json['customContent'] as String?,
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      platformSpecificData: json['platformSpecificData'] != null
          ? Map<String, dynamic>.from(json['platformSpecificData'] as Map)
          : null,
      tiktokSettings: json['tiktokSettings'] != null
          ? Map<String, dynamic>.from(json['tiktokSettings'] as Map)
          : null,
      status: json['status'] as String,
      platformPostId: json['platformPostId'] as String?,
      publishedUrl: json['publishedUrl'] as String?,
      error: json['error'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      socialAccount: SocialAccountSummary.fromJson(
        json['socialAccount'] as Map<String, dynamic>,
      ),
    );
  }
}

class SocialAccountSummary {
  final String id;
  final String platform;
  final String status;
  final String displayName;
  final String? username;
  final String? profilePictureUrl;
  final String? profileUrl;

  const SocialAccountSummary({
    required this.id,
    required this.platform,
    required this.status,
    required this.displayName,
    this.username,
    this.profilePictureUrl,
    this.profileUrl,
  });

  factory SocialAccountSummary.fromJson(Map<String, dynamic> json) {
    return SocialAccountSummary(
      id: json['id'] as String,
      platform: json['platform'] as String,
      status: json['status'] as String,
      displayName: json['displayName'] as String? ?? json['platform'] as String,
      username: json['username'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      profileUrl: json['profileUrl'] as String?,
    );
  }
}

class Post {
  final String id;
  final String workspaceId;
  final String content;
  final String status;
  final DateTime? scheduledFor;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PostTarget> postTargets;

  const Post({
    required this.id,
    required this.workspaceId,
    required this.content,
    required this.status,
    this.scheduledFor,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.postTargets,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      content: json['content'] as String,
      status: json['status'] as String,
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.tryParse(json['scheduledFor'] as String)
          : null,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      postTargets:
          (json['postTargets'] as List<dynamic>?)
              ?.map((e) => PostTarget.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
