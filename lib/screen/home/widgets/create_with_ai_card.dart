import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

import 'home_action_button.dart';

class CreateWithAiCard extends StatelessWidget {
  const CreateWithAiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x0F000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kBlueBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(
                '$homeIconPath/Vector-1.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextBlack,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Caption · Image · Video · Motion',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Color(0xb2000000)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          HomeActionButton.primary(label: '+ New Post', onPressed: () {}),
        ],
      ),
    );
  }
}
