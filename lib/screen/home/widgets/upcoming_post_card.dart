import 'package:flutter/material.dart';
import 'package:postflow/models/home_models.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_action_button.dart';

class UpcomingPostCard extends StatelessWidget {
  final UpcomingPost post;

  const UpcomingPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBlueBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kBlue,
              fontFamily: 'Epilogue',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            post.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: kTextMuted),
          ),
          const SizedBox(height: 4),
          Text(
            post.scheduledText,
            style: const TextStyle(
              fontSize: 13,
              color: kTextMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          HomeActionButton.link(label: 'View Now', onPressed: () {}),
        ],
      ),
    );
  }
}
