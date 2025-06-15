import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart'; // Import Uuid package
import '../config/backend_config.dart';
import '../models/crystal.dart';
import '../models/birth_chart.dart';
import '../models/crystal_collection.dart';
import 'platform_file.dart';
import 'storage_service.dart';

/// Service for communicating with the CrystalGrimoire backend
class BackendService {
  static String? _authToken;
  static String? _userId;
  
  /// Check if user is authenticated
  static bool get isAuthenticated => _authToken != null;
  
  /// Get current user ID
  static String? get currentUserId => _userId;
  
  /// Set authentication token
  static void setAuth(String token, String userId) {
    _authToken = token;
    _userId = userId;
  }
  
  /// Clear authentication
  static void clearAuth() {
    _authToken = null;
    _userId = null;
  }
  
  /// Get headers with auth if available
  static Map<String, String> get _headers {
    final headers = BackendConfig.headers;
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
  
  /// Register a new user
  static Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl}/api/auth/register'),
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setAuth(data['access_token'], data['user_id']);
        return {
          'success': true,
          'user_id': data['user_id'],
          'email': data['email'],
          'token': data['access_token'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
  
  /// Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl}/api/auth/login'),
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setAuth(data['access_token'], data['user_id']);
        return {
          'success': true,
          'user_id': data['user_id'],
          'email': data['email'],
          'subscription_tier': data['subscription_tier'],
          'token': data['access_token'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
  
  /// Identify crystal using backend API
  static Future<CrystalIdentification> identifyCrystal({
    required List<PlatformFile> images,
    String? userContext,
    String? sessionId,
  }) async {
    try {
      // Check if backend is available
      if (!await BackendConfig.isBackendAvailable()) {
        throw Exception('Backend not available');
      }
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.identifyEndpoint}'),
      );
      
      // Add headers
      request.headers.addAll(_headers);
      
      // Add images
      for (int i = 0; i < images.length; i++) {
        final imageBytes = await images[i].readAsBytes();
        final imageFile = http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: images[i].name.isNotEmpty ? images[i].name : 'crystal_$i.jpg',
        );
        request.files.add(imageFile);
      }
      
      // Add other fields
      request.fields['description'] = userContext ?? '';
      if (sessionId != null) {
        request.fields['session_id'] = sessionId;
      }
      
      // Add birth chart context if available
      final birthChartData = await StorageService.getBirthChart();
      if (birthChartData != null) {
        final birthChart = BirthChart.fromJson(birthChartData);
        final spiritualContext = birthChart.getSpiritualContext();
        
        // Add astrological context to the request
        request.fields['astrological_context'] = jsonEncode({
          'sun_sign': spiritualContext['sunSign'],
          'moon_sign': spiritualContext['moonSign'],
          'ascendant': spiritualContext['ascendant'],
          'dominant_elements': spiritualContext['dominantElements'],
          'recommended_crystals': spiritualContext['recommendations'],
        });
      }
      
      final streamedResponse = await request.send().timeout(BackendConfig.uploadTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseBackendResponse(data);
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required');
      } else if (response.statusCode == 429) {
        throw Exception('Monthly identification limit reached. Upgrade for unlimited access.');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Identification failed');
      }
    } catch (e) {
      throw Exception('Backend crystal identification failed: $e');
    }
  }
  
  /// Identify crystal anonymously (for testing without auth)
  static Future<CrystalIdentification> identifyCrystalAnonymous({
    required List<PlatformFile> images,
    String? userContext,
    String? sessionId,
  }) async {
    throw UnsupportedError('Anonymous crystal identification is not supported by the current backend.');
  }
  
  /// Get user's crystal collection
  static Future<List<Crystal>> getUserCollection() async {
    if (!isAuthenticated || _userId == null) {
      throw Exception('Authentication required');
    }
    
    try {
      final response = await http.get(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.collectionEndpoint}/$_userId'), // Ensure this matches requirement
        headers: _headers,
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final crystals = <Crystal>[];
        
        for (final crystalData in data['crystals']) {
          crystals.add(_parseBackendCrystal(crystalData));
        }
        
        return crystals;
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load collection');
      }
    } catch (e) {
      throw Exception('Failed to get user collection: $e');
    }
  }
  
