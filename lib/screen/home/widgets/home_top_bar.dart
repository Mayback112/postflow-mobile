import 'package:flutter/material.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/services/auth_service.dart';
import 'package:postflow/theme/home_theme.dart';

class HomeTopBar extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const HomeTopBar({super.key, this.onMenuTap});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  AuthUser? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await AuthService().me();
      if (!mounted) return;
      setState(() => _user = user);
    } catch (_) {
      if (!mounted) return;
      setState(() => _user = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _displayName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _HomeAvatar(user: _user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
                const Text(
                  'Welcome to PostFlow',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0x991b281b),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _HeaderIconButton(
            assetPath: '$homeIconPath/notification-bell-new_svgrepo.com.png',
            size: 19,
            onTap: () => Navigator.of(context).pushNamed('/Notifications'),
          ),
          const SizedBox(width: 10),
          _HeaderIconButton(
            assetPath: '$homeIconPath/heroicons-solid_menu-alt-3.png',
            size: 19,
            onTap: widget.onMenuTap,
          ),
        ],
      ),
    );
  }

  String get _displayName {
    final name = _user?.name?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = _user?.email.trim();
    if (email != null && email.isNotEmpty) return email;

    return 'there';
  }
}

class _HomeAvatar extends StatelessWidget {
  final AuthUser? user;

  const _HomeAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final imageUrl = user?.profileImageUrl;
    final initials = _initialsFor(user);

    return CircleAvatar(
      radius: 25,
      backgroundColor: kBlueBg,
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              initials,
              style: const TextStyle(
                color: kBlue,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            )
          : ClipOval(
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Text(
                  initials,
                  style: const TextStyle(
                    color: kBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
    );
  }

  String _initialsFor(AuthUser? user) {
    final name = user?.name?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      return parts.take(2).map((part) => part[0].toUpperCase()).join();
    }

    final email = user?.email.trim();
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();

    return '?';
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
