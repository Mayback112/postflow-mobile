import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

class PlatformMark extends StatelessWidget {
  final String name;

  const PlatformMark({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (name.toLowerCase()) {
      'instagram' => '$homeIconPath/platform_instagram_home.png',
      'tiktok' => '$homeIconPath/platform_tiktok_home.png',
      'youtube' => '$homeIconPath/platform_youtube_home.png',
      'linkedin' => '$homeIconPath/platform_linkedin_home.png',
      'x' => null,
      'threads' => null,
      _ => null,
    };

    return _LogoShell(
      child: assetPath == null
          ? Icon(_fallbackIcon, color: kBlue, size: 24)
          : Image.asset(assetPath, width: 24, height: 24, fit: BoxFit.contain),
    );
  }

  IconData get _fallbackIcon {
    return switch (name.toLowerCase()) {
      'facebook' => Icons.facebook_rounded,
      'x' => Icons.close_rounded,
      'threads' => Icons.alternate_email_rounded,
      _ => Icons.public_rounded,
    };
  }
}

class _LogoShell extends StatelessWidget {
  final Widget child;

  const _LogoShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kPillBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusMd),
      ),
      child: child,
    );
  }
}
