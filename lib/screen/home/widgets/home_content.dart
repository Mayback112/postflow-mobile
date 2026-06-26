part of '../home.dart';

class _HomeContent extends StatelessWidget {
  final bool isWide;
  final HomeController homeController;

  const _HomeContent({required this.isWide, required this.homeController});

  @override
  Widget build(BuildContext context) {
    final hasUpcomingPost = homeController.upcomingPost != null;
    final hasPlatforms = homeController.connectedPlatforms.isNotEmpty;
    final hasSchedules = homeController.schedules.isNotEmpty;
    final isEmpty = !hasUpcomingPost && !hasPlatforms && !hasSchedules;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isEmpty) ...[
          const _HomeEntry(index: 0, child: HomeEmptyState()),
        ] else ...[
          if (hasUpcomingPost) ...[
            _HomeEntry(
              index: 0,
              child: UpcomingPostCard(post: homeController.upcomingPost!),
            ),
            const SizedBox(height: 16),
          ],
          const _HomeEntry(index: 1, child: CreateWithAiCard()),
          const SizedBox(height: 16),
          _HomeEntry(
            index: 2,
            child: _HomeStatsStrip(
              scheduledCount: homeController.schedules.length,
              channelCount: homeController.connectedPlatforms.length,
              readyPercent: hasSchedules ? 86 : 0,
            ),
          ),
          if (hasPlatforms) ...[
            const SizedBox(height: 16),
            _HomeEntry(
              index: 3,
              child: ConnectedPlatformsCard(
                platforms: homeController.connectedPlatforms,
              ),
            ),
          ],
          if (hasSchedules) ...[
            const SizedBox(height: 20),
            _HomeEntry(
              index: 4,
              child: SchedulesSection(schedules: homeController.schedules),
            ),
          ],
        ],
        const SizedBox(height: 24),
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

class _HomeStatsStrip extends StatelessWidget {
  final int scheduledCount;
  final int channelCount;
  final int readyPercent;

  const _HomeStatsStrip({
    required this.scheduledCount,
    required this.channelCount,
    required this.readyPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HomeStatTile(
            value: '$scheduledCount',
            label: 'Scheduled',
            color: kBlue,
            backgroundColor: kBlueBg,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HomeStatTile(
            value: '$channelCount',
            label: 'Channels',
            color: kBlue,
            backgroundColor: kBlueBg,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _HomeStatTile(
            value: '$readyPercent%',
            label: 'Ready',
            color: kMint,
            backgroundColor: kMintBg,
          ),
        ),
      ],
    );
  }
}

class _HomeStatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _HomeStatTile({
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextGrey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _HomeEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 360 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
