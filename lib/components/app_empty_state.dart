import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimaryPressed,
    this.secondaryLabel,
    this.onSecondaryPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final showPrimary = primaryLabel != null && onPrimaryPressed != null;
    final showSecondary = secondaryLabel != null && onSecondaryPressed != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(homeRadiusXl),
        border: Border.all(color: kBorderLight),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kBlueBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: kBlue, size: 34),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextBlack,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kTextGrey,
              fontSize: 13,
              height: 1.45,
              fontFamily: 'Poppins',
            ),
          ),
          if (showPrimary || showSecondary) const SizedBox(height: 22),
          if (showPrimary)
            FilledButton(
              onPressed: onPrimaryPressed,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              child: Text(primaryLabel!),
            ),
          if (showPrimary && showSecondary) const SizedBox(height: 10),
          if (showSecondary)
            OutlinedButton(
              onPressed: onSecondaryPressed,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: kBlue,
                side: const BorderSide(color: Color(0x332C90E3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              child: Text(secondaryLabel!),
            ),
        ],
      ),
    );
  }
}
