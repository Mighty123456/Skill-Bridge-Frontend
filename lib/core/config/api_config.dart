class ApiConfig {
  // SET THIS TO TRUE FOR LOCAL TESTING, FALSE FOR PRODUCTION (Vercel/Render)
  static const bool useLocalHost = false;

  // Local IPs: 
  // 10.0.2.2 for Android Emulator (Default)
  // 127.0.0.1 or localhost for iOS Emulator, Web, or Windows
  // Use your PC's IP (e.g., 192.168.1.5) for Physical Devices
  static const String localIp = '10.0.2.2'; 
  
  // Base URLs
  static const String vercelBaseUrl = 'https://skill-bridge-backend-delta.vercel.app/api';
  static const String renderBaseUrl = 'https://skill-bridge-backend-1erz.onrender.com/api';
  static const String localBaseUrl = 'http://$localIp:3000/api';
  
  // Auth endpoints (Vercel)
  static String get authBaseUrl => useLocalHost ? localBaseUrl : vercelBaseUrl;
  
  // Main API Base URL (Vercel)
  static String get baseUrl => authBaseUrl;
  
  // Upload endpoints (Render)
  static String get uploadBaseUrl => useLocalHost ? localBaseUrl : renderBaseUrl;

  // Socket URL (Render) - No /api suffix
  static String get socketUrl => useLocalHost ? 'http://$localIp:3000' : 'https://skill-bridge-backend-1erz.onrender.com';
  
  // Timeout duration
  static const Duration timeout = Duration(minutes: 2);
}

