import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_data.dart';
import 'widgets/connected_platforms_card.dart';
import 'widgets/create_with_ai_card.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/schedules_section.dart';
import 'widgets/upcoming_post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: homePageMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: HomeTopBar(onMenuTap: _openSideNav),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeEntry(
                            index: 0,
                            child: UpcomingPostCard(post: upcomingPost),
                          ),
                          SizedBox(height: 16),
                          _HomeEntry(index: 1, child: CreateWithAiCard()),
                          SizedBox(height: 16),
                          _HomeEntry(
                            index: 2,
                            child: ConnectedPlatformsCard(
                              platforms: connectedPlatforms,
                            ),
                          ),
                          SizedBox(height: 20),
                          _HomeEntry(
                            index: 3,
                            child: SchedulesSection(schedules: schedules),
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _HomeEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
