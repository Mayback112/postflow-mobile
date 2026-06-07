import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const HomeTopBar({super.key, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: kBlueBg,
            child: ClipOval(
              child: Image.network(
                'https://i.pravatar.cc/150?img=12',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.person, color: kBlue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, Bernard',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              Text(
                'Welcome to PostFlow',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0x991b281b),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          const _HeaderIconButton(
            assetPath: '$homeIconPath/notification-bell-new_svgrepo.com.png',
            size: 19,
          ),
          const SizedBox(width: 10),
          _HeaderIconButton(
            assetPath: '$homeIconPath/heroicons-solid_menu-alt-3.png',
            size: 19,
            onTap: onMenuTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String assetPath;
  final double size;
  final VoidCallback? onTap;

  const _HeaderIconButton({
    required this.assetPath,
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPillBg,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                assetPath,
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
