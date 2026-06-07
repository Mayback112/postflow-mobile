class PlatformItem {
  final String name;

  const PlatformItem({required this.name});
}

class ScheduleItem {
  final String title;
  final String subtitle;
  final String date;
  final String time;
  final String platform;
  final String status;
  final String contentType;

  const ScheduleItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
    this.platform = 'Instagram',
    this.status = 'Queued',
    this.contentType = 'Post',
  });
}

class UpcomingPost {
  final String title;
  final String subtitle;
  final String scheduledText;

  const UpcomingPost({
    required this.title,
    required this.subtitle,
    required this.scheduledText,
  });
}
