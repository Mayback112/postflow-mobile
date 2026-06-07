import 'package:flutter/material.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_action_button.dart';

class SchedulesSection extends StatelessWidget {
  final List<ScheduleItem> schedules;

  const SchedulesSection({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SchedulesHeader(),
        const SizedBox(height: 12),
        ...schedules.map(
          (schedule) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ScheduleCard(schedule: schedule),
          ),
        ),
      ],
    );
  }
}

class _SchedulesHeader extends StatelessWidget {
  const _SchedulesHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'All Schedules',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x10000000)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  '$homeIconPath/fa_sort.png',
                  width: 14,
                  height: 16,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            _ScheduleFilterChip(label: 'Upcoming', isActive: true),
            SizedBox(width: 8),
            _ScheduleFilterChip(label: 'Drafts'),
            SizedBox(width: 8),
            _ScheduleFilterChip(label: 'Posted'),
          ],
        ),
      ],
    );
  }
}

class _ScheduleFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ScheduleFilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? kBlue : kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isActive ? kBlue : const Color(0x10000000)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : kTextGrey,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleItem schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x12000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: kBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTextBlack,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      schedule.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: kTextGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const _StatusPill(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ScheduleMetaPill(
                assetPath: '$homeIconPath/ic_outline-date-range.png',
                label: schedule.date,
              ),
              const SizedBox(width: 8),
              _ScheduleMetaPill(
                assetPath: '$homeIconPath/wi_time-2.png',
                label: schedule.time,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              HomeActionButton.link(label: 'View', onPressed: () {}),
              const Spacer(),
              IconButton(
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.more_horiz_rounded, color: kTextGrey),
                tooltip: 'More actions',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: kBlueBg,
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Queued',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kBlue,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _ScheduleMetaPill extends StatelessWidget {
  final String assetPath;
  final String label;

  const _ScheduleMetaPill({required this.assetPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xfff8fbff),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x0A000000)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetPath, width: 15, height: 15, fit: BoxFit.contain),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
