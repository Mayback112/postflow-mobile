import 'package:flutter/material.dart';
import 'package:postflow/components/app_empty_state.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/screen/home/widgets/home_action_button.dart';
import 'package:postflow/theme/home_theme.dart';

enum _CalendarSortOption { date, time, title }

class CalendarSchedulesSection extends StatefulWidget {
  final List<ScheduleItem> schedules;

  const CalendarSchedulesSection({super.key, required this.schedules});

  @override
  State<CalendarSchedulesSection> createState() =>
      _CalendarSchedulesSectionState();
}

class _CalendarSchedulesSectionState extends State<CalendarSchedulesSection> {
  _CalendarSortOption _sortOption = _CalendarSortOption.date;

  List<ScheduleItem> get _sortedSchedules {
    final sorted = [...widget.schedules];

    switch (_sortOption) {
      case _CalendarSortOption.date:
        sorted.sort((a, b) => a.date.compareTo(b.date));
      case _CalendarSortOption.time:
        sorted.sort((a, b) => _timeValue(a.time).compareTo(_timeValue(b.time)));
      case _CalendarSortOption.title:
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
        _CalendarSectionHeader(
          selectedSortOption: _sortOption,
          onSortSelected: (option) => setState(() => _sortOption = option),
        ),
        const SizedBox(height: 12),
        if (_sortedSchedules.isEmpty)
          AppEmptyState(
            icon: Icons.calendar_month_rounded,
            title: 'Nothing on this day',
            message:
                'No posts are scheduled for the selected date. Create a post to fill the calendar.',
            primaryLabel: 'Create post',
            onPrimaryPressed: () =>
                Navigator.of(context).pushNamed('/CreateWithAi'),
          )
        else
          ..._sortedSchedules.map(
            (schedule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CalendarScheduleCard(schedule: schedule),
            ),
          ),
      ],
    );
  }
}

class _CalendarSectionHeader extends StatelessWidget {
  final _CalendarSortOption selectedSortOption;
  final ValueChanged<_CalendarSortOption> onSortSelected;

