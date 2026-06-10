import 'package:flutter/material.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/theme/home_theme.dart';

enum _ConnectionState { connected, actionNeeded, notConnected }

class PlatformsScreen extends StatefulWidget {
  const PlatformsScreen({super.key});

  @override
  State<PlatformsScreen> createState() => _PlatformsScreenState();
}

class _PlatformsScreenState extends State<PlatformsScreen> {
  bool _isSideNavOpen = false;

  final Map<String, _ConnectionState> _platformStates = {
    'Instagram': _ConnectionState.connected,
    'Facebook': _ConnectionState.actionNeeded,
    'TikTok': _ConnectionState.notConnected,
    'YouTube': _ConnectionState.connected,
    'LinkedIn': _ConnectionState.notConnected,
  };

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  void _connectPlatform(String name) {
    setState(() {
      _platformStates[name] = _ConnectionState.connected;
    });
  }

  void _openConnectSheet(String name, _ConnectionState state) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _PlatformConnectSheet(
          platform: name,
          state: state,
          onConnected: () {
            Navigator.of(context).pop();
            _connectPlatform(name);
          },
        );
      },
    );
  }

  int get _connectedPlatforms {
    return _platformStates.values
        .where((state) => state == _ConnectionState.connected)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SideNavOverlay(
        isOpen: _isSideNavOpen,
        activeIndex: 5,
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
                  _PlatformsTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ConnectionSummaryCard(
                            connectedPlatforms: _connectedPlatforms,
                          ),
                          const SizedBox(height: 14),
                          _SectionHeader(
                            icon: Icons.public_rounded,
                            title: 'Social platforms',
                            subtitle: 'Accounts the backend can post to.',
                          ),
                          const SizedBox(height: 8),
                          ..._platformStates.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ConnectionTile(
                                name: entry.key,
                                subtitle: _platformSubtitle(entry.key),
                                state: entry.value,
                                icon: _PlatformMark(name: entry.key),
                                onPressed: () =>
                                    _openConnectSheet(entry.key, entry.value),
                              ),
                            ),
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

  String _platformSubtitle(String name) {
    return switch (name) {
      'Instagram' => 'Posts, reels, and captions',
      'Facebook' => 'Pages and cross-posting',
      'TikTok' => 'Short video publishing',
      'YouTube' => 'Shorts and video uploads',
      'LinkedIn' => 'Company and profile posts',
      _ => 'Publishing access',
    };
  }
}

class _PlatformsTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;

  const _PlatformsTopBar({required this.onMenuTap});

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
                  'Platforms',
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
                  'Connect accounts for publishing',
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

class _ConnectionSummaryCard extends StatelessWidget {
  final int connectedPlatforms;

  const _ConnectionSummaryCard({required this.connectedPlatforms});

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
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(homeRadiusMd),
            ),
            child: const Icon(Icons.hub_rounded, color: kBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Connection center',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$connectedPlatforms social accounts ready to publish',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformConnectSheet extends StatelessWidget {
  final String platform;
  final _ConnectionState state;
  final VoidCallback onConnected;

  const _PlatformConnectSheet({
    required this.platform,
    required this.state,
    required this.onConnected,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = state == _ConnectionState.connected;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _PlatformMark(name: platform),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConnected ? 'Manage $platform' : 'Connect $platform',
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
                        isConnected
                            ? 'Refresh access or reconnect this account.'
                            : 'Choose how PostFlow should get posting access.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextGrey,
                          fontSize: 12,
                          height: 1.35,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetActionButton(
              icon: Icons.verified_rounded,
              label: 'Continue with $platform OAuth',
              subtitle: 'Recommended for secure posting permissions',
              onPressed: onConnected,
            ),
            const SizedBox(height: 10),
            _SheetActionButton(
              icon: Icons.key_rounded,
              label: 'Login with credentials',
              subtitle: 'Use account username, email, or password details',
              onPressed: onConnected,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPillBg,
                border: Border.all(color: kBorderLight),
                borderRadius: BorderRadius.circular(homeRadiusMd),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_rounded, color: kBlue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your credentials are encrypted and only used to connect, refresh, and publish to the platform you choose.',
                      style: TextStyle(
                        color: kTextMuted,
                        fontSize: 12,
                        height: 1.4,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onPressed;

  const _SheetActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardBg,
      borderRadius: BorderRadius.circular(homeRadiusLg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(homeRadiusLg),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: kBorderLight),
            borderRadius: BorderRadius.circular(homeRadiusLg),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBlueBg,
                  borderRadius: BorderRadius.circular(homeRadiusMd),
                ),
                child: Icon(icon, color: kBlue, size: 20),
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
                        color: kTextBlack,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
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
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: kTextGrey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
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
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextGrey,
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConnectionTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final _ConnectionState state;
  final Widget icon;
  final VoidCallback onPressed;

  const _ConnectionTile({
    required this.name,
    required this.subtitle,
    required this.state,
    required this.icon,
    required this.onPressed,
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
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusAction(state: state, onPressed: onPressed),
        ],
      ),
    );
  }
}

class _StatusAction extends StatelessWidget {
  final _ConnectionState state;
  final VoidCallback onPressed;

  const _StatusAction({required this.state, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isConnected = state == _ConnectionState.connected;
    final isActionNeeded = state == _ConnectionState.actionNeeded;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(88, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        foregroundColor: isConnected
            ? kMint
            : isActionNeeded
            ? kAmber
            : kBlue,
        backgroundColor: isConnected
            ? kMintBg
            : isActionNeeded
            ? kAmberBg
            : kPillBg,
        side: BorderSide(
          color: isConnected
              ? kMint.withValues(alpha: 0.3)
              : isActionNeeded
              ? kAmber.withValues(alpha: 0.3)
              : kBlue.withValues(alpha: 0.28),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(homeRadiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
      child: Text(
        isConnected
            ? 'Linked'
            : isActionNeeded
            ? 'Review'
            : 'Connect',
      ),
    );
  }
}

class _PlatformMark extends StatelessWidget {
  final String name;

  const _PlatformMark({required this.name});

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (name.toLowerCase()) {
      'instagram' => '$homeIconPath/platform_instagram_home.png',
      'tiktok' => '$homeIconPath/platform_tiktok_home.png',
      'youtube' => '$homeIconPath/platform_youtube_home.png',
      'linkedin' => '$homeIconPath/platform_linkedin_home.png',
      _ => null,
    };

    return _LogoShell(
      child: assetPath == null
          ? const Icon(Icons.facebook_rounded, color: kBlue, size: 24)
          : Image.asset(assetPath, width: 24, height: 24, fit: BoxFit.contain),
    );
  }
}

class _LogoShell extends StatelessWidget {
  final Widget child;

  const _LogoShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kPillBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusMd),
      ),
      child: child,
    );
  }
}
