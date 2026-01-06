import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/forgot_password_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/role_selection_screen.dart';
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/auth/presentation/pages/user_registration_screen.dart';
import '../features/auth/presentation/pages/worker_registration_screen.dart';
import '../features/auth/presentation/pages/onboarding_screen.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.routeName:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case OnboardingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case ForgotPasswordScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RoleSelectionScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case WorkerRegistrationScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WorkerRegistrationScreen());
      case UserRegistrationScreen.routeName:
        final isContractor = settings.arguments == true;
        return MaterialPageRoute(
          builder: (_) => UserRegistrationScreen(isContractor: isContractor),
        );
      default:
        return null;
    }
  }
}

