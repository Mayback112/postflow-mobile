import 'package:flutter/material.dart';
import 'package:postflow/screen/platforms/platform_models.dart';
import 'package:postflow/theme/home_theme.dart';

class ConnectionTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final PlatformConnectionState state;
  final Widget icon;
  final bool isBusy;
  final VoidCallback onPressed;

  const ConnectionTile({
    super.key,
    required this.name,
    required this.subtitle,
    required this.state,
    required this.icon,
    this.isBusy = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
        boxShadow: homeSoftShadow,
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextBlack,
                    fontSize: 14,
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
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusAction(state: state, isBusy: isBusy, onPressed: onPressed),
        ],
      ),
    );
  }
}

class _StatusAction extends StatelessWidget {
  final PlatformConnectionState state;
  final bool isBusy;
  final VoidCallback onPressed;

  const _StatusAction({
    required this.state,
    required this.isBusy,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = state == PlatformConnectionState.connected;
    final isActionNeeded = state == PlatformConnectionState.actionNeeded;

    return OutlinedButton(
      onPressed: isBusy ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        foregroundColor: isConnected
            ? kMint
            : isActionNeeded
            ? kAmber
            : kBlue,
        backgroundColor: isConnected
            ? kMintBg
            : isActionNeeded
            ? kAmberBg
            : kPillBg,
        side: BorderSide(
          color: isConnected
              ? kMint.withValues(alpha: 0.3)
              : isActionNeeded
              ? kAmber.withValues(alpha: 0.3)
              : kBlue.withValues(alpha: 0.28),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(homeRadiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
      child: isBusy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              isConnected
                  ? 'Connected'
                  : isActionNeeded
                  ? 'Reconnect'
                  : 'Connect',
            ),
    );
  }
}
