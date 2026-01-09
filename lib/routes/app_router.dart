import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/forgot_password_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/role_selection_screen.dart';
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/auth/presentation/pages/user_registration_screen.dart';
import '../features/auth/presentation/pages/worker_registration_screen.dart';
import '../features/auth/presentation/pages/onboarding_screen.dart';
import '../features/auth/presentation/pages/otp_verification_screen.dart';
import '../features/tenant/presentation/pages/tenant_main_screen.dart';
import '../features/tenant/presentation/pages/post_job_screen.dart';
import '../features/tenant/presentation/pages/job_detail_screen.dart';
import '../features/tenant/presentation/pages/quotation_comparison_screen.dart';
import '../features/tenant/presentation/pages/job_execution_screen.dart';
import '../features/tenant/presentation/pages/payment_screen.dart';
import '../features/tenant/presentation/pages/rating_screen.dart';
import '../features/worker/presentation/pages/worker_main_screen.dart';
import '../features/worker/presentation/pages/job_bid_screen.dart';
import '../features/worker/presentation/pages/worker_wallet_screen.dart';
import '../features/worker/presentation/pages/active_jobs_screen.dart';
import '../features/worker/presentation/pages/worker_performance_screen.dart';
import '../features/worker/presentation/pages/worker_notifications_screen.dart';
import '../features/profile/presentation/pages/edit_profile_screen.dart';

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
      case OTPVerificationScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            email: args?['email'] ?? '',
            flowType: args?['flowType'] ?? 'registration',
          ),
        );
      case TenantMainScreen.routeName:
        return MaterialPageRoute(builder: (_) => const TenantMainScreen());
      case PostJobScreen.routeName:
        return MaterialPageRoute(builder: (_) => const PostJobScreen());
      case JobDetailScreen.routeName:
        return MaterialPageRoute(builder: (_) => const JobDetailScreen());
      case QuotationComparisonScreen.routeName:
        return MaterialPageRoute(builder: (_) => const QuotationComparisonScreen());
      case JobExecutionScreen.routeName:
        return MaterialPageRoute(builder: (_) => const JobExecutionScreen());
      case PaymentScreen.routeName:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      case RatingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RatingScreen());
      case WorkerMainScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WorkerMainScreen());
      case JobBidScreen.routeName:
        return MaterialPageRoute(builder: (_) => const JobBidScreen());
      case WorkerWalletScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WorkerWalletScreen());
      case ActiveJobsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ActiveJobsScreen());
      case WorkerPerformanceScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WorkerPerformanceScreen());
      case WorkerNotificationsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WorkerNotificationsScreen());
      case EditProfileScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(userData: args),
        );

      default:
        return null;
    }
  }
}


