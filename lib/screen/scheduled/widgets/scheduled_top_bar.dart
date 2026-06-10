import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

class ScheduledTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const ScheduledTopBar({super.key, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Scheduled',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kTextBlack,
                fontFamily: 'Poppins',
              ),
            ),
          ),
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
