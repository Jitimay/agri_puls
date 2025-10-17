/// API Configuration for AgriPulse
/// 
/// IMPORTANT: Update the IP address below to match your backend server
class ApiConfig {
  // TODO: Replace with your actual backend IP address
  // Example: 'http://192.168.1.100:5001/api' or 'http://10.0.2.2:5001/api' for Android emulator
  static const String baseUrl = 'http://192.168.138.1:5001/api';
  
  // Timeout for API requests
  static const Duration timeout = Duration(seconds: 10);
  
  // API endpoints
  static const String dashboardEndpoint = '/dashboard';
  static const String regionsEndpoint = '/regions';
  static const String aiAskEndpoint = '/ai/ask';
}