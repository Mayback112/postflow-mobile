import 'package:flutter/material.dart';
import 'package:postflow/components/onboarding/onboarding_page.dart';

class Onboarding3Page extends StatelessWidget {
  const Onboarding3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundImage: 'asset/images/background/Onboarding3.png',
      illustrationImage: 'asset/images/illustrations/onboarding3.png',
      showBackButton: true,
      title: 'Publish Everywhere at Once',
      description:
          'Connect Instagram, TikTok, YouTube, LinkedIn, X, and more. One post, every platform, zero manual work.',
      activeStep: 2,
      totalSteps: 4,
      primaryButtonText: 'Continue',
      onPrimaryPressed: () {
        Navigator.pushNamed(context, '/Onboarding4');
      },
    );
  }
}
