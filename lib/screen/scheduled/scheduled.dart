import 'package:flutter/material.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/screen/home/home_data.dart';
import 'package:postflow/screen/home/widgets/home_action_button.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

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
                  _ScheduledTopBar(onMenuTap: _openSideNav),
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

class _ScheduledTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _ScheduledTopBar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Scheduled',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kTextBlack,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          IconButton(
            onPressed: onMenuTap,
            icon: Image.asset(
              '$homeIconPath/heroicons-solid_menu-alt-3.png',
              width: 19,
              height: 19,
              fit: BoxFit.contain,
            ),
            tooltip: 'Open navigation menu',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: kPillBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledContent extends StatelessWidget {
  final bool isWide;
  final List<ScheduleItem> schedules;
  final _ScheduledFilter activeFilter;
  final _ScheduledSort activeSort;
  final ValueChanged<_ScheduledFilter> onFilterSelected;
  final ValueChanged<_ScheduledSort> onSortSelected;

  const _ScheduledContent({
    required this.isWide,
    required this.schedules,
    required this.activeFilter,
    required this.activeSort,
    required this.onFilterSelected,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ScheduledSummaryRow(schedules: schedules),
        const SizedBox(height: 18),
        _ScheduledControls(
          activeFilter: activeFilter,
          activeSort: activeSort,
          onFilterSelected: onFilterSelected,
          onSortSelected: onSortSelected,
        ),
        const SizedBox(height: 14),
        if (schedules.isEmpty)
          const _ScheduledEmptyState()
        else
          ...schedules.map(
            (schedule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ScheduledCard(schedule: schedule),
            ),
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

class _ScheduledSummaryRow extends StatelessWidget {
  final List<ScheduleItem> schedules;

  const _ScheduledSummaryRow({required this.schedules});

  @override
  Widget build(BuildContext context) {
    final queued = schedules
        .where((schedule) => schedule.status.toLowerCase() == 'queued')
        .length;
    final drafts = schedules
        .where((schedule) => schedule.status.toLowerCase() == 'draft')
        .length;
    final posted = schedules
        .where((schedule) => schedule.status.toLowerCase() == 'posted')
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            label: 'Queued',
            value: '$queued',
            icon: Icons.schedule_rounded,
            color: kBlue,
            backgroundColor: kBlueBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Drafts',
            value: '$drafts',
            icon: Icons.edit_note_rounded,
            color: kAmber,
            backgroundColor: kAmberBg,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            label: 'Posted',
            value: '$posted',
            icon: Icons.check_circle_rounded,
            color: kMint,
            backgroundColor: kMintBg,
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusXl),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: kTextBlack,
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextGrey,
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledControls extends StatelessWidget {
  final _ScheduledFilter activeFilter;
  final _ScheduledSort activeSort;
  final ValueChanged<_ScheduledFilter> onFilterSelected;
  final ValueChanged<_ScheduledSort> onSortSelected;

  const _ScheduledControls({
    required this.activeFilter,
    required this.activeSort,
    required this.onFilterSelected,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'All scheduled posts',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            PopupMenuButton<_ScheduledSort>(
              tooltip: 'Sort scheduled posts',
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
                  _ScheduledSort.date,
                  Icons.calendar_today_rounded,
                  'Date',
                ),
                _sortMenuItem(
                  _ScheduledSort.time,
                  Icons.schedule_rounded,
                  'Time',
                ),
                _sortMenuItem(
                  _ScheduledSort.title,
                  Icons.sort_by_alpha_rounded,
                  'A-Z',
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChipButton(
              label: 'All',
              isActive: activeFilter == _ScheduledFilter.all,
              onPressed: () => onFilterSelected(_ScheduledFilter.all),
            ),
            _FilterChipButton(
              label: 'Queued',
              isActive: activeFilter == _ScheduledFilter.queued,
              onPressed: () => onFilterSelected(_ScheduledFilter.queued),
            ),
            _FilterChipButton(
              label: 'Drafts',
              isActive: activeFilter == _ScheduledFilter.draft,
              onPressed: () => onFilterSelected(_ScheduledFilter.draft),
            ),
            _FilterChipButton(
              label: 'Posted',
              isActive: activeFilter == _ScheduledFilter.posted,
              onPressed: () => onFilterSelected(_ScheduledFilter.posted),
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<_ScheduledSort> _sortMenuItem(
    _ScheduledSort option,
    IconData icon,
    String label,
  ) {
    final isSelected = option == activeSort;

    return PopupMenuItem<_ScheduledSort>(
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

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _FilterChipButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: '$label scheduled posts filter',
      child: TextButton(
        onPressed: onPressed,
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

class _ScheduledCard extends StatelessWidget {
  final ScheduleItem schedule;

  const _ScheduledCard({required this.schedule});

  void _showScheduleDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ScheduleDetailsSheet(schedule: schedule),
    );
  }

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
              _ScheduledThumbnail(schedule: schedule),
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
              _StatusPill(label: schedule.status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(
                icon: Icons.calendar_today_rounded,
                label: schedule.date,
              ),
              _MetaPill(icon: Icons.access_time_rounded, label: schedule.time),
              _MetaPill(icon: Icons.public_rounded, label: schedule.platform),
              _MetaPill(
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
              const SizedBox(width: 8),
              HomeActionButton.link(label: 'Edit', onPressed: () {}),
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

class _ScheduledThumbnail extends StatelessWidget {
  final ScheduleItem schedule;

  const _ScheduledThumbnail({required this.schedule});

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
                child: _ScheduledPlatformLogo(platform: schedule.platform),
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

class _ScheduledPlatformLogo extends StatelessWidget {
  final String platform;

  const _ScheduledPlatformLogo({required this.platform});

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

class _ScheduleDetailsSheet extends StatelessWidget {
  final ScheduleItem schedule;

  const _ScheduleDetailsSheet({required this.schedule});

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
                    Icons.schedule_rounded,
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
                _StatusPill(label: schedule.status),
              ],
            ),
            const SizedBox(height: 16),
            if (_ScheduleMediaPreview.hasMedia(schedule)) ...[
              _ScheduleMediaPreview(schedule: schedule),
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
                      _MetaPill(
                        icon: Icons.calendar_today_rounded,
                        label: schedule.date,
                      ),
                      _MetaPill(
                        icon: Icons.access_time_rounded,
                        label: schedule.time,
                      ),
                      _MetaPill(
                        icon: Icons.public_rounded,
                        label: schedule.platform,
                      ),
                      _MetaPill(
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

class _ScheduleMediaPreview extends StatelessWidget {
  final ScheduleItem schedule;

  const _ScheduleMediaPreview({required this.schedule});

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

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDraft = label.toLowerCase() == 'draft';
    final isPosted = label.toLowerCase() == 'posted';
    final statusColor = isDraft
        ? kAmber
        : isPosted
        ? kMint
        : kBlue;
    final statusBg = isDraft
        ? kAmberBg
        : isPosted
        ? kMintBg
        : kBlueBg;

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

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

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

class _ScheduledEmptyState extends StatelessWidget {
  const _ScheduledEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: const Column(
        children: [
          Icon(Icons.event_busy_rounded, color: kTextGrey, size: 32),
          SizedBox(height: 10),
          Text(
            'No scheduled posts',
            style: TextStyle(
              color: kTextBlack,
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try a different filter or create a new post.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextGrey,
              fontFamily: 'Poppins',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
