import 'package:flutter/material.dart';
import 'package:postflow/screen/notifications/notification_models.dart';
import 'package:postflow/theme/home_theme.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;

  const NotificationTile({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notification.isUnread ? kPillBg : kCardBg,
            border: Border.all(
              color: notification.isUnread ? kBlueBg : kBorderLight,
            ),
            borderRadius: BorderRadius.circular(homeRadiusLg),
            boxShadow: homeSoftShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: Icon(_icon, color: _iconColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: kTextBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        if (notification.isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: kBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextGrey,
                        fontSize: 12,
                        height: 1.35,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextGrey,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (notification.kind) {
      NotificationKind.schedule => Icons.event_available_rounded,
      NotificationKind.platform => Icons.public_rounded,
      NotificationKind.ai => Icons.auto_awesome_rounded,
      NotificationKind.account => Icons.person_rounded,
    };
  }

  Color get _iconColor {
    return switch (notification.kind) {
      NotificationKind.schedule => kMint,
      NotificationKind.platform => kAmber,
      NotificationKind.ai => kBlue,
      NotificationKind.account => kBlueDark,
    };
  }

  Color get _iconBg {
    return switch (notification.kind) {
      NotificationKind.schedule => kMintBg,
      NotificationKind.platform => kAmberBg,
      NotificationKind.ai => kBlueBg,
      NotificationKind.account => kBlueBg,
    };
  }
}
