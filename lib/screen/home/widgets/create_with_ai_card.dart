import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_action_button.dart';

class CreateWithAiCard extends StatelessWidget {
  const CreateWithAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(homeSpaceLg),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        border: Border.all(color: kBorderLight),
        boxShadow: homeCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kMintBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: Center(
                  child: Image.asset(
                    '$homeIconPath/Vector-1.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    semanticLabel: 'AI creation',
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
                        fontSize: 15,
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: HomeActionButton.primary(
                  label: '+ New Post',
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome_rounded),
                tooltip: 'Open AI tools',
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: kMint,
                  side: const BorderSide(color: kBorderLight),
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
