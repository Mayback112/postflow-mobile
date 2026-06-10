import 'package:flutter/material.dart';
import 'package:postflow/screen/calendar/calendar_data.dart';
import 'package:postflow/screen/calendar/widgets/calendar_grid.dart';
import 'package:postflow/screen/calendar/widgets/calendar_schedules_section.dart';
import 'package:postflow/screen/calendar/widgets/month_header.dart';
import 'package:postflow/screen/home/home_data.dart';
import 'package:postflow/theme/home_theme.dart';

class CalendarContent extends StatelessWidget {
  final bool isWide;
  final DateTime focusedMonth;
  final int selectedDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<int> onDayTap;

  const CalendarContent({
    super.key,
    required this.isWide,
    required this.focusedMonth,
    required this.selectedDay,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CalendarEntry(
          index: 0,
          child: MonthHeader(
            month: focusedMonth,
            onPrev: onPrevMonth,
            onNext: onNextMonth,
          ),
        ),
        const SizedBox(height: 18),
        _CalendarEntry(
          index: 1,
          child: CalendarGrid(
            focusedMonth: focusedMonth,
            selectedDay: selectedDay,
            scheduledDays: calendarScheduledDays,
            onDayTap: onDayTap,
          ),
        ),
        const SizedBox(height: 24),
        const _CalendarEntry(
          index: 2,
          child: CalendarSchedulesSection(schedules: schedules),
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
