import 'package:flutter/material.dart';
import 'package:postflow/components/app_empty_state.dart';
import 'package:postflow/models/social_account.dart';
import 'package:postflow/screen/platforms/platform_models.dart';
import 'package:postflow/screen/platforms/widgets/connection_summary_card.dart';
import 'package:postflow/screen/platforms/widgets/connection_tile.dart';
import 'package:postflow/screen/platforms/widgets/platform_mark.dart';
import 'package:postflow/theme/home_theme.dart';

class PlatformsContent extends StatelessWidget {
  final bool isLoading;
  final bool isSyncing;
  final String? connectingPlatform;
  final String? errorMessage;
  final String? successMessage;
  final bool connectStarted;
  final List<SocialAccount> accounts;
  final VoidCallback onRetry;
  final VoidCallback onDone;
  final void Function(String platformName) onConnectTap;

  const PlatformsContent({
    super.key,
    required this.isLoading,
    required this.isSyncing,
    required this.connectingPlatform,
    required this.errorMessage,
    required this.successMessage,
    required this.connectStarted,
    required this.accounts,
    required this.onRetry,
    required this.onDone,
    required this.onConnectTap,
  });

  @override
  Widget build(BuildContext context) {
    final connectedPlatforms = accounts
        .where(isAccountReadyForPublishing)
        .map((account) => account.platform)
        .toSet()
        .length;
    final followUpAccounts =
        accounts.where((account) => followUpInfoForAccount(account) != null).toList();

    if (isLoading) {
      return const _PlatformsLoadingState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConnectionSummaryCard(connectedPlatforms: connectedPlatforms),
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          _PlatformsNotice(
            icon: Icons.error_outline_rounded,
            title: 'Could not update platforms',
            message: errorMessage!,
            actionLabel: 'Retry',
            onActionPressed: onRetry,
          ),
        ],
        if (successMessage != null) ...[
          const SizedBox(height: 14),
          _PlatformsNotice(
            icon: Icons.check_circle_outline_rounded,
            title: 'Platform connected',
            message: successMessage!,
            actionLabel: 'Refresh',
            onActionPressed: onRetry,
          ),
        ],
        if (connectStarted) ...[
          const SizedBox(height: 14),
          _PlatformsNotice(
            icon: Icons.open_in_browser_rounded,
            title: 'Finish in browser',
            message:
                'After the platform login completes, return here and sync your accounts.',
            actionLabel: isSyncing ? 'Syncing...' : 'Done',
            onActionPressed: isSyncing ? null : onDone,
          ),
        ],
        if (followUpAccounts.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _SectionHeader(
            icon: Icons.rule_rounded,
            title: 'Follow-up steps',
            subtitle: 'Some providers need an extra selection after login.',
          ),
          const SizedBox(height: 8),
          ...followUpAccounts.map((account) {
            final info = followUpInfoForAccount(account)!;
            final platformName = displayPlatformNameForBackend(account.platform);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FollowUpCard(
                platformName: platformName,
                title: info.title,
                message: info.message,
                actionLabel: info.actionLabel,
                icon: info.icon,
                onActionPressed: () => onConnectTap(platformName),
              ),
            );
          }),
        ],
        if (connectedPlatforms == 0) ...[
          const SizedBox(height: 14),
          AppEmptyState(
            icon: Icons.add_link_rounded,
            title: 'No platforms connected',
            message:
                'Connect a social account so PostFlow can publish scheduled content for you.',
            primaryLabel: 'Connect Instagram',
            onPrimaryPressed: () => onConnectTap('Instagram'),
          ),
        ],
        const SizedBox(height: 14),
        const _SectionHeader(
          icon: Icons.public_rounded,
          title: 'Social platforms',
          subtitle: 'Accounts the backend can post to.',
        ),
        const SizedBox(height: 8),
        ...supportedPlatformNames.map((platformName) {
          final account = _accountForPlatform(platformName);
          final state = _stateForAccount(account);
          final title = account?.displayName ?? platformName;
          final subtitle = _subtitleFor(platformName, account);
          final followUp = account == null ? null : followUpInfoForAccount(account);
          final isBusy =
              connectingPlatform == backendPlatformForName(platformName);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ConnectionTile(
              name: title,
              subtitle: subtitle,
              state: state,
              actionLabel:
                  followUp != null && state == PlatformConnectionState.actionNeeded
                      ? followUp.actionLabel
                      : null,
              icon: _PlatformAccountAvatar(
                platformName: platformName,
                imageUrl: account?.profilePictureUrl,
              ),
              isBusy: isBusy,
              onPressed: () => onConnectTap(platformName),
            ),
          );
        }),
      ],
    );
  }

  SocialAccount? _accountForPlatform(String platformName) {
    final backendPlatform = backendPlatformForName(platformName);
    final matches =
        accounts
            .where((account) => account.platform == backendPlatform)
            .toList()
          ..sort((a, b) {
            if (a.isActive == b.isActive) return 0;
            return a.isActive ? -1 : 1;
          });
    return matches.isEmpty ? null : matches.first;
  }

  PlatformConnectionState _stateForAccount(SocialAccount? account) {
    if (account == null) return PlatformConnectionState.notConnected;
    if (!account.isActive) return PlatformConnectionState.actionNeeded;
    return followUpInfoForAccount(account) != null
        ? PlatformConnectionState.actionNeeded
        : PlatformConnectionState.connected;
  }

  String _subtitleFor(String platformName, SocialAccount? account) {
    final followUp = account == null ? null : followUpInfoForAccount(account);
    if (followUp != null) return followUp.title;

    final username = account?.username;
    if (username != null && username.isNotEmpty) return '@$username';
    if (account != null && !account.isActive) return 'Reconnect needed';
    return platformSubtitle(platformName);
  }
}

class _PlatformsLoadingState extends StatelessWidget {
  const _PlatformsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 220),
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

class _PlatformsNotice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onActionPressed;

  const _PlatformsNotice({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPillBg,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(homeRadiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kBlue, size: 22),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
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
          const SizedBox(width: 8),
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(foregroundColor: kBlue),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final String platformName;
  final String title;
  final String message;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onActionPressed;

  const _FollowUpCard({
    required this.platformName,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.icon,
    required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardBg,
      borderRadius: BorderRadius.circular(homeRadiusLg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: kBorderLight),
          borderRadius: BorderRadius.circular(homeRadiusLg),
          boxShadow: homeSoftShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlatformMark(name: platformName),
            const SizedBox(width: 12),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 3,
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
            const SizedBox(width: 8),
            _FollowUpAction(
              icon: icon,
              label: actionLabel,
              onPressed: onActionPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowUpAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _FollowUpAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: kBlue,
        backgroundColor: kPillBg,
        side: BorderSide(color: kBlue.withValues(alpha: 0.28)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(homeRadiusMd),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

class _PlatformAccountAvatar extends StatelessWidget {
  final String platformName;
  final String? imageUrl;

  const _PlatformAccountAvatar({required this.platformName, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return PlatformMark(name: platformName);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(homeRadiusMd),
      child: Image.network(
        imageUrl!,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => PlatformMark(name: platformName),
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
