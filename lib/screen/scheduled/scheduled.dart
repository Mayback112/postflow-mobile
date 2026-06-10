import 'package:flutter/material.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/screen/home/home_data.dart';
import 'package:postflow/screen/home/widgets/home_action_button.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/screen/scheduled/widgets/scheduled_empty_state.dart';
import 'package:postflow/screen/scheduled/widgets/scheduled_top_bar.dart';
import 'package:postflow/theme/home_theme.dart';

part 'widgets/scheduled_content.dart';

enum _ScheduledFilter { all, queued, draft, posted }

enum _ScheduledSort { date, time, title }

class ScheduledScreen extends StatefulWidget {
  const ScheduledScreen({super.key});

  @override
  State<ScheduledScreen> createState() => _ScheduledScreenState();
}

class _ScheduledScreenState extends State<ScheduledScreen> {
  bool _isSideNavOpen = false;
  _ScheduledFilter _filter = _ScheduledFilter.all;
  _ScheduledSort _sort = _ScheduledSort.date;

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  List<ScheduleItem> get _visibleSchedules {
    final filtered = schedules.where((schedule) {
      return switch (_filter) {
        _ScheduledFilter.all => true,
        _ScheduledFilter.queued => schedule.status.toLowerCase() == 'queued',
        _ScheduledFilter.draft => schedule.status.toLowerCase() == 'draft',
        _ScheduledFilter.posted => schedule.status.toLowerCase() == 'posted',
      };
    }).toList();

    switch (_sort) {
      case _ScheduledSort.date:
        filtered.sort((a, b) => a.date.compareTo(b.date));
      case _ScheduledSort.time:
        filtered.sort(
          (a, b) => _timeValue(a.time).compareTo(_timeValue(b.time)),
        );
      case _ScheduledSort.title:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }

    return filtered;
  }

  int _timeValue(String time) {
    final parts = time.trim().split(RegExp(r'[: ]+'));
    if (parts.length < 3) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final period = parts[2].toUpperCase();
    final normalizedHour = period == 'PM' && hour != 12
        ? hour + 12
        : period == 'AM' && hour == 12
        ? 0
        : hour;

    return (normalizedHour * 60) + minute;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SideNavOverlay(
        isOpen: _isSideNavOpen,
        activeIndex: 2,
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
                  ScheduledTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: _ScheduledContent(
                        isWide: isWide,
                        schedules: _visibleSchedules,
                        activeFilter: _filter,
                        activeSort: _sort,
                        onFilterSelected: (filter) =>
                            setState(() => _filter = filter),
                        onSortSelected: (sort) => setState(() => _sort = sort),
                      ),
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
