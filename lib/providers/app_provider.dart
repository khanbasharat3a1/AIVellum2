import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/prompt.dart';
import '../models/user_location.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../services/ads_service.dart';

class AppProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  
  bool _isLoading = true;
  String _error = '';
  int _currentIndex = 0;
  String _searchQuery = '';
  String? _selectedCategoryId;
  UserLocation? _userLocation;
  bool _hasLifetimeAccess = false;

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentIndex => _currentIndex;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  UserLocation? get userLocation => _userLocation;
  bool get hasLifetimeAccess => _hasLifetimeAccess;
  
  List<Category> get categories => _dataService.categories;
  List<Prompt> get prompts => _dataService.prompts;
  Map<String, dynamic> get pricing {
    final allPricing = _dataService.pricing;
    if (_userLocation?.isIndia == true) {
      return allPricing['india'] ?? {};
    } else {
      return allPricing['international'] ?? {};
    }
  }
  Map<String, dynamic> get appConfig => _dataService.appConfig;

  // Initialize app data
  Future<void> initialize() async {
    try {
      print('Initializing app...');
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Load user location first
      _userLocation = await LocationService.getUserLocation();
      print('User location: ${_userLocation?.countryName}');

      await _dataService.loadData();
      print('Data service loaded successfully');
      
      // Initialize ads
      AdsService.initialize();
      print('Ads service initialized');
      
      _isLoading = false;
      notifyListeners();
      print('App initialization completed');
    } catch (e) {
      print('App initialization error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Navigation
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Prompt> getSearchResults() {
    if (_searchQuery.isEmpty) return [];
    return _dataService.searchPrompts(_searchQuery);
  }

  // Category filtering
  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  List<Prompt> getPromptsByCategory(String categoryId) {
    return _dataService.getPromptsByCategory(categoryId);
  }

  List<Prompt> getFeaturedPrompts() {
    if (prompts.isEmpty) return [];
    
    final List<Prompt> featured = [];
    
    // First, add some premium prompts from money_making (most popular category)
    final moneyMakingPrompts = prompts.where((p) => p.categoryId == 'money_making').toList();
    if (moneyMakingPrompts.isNotEmpty) {
      featured.addAll(moneyMakingPrompts.take(2));
    }
    
    // Add some content creation prompts
    final contentPrompts = prompts.where((p) => p.categoryId == 'content_creation').toList();
    if (contentPrompts.isNotEmpty) {
      featured.addAll(contentPrompts.take(1));
    }
    
    // Add business strategy prompts
    final businessPrompts = prompts.where((p) => p.categoryId == 'business_strategy').toList();
    if (businessPrompts.isNotEmpty) {
      featured.addAll(businessPrompts.take(1));
    }
    
    // Add freelancing prompts
    final freelancingPrompts = prompts.where((p) => p.categoryId == 'freelancing').toList();
    if (freelancingPrompts.isNotEmpty) {
      featured.addAll(freelancingPrompts.take(1));
    }
    
    // Add writing prompts
    final writingPrompts = prompts.where((p) => p.categoryId == 'writing').toList();
    if (writingPrompts.isNotEmpty) {
      featured.addAll(writingPrompts.take(1));
    }
    
    // Add marketing prompts
    final marketingPrompts = prompts.where((p) => p.categoryId == 'marketing_sales').toList();
    if (marketingPrompts.isNotEmpty) {
      featured.addAll(marketingPrompts.take(1));
    }
    
    // If we still don't have enough, add more from any category
    if (featured.length < 8) {
      final remaining = prompts.where((p) => !featured.contains(p)).take(8 - featured.length);
      featured.addAll(remaining);
    }
    
    // Shuffle for variety and return up to 8 prompts
    featured.shuffle();
    return featured.take(8).toList();
  }

  // Favorites
  List<Prompt> get favoritePrompts => _dataService.getFavoritePrompts();

  Future<void> toggleFavorite(String promptId) async {
    await _dataService.toggleFavorite(promptId);
    notifyListeners();
  }

  // Premium features
  List<Prompt> get unlockedPrompts => _dataService.getUnlockedPrompts();
  
  Future<bool> unlockPromptWithAd(String promptId) async {
    if (AdsService.isRewardedAdReady) {
      final success = await AdsService.showRewardedAd();
      if (success) {
        await _dataService.unlockPrompt(promptId);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<bool> unlockPromptWithPayment(String promptId) async {
    // TODO: Implement actual payment
    // For now, show coming soon message
    return false;
  }

  Future<bool> unlockAllPromptsWithPayment() async {
    // TODO: Implement actual payment
    // For now, show coming soon message
    return false;
  }

  // Statistics
  int get totalPrompts => prompts.length;
  int get freePromptsCount => _dataService.getFreePromptsCount();
  int get premiumPromptsCount => _dataService.getPremiumPromptsCount();
  int get unlockedPromptsCount => _dataService.getUnlockedPromptsCount();
  int get favoritePromptsCount => favoritePrompts.length;

  // Get prompts by difficulty
  List<Prompt> getPromptsByDifficulty(String difficulty) {
    return prompts.where((p) => p.difficulty == difficulty).toList();
  }

  // Get category by ID
  Category? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get prompt by ID
  Prompt? getPromptById(String promptId) {
    try {
      return prompts.firstWhere((p) => p.id == promptId);
    } catch (e) {
      return null;
    }
  }

  // Get formatted price for individual prompt
  String getIndividualPromptPrice() {
    final pricingData = pricing;
    final currency = pricingData['currency'] ?? '\$';
    final price = pricingData['individual_prompt'] ?? 0.05;
    return '$currency$price';
  }

  // Get formatted price for lifetime access
  String getLifetimeAccessPrice() {
    final pricingData = pricing;
    final currency = pricingData['currency'] ?? '\$';
    final price = pricingData['lifetime_access'] ?? 12.99;
    return '$currency$price';
  }
}