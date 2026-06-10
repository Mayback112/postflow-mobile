import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:postflow/controllers/platforms_controller.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/screen/platforms/platform_models.dart';
import 'package:postflow/screen/platforms/widgets/platform_connect_sheet.dart';
import 'package:postflow/screen/platforms/widgets/platforms_content.dart';
import 'package:postflow/screen/platforms/widgets/platforms_top_bar.dart';
import 'package:postflow/theme/home_theme.dart';

class PlatformsScreen extends StatefulWidget {
  const PlatformsScreen({super.key});

  @override
  State<PlatformsScreen> createState() => _PlatformsScreenState();
}

class _PlatformsScreenState extends State<PlatformsScreen>
    with WidgetsBindingObserver {
  late final PlatformsController _platformsController;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  bool _isSideNavOpen = false;

  @override
  void initState() {
    super.initState();
    _platformsController = PlatformsController();
    _appLinks = AppLinks();
    WidgetsBinding.instance.addObserver(this);
    _platformsController.loadAccounts();
    _listenForConnectCallbacks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    _platformsController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _platformsController.connectStarted) {
      _platformsController.syncAccountsAfterConnect();
    }
  }

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  void _listenForConnectCallbacks() {
    _appLinks.getInitialLink().then((uri) {
      if (uri == null) return;
      _platformsController.handleConnectCallback(uri);
    });
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _platformsController.handleConnectCallback,
      onError: (_) {},
    );
  }

  void _openConnectSheet(String name) {
    final backendPlatform = backendPlatformForName(name);
    final account = _platformsController.accountForPlatform(backendPlatform);
    final state = account == null
        ? PlatformConnectionState.notConnected
        : account.isActive
        ? PlatformConnectionState.connected
        : PlatformConnectionState.actionNeeded;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return PlatformConnectSheet(
          platform: name,
          state: state,
          onConnected: () {
            Navigator.of(context).pop();
            _platformsController.connectPlatform(name);
          },
        );
      },
    );
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
                  PlatformsTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: AnimatedBuilder(
                        animation: _platformsController,
                        builder: (context, _) {
                          return PlatformsContent(
                            isLoading: _platformsController.isLoading,
                            isSyncing: _platformsController.isSyncing,
                            connectingPlatform:
                                _platformsController.connectingPlatform,
                            errorMessage: _platformsController.errorMessage,
                            successMessage: _platformsController.successMessage,
                            connectStarted: _platformsController.connectStarted,
                            accounts: _platformsController.accounts,
                            onRetry: _platformsController.loadAccounts,
                            onDone:
                                _platformsController.syncAccountsAfterConnect,
                            onConnectTap: _openConnectSheet,
                          );
                        },
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
