import 'package:http/http.dart' as http;

/// Backend API Configuration for CrystalGrimoire
class BackendConfig {
  // Backend API URL - Using local demo backend
  static const String baseUrl = 'http://localhost:8081/api';
  
  // Use backend API if available, otherwise use direct AI
  static const bool useBackend = true;
  
  // DEBUG: Force backend usage for testing
  static const bool FORCE_BACKEND_INTEGRATION = true;
  
  // API Endpoints
  static const String identifyEndpoint = '/crystal/identify';
  static const String collectionEndpoint = '/crystal/collection';
  static const String saveEndpoint = '/crystal/save';
  static const String usageEndpoint = '/usage';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  
  // Headers
  static Map<String, String> get headers => {
    'Accept': 'application/json',
    // Add auth headers when implemented
  };
  
  // Check if backend is available
  static Future<bool> isBackendAvailable() async {
    if (!useBackend) return false;
    
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8081/health'),
        headers: headers,
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Backend not available: $e');
      return false;
    }
  }
}