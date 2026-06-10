import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_data.dart';
import 'widgets/connected_platforms_card.dart';
import 'widgets/create_with_ai_card.dart';
import 'widgets/home_empty_state.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/schedules_section.dart';
import 'widgets/upcoming_post_card.dart';

part 'widgets/home_content.dart';

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
