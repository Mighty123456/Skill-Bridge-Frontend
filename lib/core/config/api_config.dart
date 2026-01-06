class ApiConfig {
  // Use Vercel URL for auth/OTP services
  static const String vercelBaseUrl = 'https://skill-bridge-backend-delta.vercel.app/api';
  
  // Use Render URL for file upload services
  static const String renderBaseUrl = 'https://skill-bridge-backend-1erz.onrender.com/api';
  
  // Auth endpoints (use Vercel)
  static String get authBaseUrl => vercelBaseUrl;
  
  // Upload endpoints (use Render)
  static String get uploadBaseUrl => renderBaseUrl;
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 30);
}

