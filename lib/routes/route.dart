import 'package:flutter/material.dart';
import 'package:postflow/screen/authentication/signup.dart';
import 'package:postflow/screen/authentication/success.dart';
import 'package:postflow/screen/calendar/calendar.dart';
import 'package:postflow/screen/create_ai/create_with_ai.dart';
import 'package:postflow/screen/create_manual/create_manual.dart';
import 'package:postflow/screen/home/home.dart';
import 'package:postflow/screen/notifications/notifications.dart';
import 'package:postflow/screen/onboarding/onboarding1.dart';
import 'package:postflow/screen/onboarding/onboarding2.dart';
import 'package:postflow/screen/onboarding/onboarding3.dart';
import 'package:postflow/screen/onboarding/onboarding4.dart';
import 'package:postflow/screen/platforms/platforms.dart';
import 'package:postflow/screen/profile/profile.dart';
import 'package:postflow/screen/scheduled/scheduled.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';

    switch (routeName) {
      case '/':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Onboarding1Page(),
        );
      case '/Onboarding2':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Onboarding2Page(),
        );
      case '/Onboarding3':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Onboarding3Page(),
        );
      case '/Onboarding4':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Onboarding4Page(),
        );
      case '/Signup':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignInPage(),
        );
      case '/Success':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SuccessPage(),
        );
      case '/Home':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomePage(),
        );
      case '/Notifications':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotificationsScreen(),
        );
      case '/CreateWithAi':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateWithAiScreen(),
        );
      case '/CreateManual':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CreateManualScreen(),
        );
      case '/Calendar':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CalendarScreen(),
        );
      case '/Scheduled':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ScheduledScreen(),
        );
      case '/Platforms':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PlatformsScreen(),
        );
      case '/Profile':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for $routeName')),
          ),
        );
    }
  }
}
