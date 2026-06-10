import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_action_button.dart';

class CreateWithAiCard extends StatelessWidget {
  const CreateWithAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    void openCreateWithAi() {
      Navigator.of(context).pushNamed('/CreateWithAi');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kCardBg, kPillBg, kBlueBg],
          stops: [0, 0.64, 1],
        ),
        borderRadius: BorderRadius.circular(homeRadiusXl),
        border: Border.all(color: const Color(0x142C90E3)),
        boxShadow: homeCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2E2C90E3),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create with AI',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: kTextBlack,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Caption, image, video, or motion post',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: kTextGrey,
                        fontFamily: 'Poppins',
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _AiModeChip(icon: Icons.short_text_rounded, label: 'Caption'),
              _AiModeChip(icon: Icons.image_rounded, label: 'Image'),
              _AiModeChip(icon: Icons.movie_creation_rounded, label: 'Video'),
              _AiModeChip(icon: Icons.collections_rounded, label: 'Carousel'),
              _AiModeChip(icon: Icons.upload_file_rounded, label: 'Resources'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HomeActionButton.primary(
                  label: 'Start creating',
                  onPressed: openCreateWithAi,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                onPressed: openCreateWithAi,
                icon: const Icon(Icons.auto_awesome_rounded),
                tooltip: 'Open AI tools',
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: kBlue,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x142C90E3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(homeRadiusMd),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiModeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AiModeChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x142C90E3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: kBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: kTextMuted,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
