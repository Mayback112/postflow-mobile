import 'package:flutter/material.dart';
import 'package:postflow/screen/notifications/notification_models.dart';
import 'package:postflow/screen/notifications/widgets/notifications_content.dart';
import 'package:postflow/screen/notifications/widgets/notifications_top_bar.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isSideNavOpen = false;
  final List<NotificationItem> _notifications = const [];

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
                  NotificationsTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          NotificationsContent(notifications: _notifications),
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
