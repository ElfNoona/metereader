import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/scanner/screens/camera_view_screen.dart';
import 'features/scanner/screens/cropping_screen.dart';
import 'features/scanner/screens/confirmation_screen.dart';

class AppRoutes {
  static const String login = '/';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String camera = '/camera';
  static const String cropping = '/cropping';
  static const String confirmation = '/confirmation';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraViewScreen());
      case cropping:
        final imagePath = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CroppingScreen(imagePath: imagePath),
        );
      case confirmation:
        final args = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ConfirmationScreen(extractedText: args ?? ''),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
