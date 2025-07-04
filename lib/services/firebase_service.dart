import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/crystal_collection.dart';
import '../models/journal_entry.dart';
import 'environment_config.dart';

/// Production Firebase Service with real authentication and Firestore integration
/// This is NOT a demo - it provides real user management and data persistence
class FirebaseService {
  final EnvironmentConfig _config;
  String? _currentUserToken;
  String? _currentUserId;
  UserProfile? _currentUser;
  
  FirebaseService({EnvironmentConfig? config}) 
    : _config = config ?? EnvironmentConfig();
  
  // Getters
  bool get isAuthenticated => _currentUserToken != null;
  String? get currentUserId => _currentUserId;
  UserProfile? get currentUser => _currentUser;
  bool get isConfigured => _config.firebaseApiKey.isNotEmpty;
  
  /// Firebase REST API endpoints
  String get _authUrl => 'https://identitytoolkit.googleapis.com/v1/accounts';
  String get _firestoreUrl => 'https://firestore.googleapis.com/v1/projects/${_config.firebaseProjectId}/databases/(default)/documents';
  
  /// Register new user with email and password
  Future<UserProfile> registerUser({
    required String email,
    required String password,
    required String name,
    DateTime? birthDate,
    String? birthTime,
    String? birthLocation,
  }) async {
    if (!isConfigured) {
      throw FirebaseException('Firebase not configured - missing API key');
    }
    
    try {
      // Create authentication account
      final authResponse = await http.post(
        Uri.parse('$_authUrl:signUp?key=${_config.firebaseApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      
      if (authResponse.statusCode != 200) {
        final error = jsonDecode(authResponse.body);
        throw FirebaseException('Registration failed: ${error['error']['message']}');
      }
      
      final authData = jsonDecode(authResponse.body);
      _currentUserToken = authData['idToken'];
      _currentUserId = authData['localId'];
      
      // Create user profile
      final userProfile = UserProfile(
        id: _currentUserId!,
        name: name,
        email: email,
        subscriptionTier: SubscriptionTier.free,
        createdAt: DateTime.now(),
        birthDate: birthDate,
        birthTime: birthTime,
        birthLocation: birthLocation,
      );
      
      // Save user profile to Firestore
      await _saveUserProfile(userProfile);
      _currentUser = userProfile;
      
      return userProfile;
    } catch (e) {
      throw FirebaseException('Registration failed: $e');
    }
  }
  
  /// Sign in existing user
  Future<UserProfile> signInUser({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      throw FirebaseException('Firebase not configured - missing API key');
    }
    
    try {
      final authResponse = await http.post(
        Uri.parse('$_authUrl:signInWithPassword?key=${_config.firebaseApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      
      if (authResponse.statusCode != 200) {
        final error = jsonDecode(authResponse.body);
        throw FirebaseException('Sign in failed: ${error['error']['message']}');
      }
      
      final authData = jsonDecode(authResponse.body);
      _currentUserToken = authData['idToken'];
      _currentUserId = authData['localId'];
      
      // Load user profile from Firestore
      _currentUser = await _loadUserProfile(_currentUserId!);
      
      return _currentUser!;
    } catch (e) {
      throw FirebaseException('Sign in failed: $e');
    }
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    _currentUserToken = null;
    _currentUserId = null;
    _currentUser = null;
  }
  
  /// Save user profile to Firestore
  Future<void> _saveUserProfile(UserProfile profile) async {
    final response = await http.patch(
      Uri.parse('$_firestoreUrl/users/${profile.id}?key=${_config.firebaseApiKey}'),
      headers: {
        'Authorization': 'Bearer $_currentUserToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fields': _mapToFirestoreFields(profile.toJson()),
      }),
    );
    
    if (response.statusCode != 200) {
      throw FirebaseException('Failed to save user profile: ${response.body}');
    }
  }
  
  /// Load user profile from Firestore
  Future<UserProfile> _loadUserProfile(String userId) async {
    final response = await http.get(
      Uri.parse('$_firestoreUrl/users/$userId?key=${_config.firebaseApiKey}'),
      headers: {
        'Authorization': 'Bearer $_currentUserToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fields = _mapFromFirestoreFields(data['fields']);
      return UserProfile.fromJson(fields);
    } else if (response.statusCode == 404) {
      throw FirebaseException('User profile not found');
    } else {
      throw FirebaseException('Failed to load user profile: ${response.body}');
    }
  }
  
  /// Save crystal collection to Firestore
  Future<void> saveCrystalCollection(List<CollectionEntry> collection) async {
    if (!isAuthenticated) {
      throw FirebaseException('User not authenticated');
    }
    
    final batch = collection.map((entry) => {
      'id': entry.id,
      'data': _mapToFirestoreFields(entry.toJson()),
    }).toList();
    
    final response = await http.patch(
      Uri.parse('$_firestoreUrl/users/$_currentUserId/crystals?key=${_config.firebaseApiKey}'),
      headers: {
        'Authorization': 'Bearer $_currentUserToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fields': {
          'collection': {
            'arrayValue': {
              'values': batch.map((item) => {
                'mapValue': {'fields': item['data']}
              }).toList(),
            }
          },
          'lastUpdated': {
            'timestampValue': DateTime.now().toIso8601String(),
          }
        }
      }),
    );
    
    if (response.statusCode != 200) {
      throw FirebaseException('Failed to save crystal collection: ${response.body}');
    }
  }
  
  /// Load crystal collection from Firestore
  Future<List<CollectionEntry>> loadCrystalCollection() async {
    if (!isAuthenticated) {
      throw FirebaseException('User not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$_firestoreUrl/users/$_currentUserId/crystals?key=${_config.firebaseApiKey}'),
      headers: {
        'Authorization': 'Bearer $_currentUserToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['fields'] != null && data['fields']['collection'] != null) {
        final collectionArray = data['fields']['collection']['arrayValue']['values'] as List;
        return collectionArray.map((item) {
          final fields = _mapFromFirestoreFields(item['mapValue']['fields']);
          return CollectionEntry.fromJson(fields);
        }).toList();
      }
      return [];
    } else if (response.statusCode == 404) {
      return []; // No collection yet
    } else {
      throw FirebaseException('Failed to load crystal collection: ${response.body}');
    }
  }
  
  /// Save journal entry to Firestore
  Future<void> saveJournalEntry(JournalEntry entry) async {
    if (!isAuthenticated) {
      throw FirebaseException('User not authenticated');
    }
    
    final response = await http.patch(
      Uri.parse('$_firestoreUrl/users/$_currentUserId/journal/${entry.id}?key=${_config.firebaseApiKey}'),
      headers: {
        'Authorization': 'Bearer $_currentUserToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'fields': _mapToFirestoreFields(entry.toJson()),
      }),
    );
    
    if (response.statusCode != 200) {
      throw FirebaseException('Failed to save journal entry: ${response.body}');
    }
  }
  
  /// Load journal entries from Firestore
  Future<List<JournalEntry>> loadJournalEntries({int limit = 50}) async {
    if (!isAuthenticated) {
      throw FirebaseException('User not authenticated');
    }
    
    final response = await http.get(
      Uri.parse('$_firestoreUrl/users/$_currentUserId/journal?key=${_config.firebaseApiKey}'),
      headers: {
        'Authorization': 'Bearer $_currentUserToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['documents'] != null) {
        final docs = data['documents'] as List;
        return docs.map((doc) {
          final fields = _mapFromFirestoreFields(doc['fields']);
          return JournalEntry.fromJson(fields);
        }).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Latest first
      }
      return [];
    } else if (response.statusCode == 404) {
      return []; // No entries yet
    } else {
      throw FirebaseException('Failed to load journal entries: ${response.body}');
    }
  }
  
  /// Update user subscription tier
  Future<void> updateSubscriptionTier(SubscriptionTier tier) async {
    if (!isAuthenticated || _currentUser == null) {
      throw FirebaseException('User not authenticated');
    }
    
    final updatedUser = _currentUser!.copyWith(subscriptionTier: tier);
    await _saveUserProfile(updatedUser);
    _currentUser = updatedUser;
  }
  
  /// Helper method to convert Dart objects to Firestore field format
  Map<String, dynamic> _mapToFirestoreFields(Map<String, dynamic> data) {
    final fields = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (value == null) return;
      
      if (value is String) {
        fields[key] = {'stringValue': value};
      } else if (value is int) {
        fields[key] = {'integerValue': value.toString()};
      } else if (value is double) {
        fields[key] = {'doubleValue': value};
      } else if (value is bool) {
        fields[key] = {'booleanValue': value};
      } else if (value is DateTime) {
        fields[key] = {'timestampValue': value.toIso8601String()};
      } else if (value is List) {
        fields[key] = {
          'arrayValue': {
            'values': value.map((item) => {
              'stringValue': item.toString(),
            }).toList(),
          }
        };
      } else if (value is Map) {
        fields[key] = {
          'mapValue': {
            'fields': _mapToFirestoreFields(Map<String, dynamic>.from(value)),
          }
        };
      } else {
        fields[key] = {'stringValue': value.toString()};
      }
    });
    
    return fields;
  }
  
