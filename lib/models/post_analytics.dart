class PostAnalytics {
  final String id;
  final String workspaceId;
  final String postId;
  final String postTargetId;
  final String socialAccountId;
  final String platform;
  final int impressions;
  final int likes;
  final int comments;
  final int shares;
  final int reach;
  final DateTime fetchedAt;

  const PostAnalytics({
    required this.id,
    required this.workspaceId,
    required this.postId,
    required this.postTargetId,
    required this.socialAccountId,
    required this.platform,
    required this.impressions,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.reach,
    required this.fetchedAt,
  });

  factory PostAnalytics.fromJson(Map<String, dynamic> json) {
    return PostAnalytics(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      postId: json['postId'] as String,
      postTargetId: json['postTargetId'] as String,
      socialAccountId: json['socialAccountId'] as String,
      platform: json['platform'] as String,
      impressions: json['impressions'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      reach: json['reach'] as int? ?? 0,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}

/// Summary returned by GET /mobile/posts/:id/analytics
class PostAnalyticsSummary {
  final String postId;
  final String workspaceId;
  final String status;
  final DateTime? publishedAt;
  final DateTime? fetchedAt;
  final AnalyticsTotals totals;
  final List<PostTargetAnalytics> targetAnalytics;

  const PostAnalyticsSummary({
    required this.postId,
    required this.workspaceId,
    required this.status,
    this.publishedAt,
    this.fetchedAt,
    required this.totals,
    required this.targetAnalytics,
  });

  factory PostAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return PostAnalyticsSummary(
      postId: json['postId'] as String,
      workspaceId: json['workspaceId'] as String,
      status: json['status'] as String? ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.tryParse(json['fetchedAt'] as String)
          : null,
      totals: AnalyticsTotals.fromJson(json['totals'] as Map<String, dynamic>),
      targetAnalytics: (json['targetAnalytics'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(PostTargetAnalytics.fromJson)
          .toList(),
    );
  }
}

class PostTargetAnalytics {
  final String postTargetId;
  final String socialAccountId;
  final String platform;
  final String status;
  final DateTime? publishedAt;
  final DateTime? fetchedAt;
  final AnalyticsTotals metrics;

  const PostTargetAnalytics({
    required this.postTargetId,
    required this.socialAccountId,
    required this.platform,
    required this.status,
    this.publishedAt,
    this.fetchedAt,
    required this.metrics,
  });

  factory PostTargetAnalytics.fromJson(Map<String, dynamic> json) {
    return PostTargetAnalytics(
      postTargetId: json['postTargetId'] as String,
      socialAccountId: json['socialAccountId'] as String,
      platform: json['platform'] as String,
      status: json['status'] as String? ?? '',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.tryParse(json['fetchedAt'] as String)
          : null,
      metrics: AnalyticsTotals.fromJson(json['metrics'] as Map<String, dynamic>),
    );
  }
}

class WorkspaceAnalyticsSummary {
  final String workspaceId;
  final String range;
  final DateTime windowStart;
  final DateTime windowEnd;
  final int postCount;
  final int targetCount;
  final AnalyticsTotals totals;
  final List<PlatformBreakdown> platformBreakdown;

  const WorkspaceAnalyticsSummary({
    required this.workspaceId,
    required this.range,
    required this.windowStart,
    required this.windowEnd,
    required this.postCount,
    required this.targetCount,
    required this.totals,
    required this.platformBreakdown,
  });

  factory WorkspaceAnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return WorkspaceAnalyticsSummary(
      workspaceId: json['workspaceId'] as String,
      range: json['range'] as String,
      windowStart: DateTime.parse(json['windowStart'] as String),
      windowEnd: DateTime.parse(json['windowEnd'] as String),
      postCount: json['postCount'] as int? ?? 0,
      targetCount: json['targetCount'] as int? ?? 0,
      totals: AnalyticsTotals.fromJson(json['totals'] as Map<String, dynamic>),
      platformBreakdown:
          (json['platformBreakdown'] as List<dynamic>?)
              ?.map(
                (e) => PlatformBreakdown.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}

class AnalyticsTotals {
  final int impressions;
  final int likes;
  final int comments;
  final int shares;
  final int reach;
  final int engagement;

  const AnalyticsTotals({
    required this.impressions,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.reach,
    required this.engagement,
  });

  factory AnalyticsTotals.fromJson(Map<String, dynamic> json) {
    return AnalyticsTotals(
      impressions: json['impressions'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      reach: json['reach'] as int? ?? 0,
      engagement: json['engagement'] as int? ?? 0,
    );
  }
}

class PlatformBreakdown {
  final String platform;
  final int postCount;
  final int targetCount;
  final AnalyticsTotals totals;

  const PlatformBreakdown({
    required this.platform,
    required this.postCount,
    required this.targetCount,
    required this.totals,
  });

  factory PlatformBreakdown.fromJson(Map<String, dynamic> json) {
    return PlatformBreakdown(
      platform: json['platform'] as String,
      postCount: json['postCount'] as int? ?? 0,
      targetCount: json['targetCount'] as int? ?? 0,
      totals: AnalyticsTotals.fromJson(json['totals'] as Map<String, dynamic>),
    );
  }
}

class BestTimeToPost {
  final String workspaceId;
  final String range;
  final DateTime windowStart;
  final DateTime windowEnd;
  final List<BestTimeBucket> buckets;

  const BestTimeToPost({
    required this.workspaceId,
    required this.range,
    required this.windowStart,
    required this.windowEnd,
    required this.buckets,
  });

  factory BestTimeToPost.fromJson(Map<String, dynamic> json) {
    return BestTimeToPost(
      workspaceId: json['workspaceId'] as String,
      range: json['range'] as String,
      windowStart: DateTime.parse(json['windowStart'] as String),
      windowEnd: DateTime.parse(json['windowEnd'] as String),
      buckets:
          (json['buckets'] as List<dynamic>?)
              ?.map((e) => BestTimeBucket.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class BestTimeBucket {
  final int dayOfWeek;
  final int hour;
  final double score;
  final int count;

  const BestTimeBucket({
    required this.dayOfWeek,
    required this.hour,
    required this.score,
    required this.count,
  });

  factory BestTimeBucket.fromJson(Map<String, dynamic> json) {
    return BestTimeBucket(
      dayOfWeek: json['dayOfWeek'] as int,
      hour: json['hour'] as int,
      score: (json['score'] as num).toDouble(),
      count: json['count'] as int? ?? 0,
    );
  }
}
