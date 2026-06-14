import 'package:flutter/material.dart';
import 'package:postflow/models/auth_models.dart';
import 'package:postflow/screen/navigation/side_nav_overlay.dart';
import 'package:postflow/screen/profile/widgets/profile_content.dart';
import 'package:postflow/screen/profile/widgets/profile_top_bar.dart';
import 'package:postflow/services/auth_service.dart';
import 'package:postflow/theme/home_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _isSideNavOpen = false;
  bool _isProfileLoading = true;
  AuthUser? _user;

  void _openSideNav() => setState(() => _isSideNavOpen = true);

  void _closeSideNav() => setState(() => _isSideNavOpen = false);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await _authService.me();
      if (!mounted) return;
      setState(() {
        _user = user;
        _isProfileLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProfileLoading = false);
    }
  }

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
                  ProfileTopBar(onMenuTap: _openSideNav),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: ProfileContent(
                        isLoading: _isProfileLoading,
                        user: _user,
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
