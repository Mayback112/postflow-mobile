class MobilePost {
  const MobilePost({
    required this.id,
    required this.workspaceId,
    required this.status,
    required this.caption,
    required this.hashtags,
    required this.mediaAssets,
    required this.platforms,
    this.scheduledAt,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.failureReason,
  });

  final String id;
  final String workspaceId;
  final String status;
  final String caption;
  final List<String> hashtags;
  final DateTime? scheduledAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? failureReason;
  final List<PostMediaAsset> mediaAssets;
  final List<PostPlatform> platforms;

  bool get hasMedia => mediaAssets.isNotEmpty;
  bool get isTextOnly => mediaAssets.isEmpty;
  bool get hasVideo => mediaAssets.any((asset) => asset.isVideo);
  bool get hasImage => mediaAssets.any((asset) => asset.isImage);
  bool get isMixedMedia => hasImage && hasVideo;

  String get contentTypeLabel {
    if (isTextOnly) return 'Text';
    if (isMixedMedia) return '${mediaAssets.length} media';
    if (hasVideo) {
      return mediaAssets.length == 1 ? 'Video' : '${mediaAssets.length} videos';
    }
    return mediaAssets.length == 1 ? 'Image' : '${mediaAssets.length} images';
  }

  String get primaryPlatformLabel {
    if (platforms.isEmpty) return 'No platforms';
    if (platforms.length == 1) return platforms.first.platformLabel;
    return '${platforms.first.platformLabel} +${platforms.length - 1}';
  }

  factory MobilePost.fromJson(Map<String, dynamic> json) {
    final media =
        (json['mediaAssets'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(PostMediaAsset.fromJson)
            .toList()
          ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return MobilePost(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      status: json['status'] as String? ?? 'DRAFT',
      caption: json['caption'] as String? ?? '',
      hashtags: (json['hashtags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
      scheduledAt: _dateTimeFromJson(json['scheduledAt']),
      publishedAt: _dateTimeFromJson(json['publishedAt']),
      createdAt: _dateTimeFromJson(json['createdAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
      failureReason: json['failureReason'] as String?,
      mediaAssets: media,
      platforms: (json['platforms'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PostPlatform.fromJson)
          .toList(),
    );
  }
}

class PostMediaAsset {
  const PostMediaAsset({
    required this.id,
    required this.resourceType,
    required this.displayOrder,
    this.secureUrl,
    this.optimizedOriginalUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.durationSec,
  });

  final String id;
  final String resourceType;
  final String? secureUrl;
  final String? optimizedOriginalUrl;
  final String? thumbnailUrl;
  final int? width;
  final int? height;
  final num? durationSec;
  final int displayOrder;

  bool get isVideo => resourceType.toLowerCase() == 'video';
  bool get isImage => resourceType.toLowerCase() == 'image';

  String? get listPreviewUrl =>
      thumbnailUrl ??
      (isVideo
          ? _cloudinaryVideoThumbnailUrl(optimizedOriginalUrl ?? secureUrl)
          : optimizedOriginalUrl ?? secureUrl);
  String? get detailPreviewUrl => isVideo
      ? thumbnailUrl ??
            _cloudinaryVideoThumbnailUrl(optimizedOriginalUrl ?? secureUrl)
      : optimizedOriginalUrl ?? secureUrl ?? thumbnailUrl;

  factory PostMediaAsset.fromJson(Map<String, dynamic> json) {
    return PostMediaAsset(
      id: json['id'] as String,
      resourceType: json['resourceType'] as String? ?? 'image',
      secureUrl: json['secureUrl'] as String?,
      optimizedOriginalUrl: json['optimizedOriginalUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: _intFromJson(json['width']),
      height: _intFromJson(json['height']),
      durationSec: json['durationSec'] as num?,
      displayOrder: _intFromJson(json['displayOrder']) ?? 0,
    );
  }
}

String? _cloudinaryVideoThumbnailUrl(String? url) {
  if (url == null || url.isEmpty || !url.contains('/video/upload/')) {
    return null;
  }

  final uploadMarker = '/video/upload/';
  final uploadIndex = url.indexOf(uploadMarker);
  final prefix = url.substring(0, uploadIndex + uploadMarker.length);
  final suffix = url.substring(uploadIndex + uploadMarker.length);
  final withoutQuery = suffix.split('?').first;
  final extensionIndex = withoutQuery.lastIndexOf('.');
  final imageSuffix = extensionIndex == -1
      ? '$withoutQuery.jpg'
      : '${withoutQuery.substring(0, extensionIndex)}.jpg';

  return '${prefix}so_0/$imageSuffix';
}

class PostPlatform {
  const PostPlatform({
    required this.id,
    required this.platform,
    required this.accountId,
    required this.status,
    required this.publishOptions,
    this.accountName,
    this.accountUsername,
    this.errorMessage,
    this.publishedAt,
    this.remotePostId,
    this.platformPostUrl,
  });

  final String id;
  final String platform;
  final String accountId;
  final String? accountName;
  final String? accountUsername;
  final String status;
  final Map<String, dynamic> publishOptions;
  final String? errorMessage;
  final DateTime? publishedAt;
  final String? remotePostId;
  final String? platformPostUrl;

  String get platformLabel {
    final lower = platform.toLowerCase();
    if (lower.isEmpty) return platform;
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }

  String get displayName {
    final username = accountUsername;
    if (username != null && username.isNotEmpty) {
      return '$platformLabel @$username';
    }
    final name = accountName;
    if (name != null && name.isNotEmpty) return name;
    return platformLabel;
  }

  factory PostPlatform.fromJson(Map<String, dynamic> json) {
    return PostPlatform(
      id: json['id'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      accountId: json['accountId'] as String? ?? '',
      accountName: json['accountName'] as String?,
      accountUsername: json['accountUsername'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      publishOptions: Map<String, dynamic>.from(
        json['publishOptions'] as Map? ?? const {},
      ),
      errorMessage: json['errorMessage'] as String?,
      publishedAt: _dateTimeFromJson(json['publishedAt']),
      remotePostId: json['remotePostId'] as String?,
      platformPostUrl: json['platformPostUrl'] as String?,
    );
  }
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

int? _intFromJson(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
