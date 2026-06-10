import 'package:postflow/models/home_models.dart';

const upcomingPost = UpcomingPost(
  title: 'Upcoming post',
  subtitle: "New collection this Friday Don't miss...",
  scheduledText: 'Scheduled to post at 7:30 PM',
  imageUrl:
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=1200&q=80',
);

const connectedPlatforms = [
  PlatformItem(name: 'Instagram'),
  PlatformItem(name: 'TikTok'),
  PlatformItem(name: 'YouTube'),
  PlatformItem(name: 'LinkedIn'),
];

const schedules = [
  ScheduleItem(
    title: 'New collection',
    subtitle: "New collection this Friday Don't miss...",
    date: '31st March \'22',
    time: '7:30 PM',
    imageUrl:
        'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80',
    platform: 'Instagram',
    status: 'Queued',
    contentType: 'Carousel',
  ),
  ScheduleItem(
    title: 'Launch teaser',
    subtitle: 'Short video introducing the weekend drop',
    date: '31st March \'22',
    time: '8:45 PM',
    imageUrl:
        'https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=800&q=80',
    platform: 'TikTok',
    status: 'Draft',
    contentType: 'Video',
  ),
];
