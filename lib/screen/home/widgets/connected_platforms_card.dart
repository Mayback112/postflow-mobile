import 'package:flutter/material.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/theme/home_theme.dart';

class ConnectedPlatformsCard extends StatelessWidget {
  final List<PlatformItem> platforms;

  const ConnectedPlatformsCard({super.key, required this.platforms});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(homeSpaceLg),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                '$homeIconPath/Vector.png',
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Connected platforms',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kTextBlack,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  foregroundColor: kBlue,
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: platforms
                .map((platform) => _PlatformChip(label: platform.name))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final String label;

  const _PlatformChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kPillBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x0A2C90E3)),
        boxShadow: homeSoftShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PlatformLogo(label: label),
          const SizedBox(width: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: kTextMuted,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformLogo extends StatelessWidget {
  final String label;

  const _PlatformLogo({required this.label});

  @override
  Widget build(BuildContext context) {
    final assetPath = _platformAssetPath(label);

    if (assetPath == null) {
      return const Icon(Icons.public_rounded, size: 18, color: kBlueDark);
    }

    return Image.asset(
      assetPath,
      width: 18,
      height: 18,
      fit: BoxFit.contain,
      semanticLabel: '$label logo',
    );
  }

  String? _platformAssetPath(String label) {
    switch (label.toLowerCase()) {
      case 'instagram':
        return '$homeIconPath/platform_instagram_home.png';
      case 'tiktok':
        return '$homeIconPath/platform_tiktok_home.png';
      case 'youtube':
        return '$homeIconPath/platform_youtube_home.png';
      case 'linkedin':
        return '$homeIconPath/platform_linkedin_home.png';
      default:
        return null;
    }
  }
}
