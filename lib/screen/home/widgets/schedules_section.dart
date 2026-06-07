import 'package:flutter/material.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_action_button.dart';

enum _ScheduleSortOption { date, time, title }

class SchedulesSection extends StatefulWidget {
  final List<ScheduleItem> schedules;

  const SchedulesSection({super.key, required this.schedules});

  @override
  State<SchedulesSection> createState() => _SchedulesSectionState();
}

class _SchedulesSectionState extends State<SchedulesSection> {
  _ScheduleSortOption _sortOption = _ScheduleSortOption.date;

  List<ScheduleItem> get _sortedSchedules {
    final sorted = [...widget.schedules];

    switch (_sortOption) {
      case _ScheduleSortOption.date:
        sorted.sort((a, b) => a.date.compareTo(b.date));
      case _ScheduleSortOption.time:
        sorted.sort((a, b) => _timeValue(a.time).compareTo(_timeValue(b.time)));
      case _ScheduleSortOption.title:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }

    return sorted;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SchedulesHeader(
          selectedSortOption: _sortOption,
          onSortSelected: (option) => setState(() => _sortOption = option),
        ),
        const SizedBox(height: 12),
        ..._sortedSchedules.map(
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
  final _ScheduleSortOption selectedSortOption;
  final ValueChanged<_ScheduleSortOption> onSortSelected;

  const _SchedulesHeader({
    required this.selectedSortOption,
    required this.onSortSelected,
  });

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
            PopupMenuButton<_ScheduleSortOption>(
              tooltip: 'Sort schedules',
              offset: const Offset(0, 48),
              elevation: 8,
              color: kCardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
                side: const BorderSide(color: kBorderLight),
              ),
              onSelected: onSortSelected,
              itemBuilder: (context) => [
                _sortMenuItem(
                  option: _ScheduleSortOption.date,
                  selectedSortOption: selectedSortOption,
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                ),
                _sortMenuItem(
                  option: _ScheduleSortOption.time,
                  selectedSortOption: selectedSortOption,
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                ),
                _sortMenuItem(
                  option: _ScheduleSortOption.title,
                  selectedSortOption: selectedSortOption,
                  icon: Icons.sort_by_alpha_rounded,
                  label: 'A-Z',
                ),
              ],
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kCardBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                  border: Border.all(color: kBorderLight),
                  boxShadow: homeSoftShadow,
                ),
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
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ScheduleFilterChip(label: 'Upcoming', isActive: true),
            _ScheduleFilterChip(label: 'Drafts'),
            _ScheduleFilterChip(label: 'Posted'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<_ScheduleSortOption> _sortMenuItem({
    required _ScheduleSortOption option,
    required _ScheduleSortOption selectedSortOption,
    required IconData icon,
    required String label,
  }) {
    final isSelected = option == selectedSortOption;

    return PopupMenuItem<_ScheduleSortOption>(
      value: option,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? kBlue : kTextGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? kBlue : kTextBlack,
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_rounded, size: 18, color: kBlue),
        ],
      ),
    );
  }
}

class _ScheduleFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _ScheduleFilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: '$label schedules filter',
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          backgroundColor: isActive ? kBlue : kCardBg,
          foregroundColor: isActive ? Colors.white : kTextGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: isActive ? kBlue : kBorderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : kTextGrey,
            fontFamily: 'Poppins',
          ),
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
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
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
                    const SizedBox(height: 4),
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
              _StatusPill(label: schedule.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ScheduleMetaPill(
                assetPath: '$homeIconPath/ic_outline-date-range.png',
                label: schedule.date,
              ),
              _ScheduleMetaPill(
                assetPath: '$homeIconPath/wi_time-2.png',
                label: schedule.time,
              ),
              _ScheduleTextPill(
                icon: Icons.public_rounded,
                label: schedule.platform,
              ),
              _ScheduleTextPill(
                icon: Icons.layers_rounded,
                label: schedule.contentType,
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
                icon: const Icon(Icons.more_horiz_rounded, color: kTextGrey),
                tooltip: 'More actions',
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDraft = label.toLowerCase() == 'draft';
    final statusColor = isDraft ? kAmber : kBlue;
    final statusBg = isDraft ? kAmberBg : kBlueBg;

    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(13),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: statusColor,
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
    return Container(
      constraints: const BoxConstraints(minHeight: 32, maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: kPillBg,
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
    );
  }
}

class _ScheduleTextPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ScheduleTextPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32, maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: kPillBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0A000000)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: kTextGrey),
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
    );
  }
}
