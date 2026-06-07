import 'package:flutter/material.dart';
import 'package:postflow/components/onboarding/onboarding_page.dart';

class Onboarding4Page extends StatelessWidget {
  const Onboarding4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundImage: 'asset/images/background/Onboarding4.png',
      illustrationImage: 'asset/images/illustrations/onboarding4.png',
      showBackButton: true,
      title: 'Your Content. On Autopilot.',
      description:
          'Join creators and businesses growing their audience with PostFlow\'s AI-powered scheduling studio.',
      activeStep: 3,
      totalSteps: 4,
      primaryButtonText: 'Sign up',
      onPrimaryPressed: () {
        Navigator.pushNamed(context, '/Signup');
      },
    );
  }
}
