import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.backgroundImage,
    required this.illustrationImage,
    required this.title,
    required this.description,
    required this.activeStep,
    required this.totalSteps,
    required this.primaryButtonText,
    this.welcomeText,
    this.showBackButton = false,
    this.secondaryButtonText,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  final String backgroundImage;
  final String illustrationImage;
  final String? welcomeText;
  final bool showBackButton;
  final String title;
  final String description;
  final int activeStep;
  final int totalSteps;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompactHeight = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(backgroundImage, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 52,
                      height: 44,
                      child: Image.asset(
                        'asset/images/logo/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PostFlow',
                      style: TextStyle(
                        fontSize: 21,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showBackButton)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 16),
                child: IconButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(CupertinoIcons.back),
                  color: Colors.white,
                  iconSize: 30,
                  tooltip: 'Back',
                ),
              ),
            ),
          Positioned(
            top: screenHeight * 0.22,
            left: 24,
            right: 24,
            child: Image.asset(
              illustrationImage,
              height: screenHeight * 0.36,
              fit: BoxFit.contain,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: isCompactHeight ? 0.58 : 0.44,
              widthFactor: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  32,
                  isCompactHeight ? 16 : 28,
                  32,
                  isCompactHeight ? 16 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isCompactHeight ? 8 : 24),
                    if (welcomeText != null) ...[
                      Text(
                        welcomeText!,
                        style: TextStyle(
                          fontSize: isCompactHeight ? 15 : 16,
                          color: Colors.black.withValues(alpha: 0.6),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: isCompactHeight ? 4 : 6),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isCompactHeight ? 23 : 26,
                        color: Colors.black.withValues(alpha: 0.7),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 8 : 12),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isCompactHeight ? 14 : 15,
                        color: Colors.black.withValues(alpha: 0.7),
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: isCompactHeight ? 12 : 16),
                    _OnboardingStepIndicator(
                      activeStep: activeStep,
                      totalSteps: totalSteps,
                    ),
                    const Spacer(),
                    _OnboardingActions(
                      primaryButtonText: primaryButtonText,
                      secondaryButtonText: secondaryButtonText,
                      onPrimaryPressed: onPrimaryPressed,
                      onSecondaryPressed: onSecondaryPressed,
                    ),
                    SizedBox(height: isCompactHeight ? 4 : 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStepIndicator extends StatelessWidget {
  const _OnboardingStepIndicator({
    required this.activeStep,
    required this.totalSteps,
  });

  final int activeStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index == activeStep;

        return Padding(
          padding: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 4),
          child: Container(
            width: isActive ? 20 : 14,
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xff2c90e3) : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    if (secondaryButtonText == null) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: _OnboardingButton(
          text: primaryButtonText,
          onPressed: onPrimaryPressed,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: SizedBox(
            height: 52,
            child: _OnboardingButton(
              text: primaryButtonText,
              onPressed: onPrimaryPressed,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 52,
            child: _OnboardingButton(
              text: secondaryButtonText!,
              onPressed: onSecondaryPressed,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  const _OnboardingButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff2c90e3),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: const Color(0x4c0b0b0b),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