  /// Helper method to convert Firestore fields to Dart objects
  Map<String, dynamic> _mapFromFirestoreFields(Map<String, dynamic> fields) {
    final data = <String, dynamic>{};
    
    fields.forEach((key, value) {
      if (value['stringValue'] != null) {
        data[key] = value['stringValue'];
      } else if (value['integerValue'] != null) {
        data[key] = int.parse(value['integerValue']);
      } else if (value['doubleValue'] != null) {
        data[key] = value['doubleValue'];
      } else if (value['booleanValue'] != null) {
        data[key] = value['booleanValue'];
      } else if (value['timestampValue'] != null) {
        data[key] = value['timestampValue'];
      } else if (value['arrayValue'] != null) {
        final array = value['arrayValue']['values'] as List? ?? [];
        data[key] = array.map((item) => item['stringValue'] ?? item.toString()).toList();
      } else if (value['mapValue'] != null) {
        data[key] = _mapFromFirestoreFields(
          Map<String, dynamic>.from(value['mapValue']['fields'] ?? {}),
        );
      }
    });
    
    return data;
  }
  
  /// Check service configuration status
  Map<String, dynamic> getServiceStatus() {
    return {
      'configured': isConfigured,
      'authenticated': isAuthenticated,
      'current_user': _currentUser?.name ?? 'None',
      'project_id': _config.firebaseProjectId,
      'auth_domain': _config.firebaseAuthDomain,
    };
  }
}

/// Exception for Firebase service errors
class FirebaseException implements Exception {
  final String message;
  FirebaseException(this.message);
  
  @override
  String toString() => 'FirebaseException: $message';
}