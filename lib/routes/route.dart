import 'package:flutter/material.dart';
import 'package:postflow/screen/authentication/signup.dart';
import 'package:postflow/screen/authentication/success.dart';
import 'package:postflow/screen/calendar/calendar.dart';
import 'package:postflow/screen/home/home.dart';
import 'package:postflow/screen/onboarding/onboarding1.dart';
import 'package:postflow/screen/onboarding/onboarding2.dart';
import 'package:postflow/screen/onboarding/onboarding3.dart';
import 'package:postflow/screen/onboarding/onboarding4.dart';

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
      case '/Calendar':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CalendarScreen(),
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
