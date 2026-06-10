import 'package:flutter/material.dart';
import 'package:postflow/components/app_empty_state.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/theme/home_theme.dart';

class ProfileContent extends StatelessWidget {
  final bool isLoading;
  final AuthUser? user;

  const ProfileContent({
    super.key,
    required this.isLoading,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final profileUser = user;

    if (isLoading && profileUser == null) {
      return const _ProfileLoadingCard();
    }

    if (profileUser == null) {
      return AppEmptyState(
        icon: Icons.person_add_alt_1_rounded,
        title: 'No profile loaded',
        message: 'Sign in to load your account details and profile image.',
        primaryLabel: 'Sign in',
        onPrimaryPressed: () => Navigator.of(context).pushNamed('/Signup'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHeroCard(user: profileUser),
        const SizedBox(height: 14),
        const _ProfileStatsRow(),
        const SizedBox(height: 14),
        _ProfileSection(
          title: 'Account details',
          icon: Icons.badge_rounded,
          children: [
            _InfoRow(
              icon: Icons.person_rounded,
              label: 'Full name',
              value: profileUser.name?.trim().isNotEmpty == true
                  ? profileUser.name!.trim()
                  : 'Not set',
            ),
            _InfoRow(
              icon: Icons.mail_rounded,
              label: 'Email',
              value: profileUser.email,
            ),
            _InfoRow(
              icon: Icons.image_rounded,
              label: 'Profile image',
              value: profileUser.profileImageUrl == null
                  ? 'Default avatar'
                  : 'Provider image',
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _ConnectedAccountsCard(),
      ],
    );
  }
}

class _ProfileLoadingCard extends StatelessWidget {
  const _ProfileLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kCardBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
        boxShadow: homeSoftShadow,
      ),
      child: const CircularProgressIndicator(color: kBlue),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final AuthUser user;

  const _ProfileHeroCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user.name?.trim().isNotEmpty == true
        ? user.name!.trim()
        : user.email;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlueBg,
        borderRadius: BorderRadius.circular(homeRadiusLg),
      ),
      child: Row(
        children: [
          _ProfileAvatar(user: user, radius: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextBlack,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
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

class _ProfileAvatar extends StatelessWidget {
  final AuthUser user;
  final double radius;

  const _ProfileAvatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    final imageUrl = user.profileImageUrl;
    final initials = _initialsFor(user);

    return CircleAvatar(
      radius: radius,
      backgroundColor: kBlue,
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.62,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            )
          : ClipOval(
              child: Image.network(
                imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.62,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
    );
  }

  String _initialsFor(AuthUser user) {
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      return parts.take(2).map((part) => part[0].toUpperCase()).join();
    }

    return user.email.isEmpty ? '?' : user.email[0].toUpperCase();
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(label: 'Posts', value: '0'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'Scheduled', value: '0'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _StatCard(label: 'Platforms', value: '0'),
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
          Container(
            constraints: const BoxConstraints(minHeight: 42),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: kPillBg,
              borderRadius: BorderRadius.circular(homeRadiusMd),
              border: Border.all(color: kBorderLight),
            ),
            child: const Text(
              'No connected accounts',
              style: TextStyle(
                color: kTextGrey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
