import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  static const String _unlockedPromptsKey = 'unlocked_prompts';
  static const String _favoritePromptsKey = 'favorite_prompts';
  static const String _userStatsKey = 'user_stats';
  static const String _lifetimeAccessKey = 'lifetime_access';
  static const String _activeSubscriptionKey = 'active_subscription';
  static const String _subscriptionStartDateKey = 'subscription_start_date';

  // Unlocked prompts management
  static Future<Set<String>> getUnlockedPrompts() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedJson = prefs.getString(_unlockedPromptsKey);
    if (unlockedJson != null) {
      final List<dynamic> unlockedList = json.decode(unlockedJson);
      return unlockedList.cast<String>().toSet();
    }
    return <String>{};
  }

  static Future<void> unlockPrompt(String promptId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await getUnlockedPrompts();
    unlocked.add(promptId);
    await prefs.setString(_unlockedPromptsKey, json.encode(unlocked.toList()));
    
    // Update stats
    await _updateStats('prompts_unlocked', unlocked.length);
  }

  static Future<void> unlockAllPrompts(List<String> allPromptIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unlockedPromptsKey, json.encode(allPromptIds));
    
    // Update stats
    await _updateStats('prompts_unlocked', allPromptIds.length);
  }

  static Future<void> unlockAllPromptsLifetime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lifetimeAccessKey, true);
    
    // Update stats
    await _updateStats('lifetime_access_purchased', true);
    await _updateStats('purchase_date', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> hasLifetimeAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lifetimeAccessKey) ?? false;
  }

  static Future<void> activateSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activeSubscriptionKey, true);
    await prefs.setInt(_subscriptionStartDateKey, DateTime.now().millisecondsSinceEpoch);
    
    // Update stats
    await _updateStats('subscription_activated', true);
    await _updateStats('subscription_start_date', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<bool> hasActiveSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool(_activeSubscriptionKey) ?? false;
    
    if (isActive) {
      // Check if subscription is still valid (not expired)
      final startDate = prefs.getInt(_subscriptionStartDateKey) ?? 0;
      final subscriptionDate = DateTime.fromMillisecondsSinceEpoch(startDate);
      final now = DateTime.now();
      final daysSinceStart = now.difference(subscriptionDate).inDays;
      
      // For monthly subscription, check if it's been less than 30 days
      if (daysSinceStart >= 30) {
        // Subscription expired, deactivate it
        await deactivateSubscription();
        return false;
      }
    }
    
    return isActive;
  }

  static Future<void> deactivateSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_activeSubscriptionKey, false);
    await prefs.remove(_subscriptionStartDateKey);
    
    // Update stats
    await _updateStats('subscription_deactivated', true);
  }

  static Future<bool> isUserSubscribed() async {
    final hasLifetime = await hasLifetimeAccess();
    final hasSubscription = await hasActiveSubscription();
    return hasLifetime || hasSubscription;
  }

  static Future<bool> isPromptUnlocked(String promptId) async {
    final unlocked = await getUnlockedPrompts();
    return unlocked.contains(promptId);
  }

  // Favorite prompts management
  static Future<Set<String>> getFavoritePrompts() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritePromptsKey);
    if (favoritesJson != null) {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList.cast<String>().toSet();
    }
    return <String>{};
  }

  static Future<void> toggleFavorite(String promptId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoritePrompts();
    
    if (favorites.contains(promptId)) {
      favorites.remove(promptId);
    } else {
      favorites.add(promptId);
    }
    
    await prefs.setString(_favoritePromptsKey, json.encode(favorites.toList()));
    
    // Update stats
    await _updateStats('favorites_count', favorites.length);
  }

  static Future<bool> isPromptFavorite(String promptId) async {
    final favorites = await getFavoritePrompts();
    return favorites.contains(promptId);
  }


  // User statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_userStatsKey);
    if (statsJson != null) {
      return json.decode(statsJson);
    }
    return {
      'prompts_unlocked': 0,
      'favorites_count': 0,
      'total_sessions': 0,
      'first_launch': DateTime.now().millisecondsSinceEpoch,
      'last_active': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<void> _updateStats(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await getUserStats();
    stats[key] = value;
    stats['last_active'] = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString(_userStatsKey, json.encode(stats));
  }

  static Future<void> incrementSessionCount() async {
    final stats = await getUserStats();
    final currentSessions = stats['total_sessions'] ?? 0;
    await _updateStats('total_sessions', currentSessions + 1);
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedPromptsKey);
    await prefs.remove(_favoritePromptsKey);
    await prefs.remove(_userStatsKey);
    await prefs.remove(_lifetimeAccessKey);
  }

  // Backup and restore
  static Future<Map<String, dynamic>> exportUserData() async {
    return {
      'unlocked_prompts': (await getUnlockedPrompts()).toList(),
      'favorite_prompts': (await getFavoritePrompts()).toList(),
      'user_stats': await getUserStats(),
      'lifetime_access': await hasLifetimeAccess(),
      'export_timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  static Future<void> importUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (data['unlocked_prompts'] != null) {
      await prefs.setString(_unlockedPromptsKey, json.encode(data['unlocked_prompts']));
    }
    
    if (data['favorite_prompts'] != null) {
      await prefs.setString(_favoritePromptsKey, json.encode(data['favorite_prompts']));
    }
    
    if (data['user_stats'] != null) {
      await prefs.setString(_userStatsKey, json.encode(data['user_stats']));
    }
    
    
    if (data['lifetime_access'] != null) {
      await prefs.setBool(_lifetimeAccessKey, data['lifetime_access']);
    }
  }
}