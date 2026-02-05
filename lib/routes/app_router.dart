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
import '../features/tenant/presentation/pages/job_detail_screen.dart' as tenant;
import '../features/tenant/presentation/pages/quotation_comparison_screen.dart';
import '../features/tenant/presentation/pages/job_execution_screen.dart';
import '../features/tenant/presentation/pages/payment_screen.dart';
import '../features/tenant/presentation/pages/rating_screen.dart';
import '../features/tenant/presentation/pages/tenant_notifications_screen.dart';
import '../features/tenant/presentation/pages/worker_map_screen.dart';
import '../features/worker/presentation/pages/worker_main_screen.dart';
import '../features/worker/presentation/pages/job_bid_screen.dart';
import '../features/worker/presentation/pages/worker_wallet_screen.dart';
import '../features/worker/presentation/pages/active_jobs_screen.dart';
import '../features/worker/presentation/pages/worker_performance_screen.dart';
import '../features/worker/presentation/pages/worker_notifications_screen.dart';
import '../features/profile/presentation/pages/edit_profile_screen.dart';
import '../features/worker/presentation/pages/job_detail_screen.dart' as worker;
import '../features/chat/presentation/pages/chat_screen.dart';
import '../features/chat/presentation/pages/chat_list_screen.dart';

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
      case tenant.JobDetailScreen.routeName:
        final args = settings.arguments;
        String? jobId;
        Map<String, dynamic>? jobData;
        
        if (args is String) {
          jobId = args;
        } else if (args is Map<String, dynamic>) {
          jobId = args['jobId'];
          jobData = args['jobData'];
        }

        return MaterialPageRoute(
          builder: (_) => tenant.JobDetailScreen(
            jobId: jobId,
            jobData: jobData,
          ),
        );
      case worker.JobDetailScreen.routeName:
        final args = settings.arguments;
        String? jobId;
        
        if (args is String) {
          jobId = args;
        } else if (args is Map<String, dynamic>) {
          jobId = args['jobId'];
        }

        return MaterialPageRoute(
          builder: (_) => worker.JobDetailScreen(
            jobId: jobId ?? '',
          ),
        );
      case QuotationComparisonScreen.routeName:
        final jobData = settings.arguments != null 
            ? Map<String, dynamic>.from(settings.arguments as Map) 
            : null;
        return MaterialPageRoute(
          builder: (_) => QuotationComparisonScreen(jobData: jobData),
        );
      case JobExecutionScreen.routeName:
        final jobData = settings.arguments != null 
            ? Map<String, dynamic>.from(settings.arguments as Map) 
            : <String, dynamic>{};
        return MaterialPageRoute(builder: (_) => JobExecutionScreen(jobData: jobData));
      case PaymentScreen.routeName:
        return MaterialPageRoute(builder: (_) => const PaymentScreen());
      case RatingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RatingScreen());
      case WorkerMainScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WorkerMainScreen());
      case JobBidScreen.routeName:
        final jobData = settings.arguments != null 
            ? Map<String, dynamic>.from(settings.arguments as Map) 
            : null;
        return MaterialPageRoute(
          builder: (_) => JobBidScreen(jobData: jobData),
        );
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
      case TenantNotificationsScreen.routeName:
        return MaterialPageRoute(builder: (_) => const TenantNotificationsScreen());
      case ChatScreen.routeName:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(chatData: args),
        );
      case ChatListScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case WorkerMapScreen.routeName:
        return MaterialPageRoute(builder: (_) => const WorkerMapScreen());

      default:
        return null;
    }
  }
}


