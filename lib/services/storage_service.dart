import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/birth_chart.dart';

class StorageService {
  static const String _birthChartKey = 'birth_chart';
  static const String _subscriptionKey = 'subscription_tier';
  static const String _aiProviderKey = 'ai_provider';
  static const String _usageKey = 'usage_stats';
  static const String _foundersAccountKey = 'founders_account_enabled';
  static const String _metaphysicalQueriesKey = 'metaphysical_queries';
  static const String _queryDateKey = 'query_date';
  static const String _userProfileKey = 'user_profile';
  
  bool _isInitialized = false;
  
  // Birth Chart
  static Future<void> saveBirthChart(Map<String, dynamic> chartData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_birthChartKey, json.encode(chartData));
  }
  
  static Future<Map<String, dynamic>?> getBirthChart() async {
    final prefs = await SharedPreferences.getInstance();
    final chartString = prefs.getString(_birthChartKey);
    if (chartString != null) {
      return json.decode(chartString) as Map<String, dynamic>;
    }
    return null;
  }
  
  static Future<void> deleteBirthChart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_birthChartKey);
  }
  
  // Subscription
  static Future<void> saveSubscriptionTier(String tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_subscriptionKey, tier);
  }
  
  static Future<String> getSubscriptionTier() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subscriptionKey) ?? 'free';
  }
  
  // AI Provider
  static Future<void> saveAIProvider(String provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aiProviderKey, provider);
  }
  
  static Future<String> getAIProvider() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_aiProviderKey) ?? 'gemini';
  }
  
  // Usage Statistics
  static Future<void> saveUsageStats(Map<String, dynamic> stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usageKey, json.encode(stats));
  }
  
  static Future<Map<String, dynamic>> getUsageStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsString = prefs.getString(_usageKey);
    if (statsString != null) {
      return json.decode(statsString) as Map<String, dynamic>;
    }
    return {
      'identifications': 0,
      'lastReset': DateTime.now().toIso8601String(),
    };
  }
  
  static Future<void> incrementIdentifications() async {
    final stats = await getUsageStats();
    stats['identifications'] = (stats['identifications'] as int) + 1;
    await saveUsageStats(stats);
  }

  static Future<int> getDailyIdentifications() async {
    final stats = await getUsageStats();
    return stats['identifications'] as int? ?? 0;
  }
  
  static Future<void> resetMonthlyUsage() async {
    await saveUsageStats({
      'identifications': 0,
      'lastReset': DateTime.now().toIso8601String(),
    });
  }
  
  // Founders Account Management
  static Future<void> enableFoundersAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_foundersAccountKey, true);
    // Automatically upgrade to founders tier
    await saveSubscriptionTier('founders');
  }
  
  static Future<bool> isFoundersAccountEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_foundersAccountKey) ?? false;
  }
  
  static Future<void> disableFoundersAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_foundersAccountKey, false);
    // Revert to free tier
    await saveSubscriptionTier('free');
  }
  
  // Metaphysical Query Tracking
  static Future<int> getDailyMetaphysicalQueries() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD
    final lastQueryDate = prefs.getString(_queryDateKey) ?? '';
    
    if (lastQueryDate != today) {
      // Reset counter for new day
      await prefs.setInt(_metaphysicalQueriesKey, 0);
      await prefs.setString(_queryDateKey, today);
      return 0;
    }
    
    return prefs.getInt(_metaphysicalQueriesKey) ?? 0;
  }
  
  static Future<void> incrementMetaphysicalQueries() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = await getDailyMetaphysicalQueries();
    await prefs.setInt(_metaphysicalQueriesKey, currentCount + 1);
  }
  
  static Future<bool> canMakeMetaphysicalQuery() async {
    final subscriptionTier = await getSubscriptionTier();
    final currentQueries = await getDailyMetaphysicalQueries();
    
    switch (subscriptionTier) {
      case 'free':
        return false; // No metaphysical queries for free tier
      case 'premium':
        return false; // Premium doesn't have metaphysical queries
      case 'pro':
        return currentQueries < 5; // 5 queries per day for pro
      case 'founders':
        return true; // Unlimited for founders
      default:
        return false;
    }
  }
  
  static Future<int> getMetaphysicalQueryLimit() async {
    final subscriptionTier = await getSubscriptionTier();
    
    switch (subscriptionTier) {
      case 'pro':
        return 5;
      case 'founders':
        return -1; // Unlimited
      default:
        return 0; // No access
    }
  }
  
  // Clear all user data (for logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Check if user has seen onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_seen_onboarding') ?? false;
  }
  
  // Mark onboarding as seen
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  }
  
  // Initialize service (for non-static usage)
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }
  
  // User Profile Management
  UserProfile? getUserProfile() {
    // For now, return null - could load from shared preferences
    return null;
  }
  
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, json.encode(profile.toJson()));
  }
  
  Future<UserProfile?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_userProfileKey);
    if (profileString != null) {
      try {
        return UserProfile.fromJson(json.decode(profileString));
      } catch (e) {
        print('Error loading user profile: $e');
        return null;
      }
    }
    return null;
  }
  
  // Birth Chart Management (non-static)
  BirthChart? getBirthChartInstance() {
    // For now, return null - could load from shared preferences
    return null;
  }
  
  Future<void> saveBirthChartInstance(BirthChart chart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_birthChartKey, json.encode(chart.toJson()));
  }
  
  Future<BirthChart?> loadBirthChart() async {
    final prefs = await SharedPreferences.getInstance();
    final chartString = prefs.getString(_birthChartKey);
    if (chartString != null) {
      try {
        return BirthChart.fromJson(json.decode(chartString));
      } catch (e) {
        print('Error loading birth chart: $e');
        return null;
      }
    }
    return null;
  }
}