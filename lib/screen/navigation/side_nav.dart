import 'package:flutter/material.dart';
import 'package:postflow/theme/home_theme.dart';

const kDivider = Color(0xffe1e4e5);
const _sideNavIconPath = 'asset/icons';

class _NavItem {
  final String iconPath;
  final String label;
  final String? routeName;

  const _NavItem(this.iconPath, this.label, {this.routeName});
}

const _navItems = [
  _NavItem('$_sideNavIconPath/side_nav_home.png', 'Home', routeName: '/Home'),
  _NavItem(
    '$_sideNavIconPath/side_nav_calendar.png',
    'Calendar',
    routeName: '/Calendar',
  ),
  _NavItem('$_sideNavIconPath/side_nav_scheduled.png', 'Scheduled a post'),
  _NavItem('$_sideNavIconPath/side_nav_ai.png', 'Create with AI'),
  _NavItem('$_sideNavIconPath/side_nav_connect.png', 'Connect platform'),
  _NavItem('$_sideNavIconPath/side_nav_profile.png', 'Profile'),
];

class SideNav extends StatefulWidget {
  final int activeIndex;
  final ValueChanged<int>? onItemSelected;

  const SideNav({super.key, this.activeIndex = 0, this.onItemSelected});

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

  void _selectItem(int index) {
    setState(() => _active = index);
    widget.onItemSelected?.call(index);

    final routeName = _navItems[index].routeName;
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (routeName != null && currentRoute != routeName) {
      Navigator.of(context).pushReplacementNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 84),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: kBlue,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/150?img=12',
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bernard Obeng Akoto',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kBlue,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Subscription',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      color: kTextGrey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Divider(color: kDivider, thickness: 1, height: 1),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final isActive = i == _active;
                  return _NavTile(
                    iconPath: item.iconPath,
                    label: item.label,
                    isActive: isActive,
                    onTap: () => _selectItem(i),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.iconPath,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            const SizedBox(width: 28),
            Image.asset(
              iconPath,
              width: 21,
              height: 21,
              fit: BoxFit.contain,
              color: isActive ? kBlue : const Color(0xff2f2f2f),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isActive ? kBlue : kTextMuted,
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
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
