import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

enum _NotificationKind { schedule, platform, ai, account }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isSideNavOpen = false;

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SideNavOverlay(
        isOpen: _isSideNavOpen,
        activeIndex: 0,
        onClose: _closeSideNav,
        onItemSelected: (_) => _closeSideNav(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.orientationOf(context) == Orientation.landscape;
              final isWide = constraints.maxWidth >= 700 || isLandscape;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NotificationsTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _NotificationSummaryCard(),
                          SizedBox(height: 14),
                          _SectionHeader(title: 'Today', unreadCount: 3),
                          SizedBox(height: 8),
                          _NotificationTile(
                            kind: _NotificationKind.platform,
                            title: 'Facebook needs review',
                            message:
                                'Reconnect Facebook so scheduled posts can publish without failing.',
                            time: '8 min ago',
                            isUnread: true,
                          ),
                          SizedBox(height: 10),
                          _NotificationTile(
                            kind: _NotificationKind.schedule,
                            title: 'Instagram post queued',
                            message:
                                'New collection is ready to publish today at 7:30 PM.',
                            time: '24 min ago',
                            isUnread: true,
                          ),
                          SizedBox(height: 10),
                          _NotificationTile(
                            kind: _NotificationKind.ai,
                            title: 'AI caption is ready',
                            message:
                                'Your product launch caption and hashtags were generated.',
                            time: '1 hr ago',
                            isUnread: true,
                          ),
                          SizedBox(height: 18),
                          _SectionHeader(title: 'Earlier', unreadCount: 0),
                          SizedBox(height: 8),
                          _NotificationTile(
                            kind: _NotificationKind.account,
                            title: 'Profile updated',
                            message:
                                'Your timezone was set to Africa/Accra for better scheduling.',
                            time: 'Yesterday',
                            isUnread: false,
                          ),
                          SizedBox(height: 10),
                          _NotificationTile(
                            kind: _NotificationKind.schedule,
                            title: 'YouTube Short published',
                            message:
                                'Launch teaser was successfully posted to YouTube.',
                            time: 'Yesterday',
                            isUnread: false,
                          ),
                          SizedBox(height: 10),
                          _NotificationTile(
                            kind: _NotificationKind.platform,
                            title: 'Instagram connected',
                            message:
                                'PostFlow can now publish posts, reels, and captions.',
                            time: '2 days ago',
                            isUnread: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              if (isWide) return content;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: homePageMaxWidth),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationsTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _NotificationsTopBar({required this.onMenuTap});

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

class _NotificationSummaryCard extends StatelessWidget {
  const _NotificationSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlueBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(homeRadiusMd),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: kBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 unread notifications',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Review items that may affect publishing.',
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
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int unreadCount;

  const _SectionHeader({required this.title, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextBlack,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        if (unreadCount > 0)
          Container(
            constraints: const BoxConstraints(minHeight: 28),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kBlueBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$unreadCount unread',
              style: const TextStyle(
                color: kBlue,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotificationKind kind;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _NotificationTile({
    required this.kind,
    required this.title,
    required this.message,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread ? kPillBg : kCardBg,
        border: Border.all(color: isUnread ? kBlueBg : kBorderLight),
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
                        title,
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
                    if (isUnread) ...[
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
                  message,
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
                  time,
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
    );
  }

  IconData get _icon {
    return switch (kind) {
      _NotificationKind.schedule => Icons.event_available_rounded,
      _NotificationKind.platform => Icons.public_rounded,
      _NotificationKind.ai => Icons.auto_awesome_rounded,
      _NotificationKind.account => Icons.person_rounded,
    };
  }

  Color get _iconColor {
    return switch (kind) {
      _NotificationKind.schedule => kMint,
      _NotificationKind.platform => kAmber,
      _NotificationKind.ai => kBlue,
      _NotificationKind.account => kBlueDark,
    };
  }

  Color get _iconBg {
    return switch (kind) {
      _NotificationKind.schedule => kMintBg,
      _NotificationKind.platform => kAmberBg,
      _NotificationKind.ai => kBlueBg,
      _NotificationKind.account => kBlueBg,
    };
  }
}
