import 'package:flutter/material.dart';
import 'package:postflow/screen/platforms/platform_models.dart';
import 'package:postflow/screen/platforms/widgets/platform_mark.dart';
import 'package:postflow/theme/home_theme.dart';

class PlatformConnectSheet extends StatelessWidget {
  final String platform;
  final PlatformConnectionState state;
  final VoidCallback onConnected;

  const PlatformConnectSheet({
    super.key,
    required this.platform,
    required this.state,
    required this.onConnected,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = state == PlatformConnectionState.connected;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                PlatformMark(name: platform),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? 'Manage $platform' : 'Connect $platform',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isConnected
                            ? 'Refresh access or reconnect this account.'
                            : 'PostFlow will open the secure platform login in your browser.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextGrey,
                          fontSize: 12,
                          height: 1.35,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetActionButton(
              icon: Icons.verified_rounded,
              label: isConnected ? 'Reconnect $platform' : 'Connect $platform',
              subtitle: 'Opens the platform login in your browser',
              onPressed: onConnected,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPillBg,
                border: Border.all(color: kBorderLight),
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_rounded, color: kBlue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PostFlow never stores platform tokens or credentials on this device. The secure browser flow is handled through the backend.',
                      style: TextStyle(
                        color: kTextMuted,
                        fontSize: 12,
                        height: 1.4,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onPressed;

  const _SheetActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardBg,
      borderRadius: BorderRadius.circular(homeRadiusLg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderLight),
            borderRadius: BorderRadius.circular(homeRadiusLg),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: Icon(icon, color: kBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextBlack,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextGrey,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: kTextGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
