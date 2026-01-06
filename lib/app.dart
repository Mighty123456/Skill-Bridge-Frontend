import 'package:flutter/material.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'routes/app_router.dart';
import 'shared/themes/app_theme.dart';

class SkillBridgeApp extends StatelessWidget {
  const SkillBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillBridge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const SplashScreen(),
    );
  }
}

