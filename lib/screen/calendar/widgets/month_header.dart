import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

class MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthHeader({
    super.key,
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 24),
          color: kTextMuted,
          onPressed: onPrev,
        ),
        Column(
          children: [
            Text(
              _monthNames[month.month - 1],
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: kTextBlack,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              '${month.year}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextGrey,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, size: 24),
          color: kTextMuted,
          onPressed: onNext,
        ),
      ],
    );
  }
}
