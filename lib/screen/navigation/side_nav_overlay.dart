import 'dart:ui';

import 'package:flutter/material.dart';

import 'side_nav.dart';

class SideNavOverlay extends StatelessWidget {
  final bool isOpen;
  final int activeIndex;
  final VoidCallback onClose;
  final ValueChanged<int>? onItemSelected;
  final Widget child;

  const SideNavOverlay({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.child,
    this.activeIndex = 0,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= 700;
    final panelWidth = isWide
        ? 360.0
        : (screenWidth * 0.76).clamp(300.0, 360.0);

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isOpen,
            child: AnimatedOpacity(
              opacity: isOpen ? 1 : 0,
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: onClose,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: const Color(0x1A000000)),
                ),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          right: isOpen ? 0 : -panelWidth,
          width: panelWidth,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 28,
                  offset: Offset(-10, 0),
                ),
              ],
            ),
            child: SideNav(
              activeIndex: activeIndex,
              onClose: onClose,
              onItemSelected: onItemSelected,
            ),
          ),
        ),
      ],
    );
  }
}
