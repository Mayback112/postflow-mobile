import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

const kDivider = Color(0xffe1e4e5);
const _sideNavIconPath = 'asset/icons';

class _NavItem {
  final String iconPath;
  final String label;
  final String? routeName;
  final String? sectionLabel;

  const _NavItem(
    this.iconPath,
    this.label, {
    this.routeName,
    this.sectionLabel,
  });

  bool get isEnabled => routeName != null;
}

const _navItems = [
  _NavItem(
    '$_sideNavIconPath/side_nav_home.png',
    'Home',
    routeName: '/Home',
    sectionLabel: 'Main',
  ),
  _NavItem(
    '$_sideNavIconPath/side_nav_calendar.png',
    'Calendar',
    routeName: '/Calendar',
  ),
  _NavItem(
    '$_sideNavIconPath/side_nav_scheduled.png',
    'Scheduled',
    routeName: '/Scheduled',
  ),
  _NavItem(
    '$_sideNavIconPath/side_nav_ai.png',
    'Create with AI',
    routeName: '/CreateWithAi',
    sectionLabel: 'Create',
  ),
  _NavItem(
    '$_sideNavIconPath/side_nav_scheduled.png',
    'Post content',
    routeName: '/CreateManual',
  ),
  _NavItem(
    '$_sideNavIconPath/side_nav_connect.png',
    'Platforms',
    routeName: '/Platforms',
    sectionLabel: 'Account',
  ),
  _NavItem(
    '$_sideNavIconPath/side_nav_profile.png',
    'Profile',
    routeName: '/Profile',
  ),
];

class SideNav extends StatefulWidget {
  final int activeIndex;
  final VoidCallback? onClose;
  final ValueChanged<int>? onItemSelected;

  const SideNav({
    super.key,
    this.activeIndex = 0,
    this.onClose,
    this.onItemSelected,
  });

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  late int _active;

  @override
  void initState() {
    super.initState();
    _active = widget.activeIndex;
  }

  @override
  void didUpdateWidget(covariant SideNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _active = widget.activeIndex;
    }
  }

  void _selectItem(int index) {
    final routeName = _navItems[index].routeName;
    if (routeName == null) return;

    setState(() => _active = index);
    widget.onItemSelected?.call(index);

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != routeName) {
      Navigator.of(context).pushReplacementNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Image.asset(
                      'asset/images/logo/logo-blue.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'PostFlow',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kTextBlack,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close navigation',
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        foregroundColor: kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kPillBg,
                    borderRadius: BorderRadius.circular(homeRadiusXl),
                    border: Border.all(color: kBorderLight),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 31,
                        backgroundColor: kBlue,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: ClipOval(
                            child: Image.network(
                              'https://i.pravatar.cc/150?img=12',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bernard Obeng Akoto',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kTextBlack,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 28,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kBlueBg,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Text(
                                    'Pro plan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: kBlue,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(color: kDivider, thickness: 1, height: 1),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverList.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, i) {
                final item = _navItems[i];
                final isActive = i == _active;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (item.sectionLabel != null)
                      _NavSectionLabel(label: item.sectionLabel!),
                    _NavTile(
                      iconPath: item.iconPath,
                      label: item.label,
                      isActive: isActive,
                      isEnabled: item.isEnabled,
                      onTap: () => _selectItem(i),
                    ),
                  ],
                );
              },
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _SideNavFooter(onClose: widget.onClose),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavSectionLabel extends StatelessWidget {
  final String label;

  const _NavSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: kTextGrey,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback onTap;

  const _NavTile({
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      enabled: isEnabled,
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(homeRadiusLg),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            decoration: BoxDecoration(
              color: isActive ? kBlueBg : Colors.transparent,
              borderRadius: BorderRadius.circular(homeRadiusLg),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(homeRadiusMd),
                  ),
                  child: Image.asset(
                    iconPath,
                    width: 21,
                    height: 21,
                    fit: BoxFit.contain,
                    color: isActive
                        ? kBlue
                        : isEnabled
                        ? const Color(0xff2f2f2f)
                        : kTextGrey.withValues(alpha: 0.48),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? kBlue
                          : isEnabled
                          ? kTextMuted
                          : kTextGrey.withValues(alpha: 0.62),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: kBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SideNavFooter extends StatelessWidget {
  final VoidCallback? onClose;

  const _SideNavFooter({this.onClose});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kPillBg,
            borderRadius: BorderRadius.circular(homeRadiusXl),
            border: Border.all(color: kBorderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ready to publish?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kTextBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Add media, caption, hashtags, then schedule it.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kTextGrey,
                  fontSize: 11,
                  height: 1.35,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  onClose?.call();
                  final currentRoute = ModalRoute.of(context)?.settings.name;
                  if (currentRoute != '/CreateManual') {
                    Navigator.of(context).pushReplacementNamed('/CreateManual');
                  }
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('Create post'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
