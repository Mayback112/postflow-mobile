import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignInContent extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;
  final VoidCallback onTestTap;

  const SignInContent({
    super.key,
    required this.isLoading,
    required this.onGoogleTap,
    required this.onAppleTap,
    required this.onTestTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthBrandHeader(),
              const SizedBox(height: 16),
              const Text(
                'Schedule. Generate. Grow.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _SocialButton(
                icon: Image.asset(
                  'asset/images/auth/google_g_white.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
                label: 'Continue with Google',
                isLoading: isLoading,
                onTap: onGoogleTap,
              ),
              const SizedBox(height: 14),
              _SocialButton(
                icon: Image.asset(
                  'asset/images/auth/apple_logo.png',
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
                label: 'Continue with Apple',
                isLoading: isLoading,
                onTap: onAppleTap,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 14),
                _SecondaryButton(
                  label: 'Use local test account',
                  isLoading: isLoading,
                  onTap: onTestTap,
                ),
              ],
              const SizedBox(height: 30),
              const Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: Image.asset(
            'asset/images/logo/logo-blue.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'PostFlow',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2c90e3),
          disabledBackgroundColor: const Color(
            0xff2c90e3,
          ).withValues(alpha: 0.62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
          shadowColor: Colors.black38,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xff2c90e3),
          side: const BorderSide(color: Color(0x332C90E3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
