import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';
import 'package:postflow/controllers/home_controller.dart';

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
  late final HomeController _homeController;
  bool _isSideNavOpen = false;

  @override
  void initState() {
    super.initState();
    _homeController = HomeController();
    _homeController.loadHomeData();
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

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
                    child: AnimatedBuilder(
                      animation: _homeController,
                      builder: (context, _) {
                        if (_homeController.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: kBlue),
                          );
                        }

                        if (_homeController.errorMessage != null) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _homeController.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: kTextGrey),
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: _homeController.loadHomeData,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: kBlue,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: _homeController.loadHomeData,
                          color: kBlue,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                            child: _HomeContent(
                              isWide: isWide,
                              homeController: _homeController,
                            ),
                          ),
                        );
                      },
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
