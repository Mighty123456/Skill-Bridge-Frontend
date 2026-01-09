class ApiConfig {
  // SET THIS TO TRUE FOR LOCAL TESTING, FALSE FOR PRODUCTION (Vercel/Render)
  static const bool useLocalHost = false;

  // Local IPs: 
  // 10.0.2.2 for Android Emulator
  // 127.0.0.1 or localhost for iOS Emulator, Web, or Windows
  // Use your PC's IP (e.g., 10.21.162.145) for Physical Devices
  static const String localIp = '10.0.2.2'; // Change to '10.21.162.145' for physical device or 'localhost' for Windows
  
  // Base URLs
  static const String vercelBaseUrl = 'https://skill-bridge-backend-delta.vercel.app/api';
  static const String renderBaseUrl = 'https://skill-bridge-backend-1erz.onrender.com/api';
  static const String localBaseUrl = 'http://$localIp:3000/api';
  
  // Auth endpoints
  static String get authBaseUrl => useLocalHost ? localBaseUrl : vercelBaseUrl;
  
  // Main API Base URL
  static String get baseUrl => authBaseUrl;
  
  // Upload endpoints
  static String get uploadBaseUrl => useLocalHost ? localBaseUrl : renderBaseUrl;
  
  // Timeout duration
  static const Duration timeout = Duration(seconds: 60);
}

