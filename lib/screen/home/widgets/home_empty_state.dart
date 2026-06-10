import 'package:flutter/material.dart';
import 'package:postflow/screen/home/widgets/home_action_button.dart';
import 'package:postflow/theme/home_theme.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    void openCreateWithAi() {
      Navigator.of(context).pushNamed('/CreateWithAi');
    }

    void openPlatforms() {
      Navigator.of(context).pushNamed('/Platforms');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusXl),
        border: Border.all(color: kBorderLight),
        boxShadow: homeCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: kBlueBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: kBlue,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'No posts scheduled yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextBlack,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Create your first post or connect a platform to start planning your calendar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kTextGrey,
              fontSize: 13,
              height: 1.45,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          HomeActionButton.primary(
            label: 'Create first post',
            onPressed: openCreateWithAi,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: openPlatforms,
            icon: const Icon(Icons.add_link_rounded, size: 19),
            label: const Text('Connect platforms'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: kBlue,
              side: const BorderSide(color: Color(0x332C90E3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _EmptyStateChecklist(),
        ],
      ),
    );
  }
}

class _EmptyStateChecklist extends StatelessWidget {
  const _EmptyStateChecklist();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _EmptyStateStep(
          icon: Icons.auto_awesome_rounded,
          label: 'Draft with AI',
        ),
        SizedBox(height: 10),
        _EmptyStateStep(icon: Icons.schedule_rounded, label: 'Choose a time'),
        SizedBox(height: 10),
        _EmptyStateStep(icon: Icons.public_rounded, label: 'Publish anywhere'),
      ],
    );
  }
}

class _EmptyStateStep extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmptyStateStep({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kPillBg,
        borderRadius: BorderRadius.circular(homeRadiusMd),
        border: Border.all(color: kBorderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: kBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kTextMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