  /// Save crystal to user collection
  static Future<bool> saveCrystal(String crystalId, {String notes = ''}) async {
    if (!isAuthenticated) {
      throw Exception('Authentication required');
    }
    
    try {
      final response = await http.post(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.saveEndpoint}'),
        headers: _headers,
        body: {
          'crystal_id': crystalId,
          'notes': notes,
        },
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to save crystal');
      }
    } catch (e) {
      throw Exception('Failed to save crystal: $e');
    }
  }
  
  /// Get usage statistics
  static Future<Map<String, dynamic>> getUsageStats() async {
    if (!isAuthenticated || _userId == null) {
      throw Exception('Authentication required');
    }
    
    try {
      final response = await http.get(
        Uri.parse('${BackendConfig.baseUrl}${BackendConfig.usageEndpoint}/$_userId'), // Ensure this matches requirement
        headers: _headers,
      ).timeout(BackendConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        clearAuth();
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load usage stats');
      }
    } catch (e) {
      throw Exception('Failed to get usage stats: $e');
    }
  }
  
  /// Parse backend response into CrystalIdentification
  static CrystalIdentification _parseBackendResponse(Map<String, dynamic> data) {
    final String identificationId = data['identification_id'] as String? ?? Uuid().v4();
    final Map<String, dynamic>? crystalDetails = data['crystal_details'] as Map<String, dynamic>?;
    final String rawLLMResponse = data['identification_raw'] as String? ?? data['identification'] as String? ?? 'No raw identification data provided.';

    String name = "Identified Crystal";
    String description = rawLLMResponse;
    String scientificName = '';
    String group = 'Unknown';
    List<String> chakras = [];
    List<String> elements = [];
    Map<String, dynamic> properties = {};
    String careInstructions = '';
    String mysticalMessage = '';

    if (crystalDetails != null) {
      name = crystalDetails['name'] as String? ?? name;
      description = crystalDetails['description'] as String? ?? description;
      scientificName = crystalDetails['scientific_name'] as String? ?? scientificName;
      group = crystalDetails['group'] as String? ?? group;

      if (crystalDetails['chakras'] is List) {
        chakras = List<String>.from(crystalDetails['chakras'].map((e) => e.toString()));
      }
      if (crystalDetails['elements'] is List) {
        elements = List<String>.from(crystalDetails['elements'].map((e) => e.toString()));
      }
      // Backend might send 'healing_applications' or a nested 'properties' map
      if (crystalDetails['properties'] is Map) {
        properties = Map<String, dynamic>.from(crystalDetails['properties'] as Map);
      } else if (crystalDetails['healing_applications'] is List) {
        properties['healing'] = List<String>.from(crystalDetails['healing_applications'].map((e) => e.toString()));
      } else if (crystalDetails['metaphysical_properties'] is List) { // another common key
         properties['metaphysical'] = List<String>.from(crystalDetails['metaphysical_properties'].map((e) => e.toString()));
      }

      careInstructions = crystalDetails['care_instructions'] as String? ?? careInstructions;
      mysticalMessage = crystalDetails['spiritual_message'] as String? ?? mysticalMessage;

      // If description in crystal_details is still the full raw response, try to get a shorter one.
      if (description == rawLLMResponse && name != "Identified Crystal" && name.isNotEmpty) {
          // This logic is a bit speculative, if the name is the first line of rawLLMResponse,
          // and description is also rawLLMResponse, it means parsing didn't separate them.
          // We prefer a shorter description if possible, or leave it as the full text.
          // For now, if name is parsed, and description is still the full text, it's acceptable.
      }

    } else {
      // Fallback if crystal_details is not present - try to get name from raw response
      final lines = rawLLMResponse.split('\n');
      if (lines.isNotEmpty && lines.first.length < 100) { // Avoid overly long first lines as name
        name = lines.first.trim();
      }
      // Description remains rawLLMResponse
    }

    final crystal = Crystal(
      id: identificationId,
      name: name,
      scientificName: scientificName,
      group: group,
      description: description,
      chakras: chakras,
      elements: elements,
      properties: properties,
      careInstructions: careInstructions,
    );
    
    return CrystalIdentification(
      sessionId: data['session_id'] as String? ?? '',
      crystal: crystal,
      confidence: _parseConfidence(0.7), // Default confidence
      mysticalMessage: mysticalMessage,
      fullResponse: rawLLMResponse,
      timestamp: data['timestamp'] != null ? DateTime.parse(data['timestamp'] as String) : DateTime.now(),
      needsMoreInfo: data['needs_more_info'] as bool? ?? false, // Default, not in current backend response
      suggestedAngles: List<String>.from((data['suggested_angles'] as List<dynamic>?)?.map((e) => e.toString()) ?? []), // Default
      observedFeatures: List<String>.from((data['observed_features'] as List<dynamic>?)?.map((e) => e.toString()) ?? []), // Default
    );
  }
  
  /// Parse backend crystal data
  static Crystal _parseBackendCrystal(Map<String, dynamic> data) {
    // This is for parsing crystals from the collection.
    // unified_backend.py's collection endpoint is a TODO.
    // For now, ensure it doesn't crash if called.
    // If data structure is unknown, make it return a Crystal object with placeholder data.
    return Crystal(
      id: data['id'] as String? ?? Uuid().v4(),
      name: data['crystal_name'] as String? ?? 'Unknown Crystal',
      scientificName: data['scientific_name'] as String? ?? '',
      group: data['group'] as String? ?? 'Unknown',
      description: data['description'] as String? ?? (data['full_response'] as String? ?? ''),
      chakras: (data['chakras'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      elements: (data['elements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      properties: (data['properties'] as Map<String,dynamic>?) ?? {},
      careInstructions: data['care_instructions'] as String? ?? '',
    );
  }
  
  /// Get personalized spiritual guidance using LLM integration
  static Future<Map<String, dynamic>> getPersonalizedGuidance({
    required String guidanceType,
    required Map<String, dynamic> userProfile,
    required String customPrompt,
  }) async {
    try {
      final uri = Uri.parse('${BackendConfig.baseUrl}/api/guidance/personalized'); // Updated URL
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      // Use _headers which includes auth token
      request.headers.addAll(_headers);
      
      // Add form fields
      request.fields['guidance_type'] = guidanceType;
      request.fields['user_profile'] = jsonEncode(userProfile);
      request.fields['custom_prompt'] = customPrompt;
      
      print('🔮 Requesting personalized guidance: $guidanceType');
      
      final streamedResponse = await request.send().timeout(BackendConfig.apiTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✨ Received personalized guidance');
        return data;
      } else {
        print('❌ Guidance request failed: ${response.statusCode}');
        throw Exception('Failed to get personalized guidance: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting personalized guidance: $e');
      // Return fallback guidance
      return {
        'guidance': _getFallbackGuidance(guidanceType),
        'source': 'fallback',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Fallback guidance when LLM service is unavailable
  static String _getFallbackGuidance(String guidanceType) {
    switch (guidanceType) {
      case 'daily':
        return "Beloved seeker, today is a perfect day to connect with your crystal allies. Hold your favorite crystal in meditation and set a clear intention for the day ahead. Trust your intuition to guide you.";
      case 'crystal_selection':
        return "Look within your collection and notice which crystal calls to you most strongly today. That crystal has a message for you - listen with your heart.";
      case 'chakra_balancing':
        return "Begin with grounding at your root chakra, then slowly work your way up, spending time with each energy center. Use crystals that resonate with each chakra's frequency.";
      case 'lunar_guidance':
        return "The moon's energy flows through all crystals. Tonight, place your stones under the night sky to absorb lunar vibrations and cleanse any stagnant energy.";
      default:
        return "Take time today to connect with your spiritual practice. Your crystals are here to support and guide you on your journey of growth and discovery.";
    }
  }

  /// Parse confidence string to double
  static double _parseConfidence(dynamic confidence) {
    if (confidence is double) return confidence;
    if (confidence is int) return confidence.toDouble();
    if (confidence is String) {
      switch (confidence.toLowerCase()) {
        case 'high': return 0.9;
        case 'medium': return 0.7;
        case 'low': return 0.5;
        default: return 0.7;
      }
    }
    return 0.7;
  }
}