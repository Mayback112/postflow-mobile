import 'package:flutter/material.dart';
import 'package:postflow/models/social_account.dart';

enum PlatformConnectionState { connected, actionNeeded, notConnected }

class PlatformFollowUpInfo {
  final String title;
  final String message;
  final String actionLabel;
  final IconData icon;

  const PlatformFollowUpInfo({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.icon,
  });
}

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

String displayPlatformNameForBackend(String backendPlatform) {
  return switch (backendPlatform.toUpperCase()) {
    'INSTAGRAM' => 'Instagram',
    'FACEBOOK' => 'Facebook',
    'TIKTOK' => 'TikTok',
    'YOUTUBE' => 'YouTube',
    'LINKEDIN' => 'LinkedIn',
    'X' => 'X',
    'THREADS' => 'Threads',
    _ => backendPlatform,
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

PlatformFollowUpInfo? followUpInfoForAccount(SocialAccount account) {
  final platform = account.platform.toUpperCase();
  final meta = account.platformMeta ?? const <String, dynamic>{};

  if (_boolMeta(meta, 'requiresPageSelection') == true) {
    final isInstagram = platform == 'INSTAGRAM';
    return PlatformFollowUpInfo(
      title: isInstagram ? 'Choose an Instagram Page' : 'Choose a Page',
      message: isInstagram
          ? 'Finish the Meta login flow by choosing the Facebook Page that powers this Instagram account.'
          : 'Finish the Meta login flow by choosing the Facebook Page that should publish for this account.',
      actionLabel: 'Continue setup',
      icon: Icons.pages_rounded,
    );
  }

  if (platform == 'YOUTUBE' &&
      (_boolMeta(meta, 'requiresChannelSelection') == true ||
          _stringMeta(meta, 'selectionType') == 'channel')) {
    final channelTitle = _stringMeta(meta, 'channelTitle');
    return PlatformFollowUpInfo(
      title: 'Choose a channel',
      message: channelTitle == null || channelTitle.isEmpty
          ? 'Finish the YouTube login flow by choosing the channel PostFlow should publish to.'
          : 'Finish the YouTube login flow by choosing the channel PostFlow should publish to. The current selection is $channelTitle.',
      actionLabel: 'Continue setup',
      icon: Icons.play_circle_outline_rounded,
    );
  }

  if (platform == 'LINKEDIN') {
    final accountType = _stringMeta(meta, 'accountType');
    if (accountType == 'organization') {
      return PlatformFollowUpInfo(
        title: 'Choose an organization',
        message:
            'This LinkedIn connection is organization-based. Reconnect if you need a different organization.',
        actionLabel: 'Reconnect',
        icon: Icons.apartment_rounded,
      );
    }
  }

  return null;
}

bool isAccountReadyForPublishing(SocialAccount account) {
  return account.isActive && followUpInfoForAccount(account) == null;
}

bool _boolMeta(Map<String, dynamic> meta, String key) {
  return meta[key] == true;
}

String? _stringMeta(Map<String, dynamic> meta, String key) {
  final value = meta[key];
  return value is String ? value.trim() : null;
}
