import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:postflow/controllers/auth_controller.dart';
import 'package:postflow/screen/authentication/widgets/sign_in_content.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _signIn(Future<bool> Function() signInAction) async {
    final signedIn = await signInAction();
    if (!mounted) return;

    if (signedIn) {
      if (kDebugMode) {
        debugPrint('AUTH navigation to /Success');
      }
      Navigator.pushNamedAndRemoveUntil(context, '/Success', (_) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _authController.errorMessage ??
              'Authentication failed. Please try again.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) {
        final isLoading = _authController.isLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SignInContent(
            isLoading: isLoading,
            onGoogleTap: () => _signIn(_authController.signInWithGoogle),
            onAppleTap: () => _signIn(_authController.signInWithApple),
            onTestTap: () => _signIn(_authController.testSignIn),
          ),
        );
      },
    );
  }
}
