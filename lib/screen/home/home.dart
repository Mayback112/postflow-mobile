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
      backgroundColor: kHomeBg,
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: HomeTopBar(onMenuTap: _openSideNav),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: _HomeContent(isWide: isWide),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final bool isWide;

  const _HomeContent({required this.isWide});

  @override
  Widget build(BuildContext context) {
    const content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HomeEntry(index: 0, child: UpcomingPostCard(post: upcomingPost)),
        SizedBox(height: 16),
        _HomeEntry(index: 1, child: CreateWithAiCard()),
        SizedBox(height: 16),
        _HomeEntry(index: 2, child: _HomeStatsStrip()),
        SizedBox(height: 16),
        _HomeEntry(
          index: 3,
          child: ConnectedPlatformsCard(platforms: connectedPlatforms),
        ),
        SizedBox(height: 20),
        _HomeEntry(index: 4, child: SchedulesSection(schedules: schedules)),
        SizedBox(height: 24),
      ],
    );

    if (isWide) return content;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: homePageMaxWidth),
        child: content,
      ),
    );
  }
}

class _HomeStatsStrip extends StatelessWidget {
  const _HomeStatsStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _HomeStatTile(
            value: '12',
            label: 'Scheduled',
            color: kBlue,
            backgroundColor: kBlueBg,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HomeStatTile(
            value: '4',
            label: 'Channels',
            color: kBlue,
            backgroundColor: kBlueBg,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HomeStatTile(
            value: '86%',
            label: 'Ready',
            color: kMint,
            backgroundColor: kMintBg,
          ),
        ),
      ],
    );
  }
}

class _HomeStatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _HomeStatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextGrey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
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
