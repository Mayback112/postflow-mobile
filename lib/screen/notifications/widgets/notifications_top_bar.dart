import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

class NotificationsTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const NotificationsTopBar({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            tooltip: 'Go back',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: kTextMuted,
              backgroundColor: kPillBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextBlack,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Publishing alerts and account updates',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onMenuTap,
            icon: Image.asset(
              '$homeIconPath/heroicons-solid_menu-alt-3.png',
              width: 19,
              height: 19,
              fit: BoxFit.contain,
            ),
            tooltip: 'Open navigation menu',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: kPillBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
