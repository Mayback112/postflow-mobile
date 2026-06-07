import 'package:flutter/material.dart';
import 'package:postflow/screen/calendar/calendar_data.dart';
import 'package:postflow/screen/calendar/widgets/calendar_grid.dart';
import 'package:postflow/screen/calendar/widgets/calendar_schedules_section.dart';
import 'package:postflow/screen/calendar/widgets/calendar_top_bar.dart';
import 'package:postflow/screen/calendar/widgets/month_header.dart';
import 'package:postflow/screen/home/home_data.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime(2026, 6);
  int _selectedDay = 6;
  bool _isSideNavOpen = false;

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  void _prevMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    _selectedDay = -1;
  });

  void _nextMonth() => setState(() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    _selectedDay = -1;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SideNavOverlay(
        isOpen: _isSideNavOpen,
        activeIndex: 1,
        onClose: _closeSideNav,
        onItemSelected: (_) => _closeSideNav(),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: homePageMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CalendarTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CalendarEntry(
                            index: 0,
                            child: MonthHeader(
                              month: _focusedMonth,
                              onPrev: _prevMonth,
                              onNext: _nextMonth,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _CalendarEntry(
                            index: 1,
                            child: CalendarGrid(
                              focusedMonth: _focusedMonth,
                              selectedDay: _selectedDay,
                              scheduledDays: calendarScheduledDays,
                              onDayTap: (day) =>
                                  setState(() => _selectedDay = day),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _CalendarEntry(
                            index: 2,
                            child: CalendarSchedulesSection(
                              schedules: schedules,
                            ),
                          ),
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

class _CalendarEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _CalendarEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
