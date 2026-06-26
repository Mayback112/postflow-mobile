import 'package:postflow/models/post.dart';

class PlatformItem {
  final String name;

  const PlatformItem({required this.name});
}

class ScheduleItem {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String platform;
  final String status;
  final String contentType;
  final String imageUrl;
  final Post? originalPost;

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    required this.imageUrl,
    this.platform = '',
    this.status = '',
    this.contentType = '',
    this.originalPost,
  });
}

class UpcomingPost {
  final String id;
  final String title;
  final String subtitle;
  final String scheduledText;
  final String imageUrl;
  final Post? originalPost;

  const UpcomingPost({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.scheduledText,
    required this.imageUrl,
    this.originalPost,
  });
}
