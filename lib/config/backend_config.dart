import 'package:http/http.dart' as http;
import 'package:crystal_grimoire/services/environment_config.dart';

/// Backend API Configuration for CrystalGrimoire
class BackendConfig {
  // Backend API URL - Using local demo backend
  static String get baseUrl => EnvironmentConfig.instance.baseApiUrl;
  
  // API Endpoints
  static const String identifyEndpoint = '/api/crystal/identify';
  static const String collectionEndpoint = '/api/crystal/collection';
  static const String saveEndpoint = '/api/crystal/save';
  static const String usageEndpoint = '/api/usage';
  
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
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      ).timeout(Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Backend not available: $e');
      return false;
    }
  }
}