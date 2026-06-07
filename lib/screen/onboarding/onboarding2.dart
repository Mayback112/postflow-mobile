import 'package:flutter/material.dart';
import 'package:postflow/components/onboarding/onboarding_page.dart';

class Onboarding2Page extends StatelessWidget {
  const Onboarding2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundImage: 'asset/images/background/Onboarding2.png',
      illustrationImage: 'asset/images/illustrations/onboarding2.png',
      showBackButton: true,
      title: 'Create Content With AI',
      description:
          'Generate captions, hashtags, flyer images, and short videos. Just describe what you need and let PostFlow handle the rest.',
      activeStep: 1,
      totalSteps: 4,
      primaryButtonText: 'Continue',
      onPrimaryPressed: () {
        Navigator.pushNamed(context, '/Onboarding3');
      },
    );
  }
}