  const _CalendarSectionHeader({
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
                "Today's Schedules",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            PopupMenuButton<_CalendarSortOption>(
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
                  option: _CalendarSortOption.date,
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                ),
                _sortMenuItem(
                  option: _CalendarSortOption.time,
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                ),
                _sortMenuItem(
                  option: _CalendarSortOption.title,
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
            _CalendarFilterChip(label: 'Today', isActive: true),
            _CalendarFilterChip(label: 'Upcoming'),
            _CalendarFilterChip(label: 'Posted'),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<_CalendarSortOption> _sortMenuItem({
    required _CalendarSortOption option,
    required IconData icon,
    required String label,
  }) {
    final isSelected = option == selectedSortOption;

    return PopupMenuItem<_CalendarSortOption>(
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

class _CalendarFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _CalendarFilterChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: '$label calendar schedules filter',
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

class CalendarScheduleCard extends StatelessWidget {
  final ScheduleItem schedule;

  const CalendarScheduleCard({super.key, required this.schedule});

  void _showScheduleDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CalendarScheduleDetailsSheet(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusXl),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CalendarScheduleThumbnail(schedule: schedule),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kTextGrey,
                        height: 1.35,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CalendarStatusPill(label: schedule.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CalendarMetaPill(
                assetPath: '$homeIconPath/ic_outline-date-range.png',
                label: schedule.date,
              ),
              _CalendarMetaPill(
                assetPath: '$homeIconPath/wi_time-2.png',
                label: schedule.time,
              ),
              _CalendarTextPill(
                icon: Icons.public_rounded,
                label: schedule.platform,
              ),
              _CalendarTextPill(
                icon: Icons.layers_rounded,
                label: schedule.contentType,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              HomeActionButton.link(
                label: 'View',
                onPressed: () => _showScheduleDetails(context),
              ),
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

class _CalendarScheduleThumbnail extends StatelessWidget {
  final ScheduleItem schedule;

  const _CalendarScheduleThumbnail({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              schedule.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Image.asset(_previewAssetPath, fit: BoxFit.cover),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.36),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: _CalendarPlatformLogo(platform: schedule.platform),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _previewAssetPath {
    final type = schedule.contentType.toLowerCase();
    if (type.contains('video') || type.contains('motion')) {
      return 'asset/images/background/Onboarding3.png';
    }
    if (type.contains('carousel')) {
      return 'asset/images/background/Onboarding2.png';
    }
    return 'asset/images/background/Onboarding4.png';
  }
}

class _CalendarPlatformLogo extends StatelessWidget {
  final String platform;

  const _CalendarPlatformLogo({required this.platform});

  @override
  Widget build(BuildContext context) {
    final assetPath = _platformAssetPath;
    if (assetPath == null) {
      return const Icon(Icons.public_rounded, size: 14, color: kBlue);
    }

    return Image.asset(assetPath, fit: BoxFit.contain);
  }

  String? get _platformAssetPath {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return '$homeIconPath/platform_instagram_home.png';
      case 'tiktok':
        return '$homeIconPath/platform_tiktok_home.png';
      case 'youtube':
        return '$homeIconPath/platform_youtube_home.png';
      case 'linkedin':
        return '$homeIconPath/platform_linkedin_home.png';
      default:
        return null;
    }
  }
}

class _CalendarScheduleDetailsSheet extends StatelessWidget {
  final ScheduleItem schedule;

  const _CalendarScheduleDetailsSheet({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kBlueBg,
                    borderRadius: BorderRadius.circular(homeRadiusMd),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: kBlue,
                    size: 22,
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
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kTextBlack,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${schedule.date} • ${schedule.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kTextGrey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                _CalendarStatusPill(label: schedule.status),
              ],
            ),
            const SizedBox(height: 16),
            if (_CalendarScheduleMediaPreview.hasMedia(schedule)) ...[
              _CalendarScheduleMediaPreview(schedule: schedule),
              const SizedBox(height: 14),
            ],
            Container(
              padding: const EdgeInsets.all(homeSpaceLg),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(homeRadiusLg),
                border: Border.all(color: kBorderLight),
                boxShadow: homeSoftShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Post content',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextBlack,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    schedule.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: kTextMuted,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _CalendarTextPill(
                        icon: Icons.calendar_today_rounded,
                        label: schedule.date,
                      ),
                      _CalendarTextPill(
                        icon: Icons.access_time_rounded,
                        label: schedule.time,
                      ),
                      _CalendarTextPill(
                        icon: Icons.public_rounded,
                        label: schedule.platform,
                      ),
                      _CalendarTextPill(
                        icon: Icons.layers_rounded,
                        label: schedule.contentType,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 52),
                      foregroundColor: kTextMuted,
                      side: const BorderSide(color: kBorderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(homeRadiusMd),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 52),
                      backgroundColor: kBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(homeRadiusMd),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarScheduleMediaPreview extends StatelessWidget {
  final ScheduleItem schedule;

  const _CalendarScheduleMediaPreview({required this.schedule});

  static bool hasMedia(ScheduleItem schedule) {
    final type = schedule.contentType.toLowerCase();
    return type.contains('image') ||
        type.contains('video') ||
        type.contains('carousel') ||
        type.contains('motion');
  }

  bool get _isVideo {
    final type = schedule.contentType.toLowerCase();
    return type.contains('video') || type.contains('motion');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Media',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kTextBlack,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(homeRadiusMd),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    schedule.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      _isVideo
                          ? 'asset/images/background/Onboarding3.png'
                          : 'asset/images/background/Onboarding2.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.02),
                          Colors.black.withValues(alpha: 0.34),
                        ],
                      ),
                    ),
                  ),
                  if (_isVideo)
                    Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: kBlue,
                          size: 34,
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isVideo
                                ? Icons.play_circle_fill_rounded
                                : Icons.image_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            schedule.contentType,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Poppins',
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
        ],
      ),
    );
  }
}

class _CalendarStatusPill extends StatelessWidget {
  final String label;

  const _CalendarStatusPill({required this.label});

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

class _CalendarMetaPill extends StatelessWidget {
  final String assetPath;
  final String label;

  const _CalendarMetaPill({required this.assetPath, required this.label});

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

class _CalendarTextPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CalendarTextPill({required this.icon, required this.label});

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
