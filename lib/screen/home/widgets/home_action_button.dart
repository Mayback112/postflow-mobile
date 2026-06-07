import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

enum HomeActionButtonVariant { primary, link }

class HomeActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final HomeActionButtonVariant variant;

  const HomeActionButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
  }) : variant = HomeActionButtonVariant.primary;

  const HomeActionButton.link({
    super.key,
    required this.label,
    required this.onPressed,
  }) : variant = HomeActionButtonVariant.link;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == HomeActionButtonVariant.primary;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        tapTargetSize: MaterialTapTargetSize.padded,
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 16 : 4,
          vertical: isPrimary ? 10 : 8,
        ),
        backgroundColor: isPrimary ? kBlue : Colors.transparent,
        foregroundColor: kBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isPrimary ? 8 : 6),
        ),
        textStyle: TextStyle(
          fontSize: isPrimary ? 12 : 15,
          fontWeight: FontWeight.w700,
          fontFamily: 'Epilogue',
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: isPrimary ? Colors.white : kBlue),
      ),
    );
  }
}
