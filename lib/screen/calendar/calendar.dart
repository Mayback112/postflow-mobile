import 'package:flutter/material.dart';
import 'package:postflow/screen/calendar/widgets/calendar_content.dart';
import 'package:postflow/screen/calendar/widgets/calendar_top_bar.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.orientationOf(context) == Orientation.landscape;
              final isWide = constraints.maxWidth >= 700 || isLandscape;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CalendarTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: CalendarContent(
                        isWide: isWide,
                        focusedMonth: _focusedMonth,
                        selectedDay: _selectedDay,
                        onPrevMonth: _prevMonth,
                        onNextMonth: _nextMonth,
                        onDayTap: (day) => setState(() => _selectedDay = day),
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
