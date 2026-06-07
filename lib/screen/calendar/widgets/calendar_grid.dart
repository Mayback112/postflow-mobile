import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final int selectedDay;
  final Set<int> scheduledDays;
  final ValueChanged<int> onDayTap;

  const CalendarGrid({
    super.key,
    required this.focusedMonth,
    required this.selectedDay,
    required this.scheduledDays,
    required this.onDayTap,
  });

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month);
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0F000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: _weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kTextGrey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          for (int row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: List.generate(7, (col) {
                  final cellIndex = row * 7 + col;
                  final dayNumber = cellIndex - startOffset + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 44));
                  }

                  return Expanded(
                    child: CalendarDayCell(
                      day: dayNumber,
                      isSelected: dayNumber == selectedDay,
                      hasEvents: scheduledDays.contains(dayNumber),
                      onTap: () => onDayTap(dayNumber),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool hasEvents;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.hasEvents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: isSelected
                  ? BoxDecoration(
                      color: kBlue,
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : kTextMuted,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            if (hasEvents && !isSelected)
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: kBlue,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
