import 'package:flutter/material.dart';
import 'package:postflow/components/app_empty_state.dart';
import 'package:postflow/controllers/notifications_controller.dart';
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
  late final NotificationsController _controller;
  bool _isSideNavOpen = false;

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.loadNotifications();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

              final content = AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final body = _controller.isLoading &&
                          _controller.notifications.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(color: kBlue),
                        )
                      : RefreshIndicator(
                          onRefresh: _controller.refresh,
                          color: kBlue,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_controller.errorMessage != null &&
                                    _controller.notifications.isEmpty)
                                  AppEmptyState(
                                    icon: Icons.notifications_off_rounded,
                                    title: 'Notifications unavailable',
                                    message: _controller.errorMessage!,
                                    primaryLabel: 'Retry',
                                    onPrimaryPressed: _controller.loadNotifications,
                                  )
                                else
                                  NotificationsContent(
                                    notifications: _controller.notifications,
                                    onNotificationTap: (notification) {
                                      if (!notification.isUnread) return;
                                      _controller.markRead(notification.id);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NotificationsTopBar(onMenuTap: _openSideNav),
                      Expanded(child: body),
                    ],
                  );
                },
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
