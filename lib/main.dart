import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'routes.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gas and Electric Company',
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // 1. App entry point inside main.dart opens up on the login screen first.
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
