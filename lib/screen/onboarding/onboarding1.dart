import 'package:flutter/material.dart';
import 'package:postflow/components/onboarding/onboarding_page.dart';

class Onboarding1Page extends StatelessWidget {
  const Onboarding1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      backgroundImage: 'asset/images/background/Onboarding1.png',
      illustrationImage: 'asset/images/illustrations/onboarding1.png',
      welcomeText: 'Welcome',
      title: 'Automate Your Social Media Posting',
      description:
          'Schedule what to post, when to post it, and which platforms to publish to. All in one place.',
      activeStep: 0,
      totalSteps: 4,
      primaryButtonText: 'Get started',
      secondaryButtonText: 'Skip',
      onPrimaryPressed: () {
        Navigator.pushNamed(context, '/Onboarding2');
      },
      onSecondaryPressed: () {
        Navigator.pushNamed(context, '/Signup');
      },
    );
  }
}
