import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/prompt.dart';
import 'database_service.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Category> _categories = [];
  List<Prompt> _prompts = [];
  Map<String, dynamic> _pricing = {};
  Map<String, dynamic> _appConfig = {};
  bool _hasLifetimeAccess = false;
  bool _hasActiveSubscription = false;

  List<Category> get categories => _categories;
  List<Prompt> get prompts => _prompts;
  Map<String, dynamic> get pricing => _pricing;
  Map<String, dynamic> get appConfig => _appConfig;

  Future<void> loadData() async {
    try {
      print('Loading data from assets...');
      final String jsonString = await rootBundle.loadString('assets/data/prompts_database.json');
      print('JSON loaded, length: ${jsonString.length}');
      
      final Map<String, dynamic> data = json.decode(jsonString);
      print('JSON parsed successfully');
      
      // Load subscription status
      _hasLifetimeAccess = await DatabaseService.hasLifetimeAccess();
      _hasActiveSubscription = await DatabaseService.hasActiveSubscription();

      if (data['categories'] != null) {
        _categories = (data['categories'] as List)
            .map((json) => Category.fromJson(json))
            .toList();
        print('Categories loaded: ${_categories.length}');
      }

      if (data['prompts'] != null) {
        _prompts = (data['prompts'] as List)
            .map((json) => Prompt.fromJson(json))
            .toList();
        print('Prompts loaded: ${_prompts.length}');
      }

      _pricing = data['pricing'] ?? {};
      _appConfig = data['app_config'] ?? {};
      print('Pricing and config loaded');

      await _loadUserData();
      print('User data loaded successfully');
    } catch (e) {
      print('Error loading data: $e');
      // Initialize with empty data to prevent crashes
      _categories = [];
      _prompts = [];
      _pricing = {};
      _appConfig = {};
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> _loadUserData() async {
    // Load favorites from database service
    final favorites = await DatabaseService.getFavoritePrompts();
    for (var prompt in _prompts) {
      prompt.isFavorite = favorites.contains(prompt.id);
    }

    // Check for lifetime access and active subscription
    _hasLifetimeAccess = await DatabaseService.hasLifetimeAccess();
    _hasActiveSubscription = await DatabaseService.hasActiveSubscription();
    
    // Load unlocked prompts from database service
    final unlocked = await DatabaseService.getUnlockedPrompts();
    for (var prompt in _prompts) {
      if (!prompt.isPremium) {
        // Free prompts are always unlocked
        prompt.isUnlocked = true;
      } else if (_hasLifetimeAccess || _hasActiveSubscription) {
        // Premium prompts unlocked if user has subscription
        prompt.isUnlocked = true;
      } else {
        // Premium prompts unlocked only if individually purchased
        prompt.isUnlocked = unlocked.contains(prompt.id);
      }
    }

    // Increment session count
    await DatabaseService.incrementSessionCount();
  }

  List<Prompt> getPromptsByCategory(String categoryId) {
    return _prompts.where((prompt) => prompt.categoryId == categoryId).toList();
  }

  List<Prompt> getFavoritePrompts() {
    return _prompts.where((prompt) => prompt.isFavorite).toList();
  }

  List<Prompt> getUnlockedPrompts() {
    return _prompts.where((prompt) => prompt.isUnlocked).toList();
  }

  List<Prompt> searchPrompts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _prompts.where((prompt) {
      return prompt.title.toLowerCase().contains(lowercaseQuery) ||
             prompt.description.toLowerCase().contains(lowercaseQuery) ||
             prompt.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<void> toggleFavorite(String promptId) async {
    await DatabaseService.toggleFavorite(promptId);
    
    final prompt = _prompts.firstWhere((p) => p.id == promptId);
    prompt.isFavorite = await DatabaseService.isPromptFavorite(promptId);
  }

  bool isPromptFavorite(String promptId) {
    try {
      final prompt = _prompts.firstWhere((p) => p.id == promptId);
      return prompt.isFavorite;
    } catch (e) {
      return false;
    }
  }

  Future<void> unlockPrompt(String promptId) async {
    await DatabaseService.unlockPrompt(promptId);
    
    final prompt = _prompts.firstWhere((p) => p.id == promptId);
    prompt.isUnlocked = true;
    
    // Refresh subscription status
    _hasLifetimeAccess = await DatabaseService.hasLifetimeAccess();
    _hasActiveSubscription = await DatabaseService.hasActiveSubscription();
  }

  Future<void> unlockAllPrompts() async {
    await DatabaseService.unlockAllPromptsLifetime();
    
    for (var prompt in _prompts) {
      prompt.isUnlocked = true;
    }
    
    // Refresh subscription status
    _hasLifetimeAccess = await DatabaseService.hasLifetimeAccess();
    _hasActiveSubscription = await DatabaseService.hasActiveSubscription();
  }

  int getFreePromptsCount() {
    return _prompts.where((prompt) => !prompt.isPremium).length;
  }

  int getPremiumPromptsCount() {
    return _prompts.where((prompt) => prompt.isPremium).length;
  }

  int getUnlockedPromptsCount() {
    return _prompts.where((prompt) => prompt.isUnlocked).length;
  }

  Future<bool> hasLifetimeAccess() async {
    return await DatabaseService.hasLifetimeAccess();
  }

  bool isPromptUnlocked(String promptId) {
    // Check if user has lifetime access or active subscription
    final hasLifetime = _hasLifetimeAccess;
    final hasSubscription = _hasActiveSubscription;
    
    if (hasLifetime || hasSubscription) {
      return true;
    }
    
    // Check if specific prompt is unlocked
    try {
      final prompt = _prompts.firstWhere((p) => p.id == promptId);
      // Free prompts are always unlocked
      if (!prompt.isPremium) {
        return true;
      }
      return prompt.isUnlocked;
    } catch (e) {
      return false;
    }
  }
}