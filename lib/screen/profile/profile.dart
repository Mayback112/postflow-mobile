import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSideNavOpen = false;

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SideNavOverlay(
        isOpen: _isSideNavOpen,
        activeIndex: 6,
        onClose: _closeSideNav,
        onItemSelected: (_) => _closeSideNav(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape =
                  MediaQuery.orientationOf(context) == Orientation.landscape;
              final isWide = constraints.maxWidth >= 700 || isLandscape;

              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          _ProfileHeroCard(),
                          SizedBox(height: 14),
                          _ProfileStatsRow(),
                          SizedBox(height: 14),
                          _ProfileSection(
                            title: 'Account details',
                            icon: Icons.badge_rounded,
                            children: [
                              _InfoRow(
                                icon: Icons.person_rounded,
                                label: 'Full name',
                                value: 'Bernard Obeng Akoto',
                              ),
                              _InfoRow(
                                icon: Icons.mail_rounded,
                                label: 'Email',
                                value: 'bernard@postflow.app',
                              ),
                              _InfoRow(
                                icon: Icons.location_on_rounded,
                                label: 'Timezone',
                                value: 'Africa/Accra',
                              ),
                              _InfoRow(
                                icon: Icons.calendar_today_rounded,
                                label: 'Member since',
                                value: 'March 2026',
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          _ProfileSection(
                            title: 'Subscription',
                            icon: Icons.workspace_premium_rounded,
                            children: [
                              _InfoRow(
                                icon: Icons.verified_rounded,
                                label: 'Plan',
                                value: 'Pro plan',
                              ),
                              _InfoRow(
                                icon: Icons.auto_awesome_rounded,
                                label: 'AI credits',
                                value: '420 remaining',
                              ),
                              _InfoRow(
                                icon: Icons.schedule_rounded,
                                label: 'Scheduled posts',
                                value: '18 this month',
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          _ConnectedAccountsCard(),
                          SizedBox(height: 14),
                          _ProfileSection(
                            title: 'Security',
                            icon: Icons.lock_rounded,
                            children: [
                              _ActionRow(
                                icon: Icons.password_rounded,
                                label: 'Password',
                                value: 'Last updated 12 days ago',
                              ),
                              _ActionRow(
                                icon: Icons.verified_user_rounded,
                                label: 'Two-step verification',
                                value: 'Not enabled',
                              ),
                              _ActionRow(
                                icon: Icons.devices_rounded,
                                label: 'Active sessions',
                                value: '2 devices',
                              ),
                            ],
                          ),
                          SizedBox(height: 14),
                          _ProfileSection(
                            title: 'Preferences',
                            icon: Icons.tune_rounded,
                            children: [
                              _ActionRow(
                                icon: Icons.notifications_rounded,
                                label: 'Notifications',
                                value: 'Email and push',
                              ),
                              _ActionRow(
                                icon: Icons.language_rounded,
                                label: 'Language',
                                value: 'English',
                              ),
                              _ActionRow(
                                icon: Icons.palette_rounded,
                                label: 'Theme',
                                value: 'Light',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              if (isWide) return content;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: homePageMaxWidth),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _ProfileTopBar({required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            tooltip: 'Go back',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: kTextMuted,
              backgroundColor: kPillBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextBlack,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'User details and account settings',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onMenuTap,
            icon: Image.asset(
              '$homeIconPath/heroicons-solid_menu-alt-3.png',
              width: 19,
              height: 19,
              fit: BoxFit.contain,
            ),
            tooltip: 'Open navigation menu',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: kPillBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlueBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
      ),
      child: Row(
        children: [
          CircleAvatar(
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
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.person, color: Colors.white, size: 36),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bernard Obeng Akoto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextBlack,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Creator and business owner',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _MiniBadge(label: 'Pro', icon: Icons.workspace_premium),
                    _MiniBadge(label: 'Verified', icon: Icons.verified),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_rounded, size: 19),
            tooltip: 'Edit profile',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
              foregroundColor: kBlue,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kBlue, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: kBlue,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(label: 'Posts', value: '128'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'Scheduled', value: '18'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'Platforms', value: '3'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextBlack,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kTextGrey,
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: Icon(icon, color: kBlue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileRow(
      icon: icon,
      label: label,
      value: value,
      trailing: const SizedBox.shrink(),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileRow(
      icon: icon,
      label: label,
      value: value,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: kTextGrey,
        size: 14,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget trailing;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kPillBg,
              borderRadius: BorderRadius.circular(homeRadiusMd),
            ),
            child: Icon(icon, color: kBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextBlack,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _ConnectedAccountsCard extends StatelessWidget {
  const _ConnectedAccountsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
        boxShadow: homeSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: const Icon(Icons.public_rounded, color: kBlue, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Connected accounts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/Platforms'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 44),
                  foregroundColor: kBlue,
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlatformBadge(label: 'Instagram'),
              _PlatformBadge(label: 'YouTube'),
              _PlatformBadge(label: 'Facebook'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  final String label;

  const _PlatformBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (label.toLowerCase()) {
      'instagram' => '$homeIconPath/platform_instagram_home.png',
      'youtube' => '$homeIconPath/platform_youtube_home.png',
      'linkedin' => '$homeIconPath/platform_linkedin_home.png',
      'tiktok' => '$homeIconPath/platform_tiktok_home.png',
      _ => null,
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: kPillBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kBorderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (assetPath == null)
            const Icon(Icons.facebook_rounded, color: kBlue, size: 18)
          else
            Image.asset(assetPath, width: 18, height: 18, fit: BoxFit.contain),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
