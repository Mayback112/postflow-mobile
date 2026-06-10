import 'package:postflow/models/social_account.dart';

enum PlatformConnectionState { connected, actionNeeded, notConnected }

const supportedPlatformNames = [
  'Instagram',
  'Facebook',
  'TikTok',
  'YouTube',
  'LinkedIn',
  'X',
  'Threads',
];

String backendPlatformForName(String name) {
  return switch (name) {
    'Instagram' => 'INSTAGRAM',
    'Facebook' => 'FACEBOOK',
    'TikTok' => 'TIKTOK',
    'YouTube' => 'YOUTUBE',
    'LinkedIn' => 'LINKEDIN',
    'X' => 'X',
    'Threads' => 'THREADS',
    _ => name.toUpperCase(),
  };
}

String platformSubtitle(String name) {
  return switch (name) {
    'Instagram' => 'Posts, reels, and captions',
    'Facebook' => 'Pages and cross-posting',
    'TikTok' => 'Short video publishing',
    'YouTube' => 'Shorts and video uploads',
    'LinkedIn' => 'Company and profile posts',
    'X' => 'Posts and threads',
    'Threads' => 'Text updates and conversations',
    _ => 'Publishing access',
  };
}

SocialAccount? preferredAccountForPlatform(
  List<SocialAccount> accounts,
  String backendPlatform,
) {
  final matches =
      accounts.where((account) => account.platform == backendPlatform).toList()
        ..sort((a, b) {
          if (a.isActive == b.isActive) return 0;
          return a.isActive ? -1 : 1;
        });
  return matches.isEmpty ? null : matches.first;
}

SocialAccount? activeAccountForPlatform(
  List<SocialAccount> accounts,
  String backendPlatform,
) {
  for (final account in accounts) {
    if (account.platform == backendPlatform && account.isActive) {
      return account;
    }
  }
  return null;
}
