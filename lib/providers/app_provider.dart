import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/prompt.dart';
import '../models/user_location.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../services/billing_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/ad_service.dart';
import '../services/database_service.dart';

class AppProvider with ChangeNotifier {
  final DataService _dataService = DataService();
  
  bool _isLoading = true;
  String _error = '';
  int _currentIndex = 0;
  String _searchQuery = '';
  String? _selectedCategoryId;
  UserLocation? _userLocation;
  bool _hasLifetimeAccess = false;
  bool _hasActiveSubscription = false;
  bool _isAdFree = false;

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  int get currentIndex => _currentIndex;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  UserLocation? get userLocation => _userLocation;
  bool get hasLifetimeAccess => _hasLifetimeAccess;
  bool get hasActiveSubscription => _hasActiveSubscription;
  bool get isUserSubscribed => _hasLifetimeAccess || _hasActiveSubscription;
  bool get isAdFree => _isAdFree;
  bool get isSignedIn => AuthService.isSignedIn;
  String? get userEmail => AuthService.currentUser?.email;
  
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

      // Load data and location in parallel
      await Future.wait([
        _dataService.loadData(),
        LocationService.getUserLocation().then((loc) => _userLocation = loc),
        BillingService.initialize(),
      ]);
      
      print('Core services loaded');
      
      // Load user data from Firestore if signed in (in background)
      if (AuthService.isSignedIn) {
        _loadFirestoreData().then((_) => notifyListeners());
      } else {
        _hasLifetimeAccess = BillingService.hasLifetimeAccess;
        _hasActiveSubscription = BillingService.hasActiveSubscription;
      }
      
      // Set purchase callback to refresh UI
      BillingService.setPurchaseCompleteCallback((promptId, isLifetime, isSubscription) async {
        if (promptId == 'error' || promptId == 'canceled' || promptId == 'pending') {
          notifyListeners();
          return;
        }
        
        if (isLifetime) {
          _hasLifetimeAccess = true;
          _isAdFree = true;
          await _dataService.unlockAllPrompts();
          if (AuthService.isSignedIn) {
            await FirestoreService.activateLifetimeAccess(AuthService.userId!);
          }
        } else if (isSubscription) {
          _hasActiveSubscription = true;
          _isAdFree = true;
          await _dataService.unlockAllPrompts();
          if (AuthService.isSignedIn) {
            await FirestoreService.activateSubscription(AuthService.userId!);
          }
        } else {
          await _dataService.unlockPrompt(promptId);
          if (AuthService.isSignedIn) {
            await FirestoreService.unlockPrompt(AuthService.userId!, promptId);
          }
        }
        notifyListeners();
      });
      
      print('Billing service initialized');
      
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

  Future<void> _loadFirestoreData() async {
    final uid = AuthService.userId!;
    
    // Sync local data to cloud
    final localUnlocked = _dataService.getUnlockedPrompts().map((p) => p.id).toList();
    final localFavorites = _dataService.getFavoritePrompts().map((p) => p.id).toList();
    await FirestoreService.syncLocalToCloud(uid, localUnlocked, localFavorites);
    
    // Load cloud data
    _hasLifetimeAccess = await FirestoreService.hasLifetimeAccess(uid);
    _hasActiveSubscription = await FirestoreService.hasActiveSubscription(uid);
    _isAdFree = await FirestoreService.isAdFree(uid);
    
    // Sync unlocked prompts from cloud
    final cloudUnlocked = await FirestoreService.getUnlockedPrompts(uid);
    for (var promptId in cloudUnlocked) {
      if (!_dataService.isPromptUnlocked(promptId)) {
        await _dataService.unlockPrompt(promptId);
      }
    }
    
    // Sync favorites from cloud
    final cloudFavorites = await FirestoreService.getFavoritePrompts(uid);
    for (var promptId in cloudFavorites) {
      if (!_dataService.isPromptFavorite(promptId)) {
        await _dataService.toggleFavorite(promptId);
      }
    }
  }

  Future<void> signInWithGoogle() async {
    final user = await AuthService.signInWithGoogle();
    if (user != null) {
      _isLoading = true;
      notifyListeners();
      
      await _loadFirestoreData();
      
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    
    await AuthService.signOut();
    
    // Clear all subscription data
    _hasLifetimeAccess = false;
    _hasActiveSubscription = false;
    _isAdFree = false;
    
    // Clear local database
    await DatabaseService.clearAllData();
    
    // Force reload data to reset to default state
    await _dataService.loadData();
    
    _isLoading = false;
    notifyListeners();
  }

  // Favorites
  List<Prompt> get favoritePrompts => _dataService.getFavoritePrompts();

  Future<void> toggleFavorite(String promptId) async {
    await _dataService.toggleFavorite(promptId);
    if (AuthService.isSignedIn) {
      final isFav = _dataService.isPromptFavorite(promptId);
      await FirestoreService.toggleFavorite(AuthService.userId!, promptId, isFav);
    }
    notifyListeners();
  }

  // Premium features
  List<Prompt> get unlockedPrompts => _dataService.getUnlockedPrompts();
  
  bool isPromptUnlocked(String promptId) {
    // Check if user has lifetime access or active subscription
    if (isUserSubscribed) {
      return true;
    }
    // Check if specific prompt is unlocked
    return _dataService.isPromptUnlocked(promptId);
  }
  

  Future<bool> unlockPromptWithPayment(String promptId) async {
    if (!AuthService.isSignedIn) return false;
    if (!BillingService.isAvailable) return false;
    
    try {
      final success = await BillingService.purchaseSinglePrompt(promptId);
      if (success) {
        return true;
      }
    } catch (e) {
      print('Payment error: $e');
    }
    return false;
  }

  Future<bool> unlockAllPromptsWithPayment() async {
    if (!AuthService.isSignedIn) return false;
    if (!BillingService.isAvailable) return false;
    
    try {
      final success = await BillingService.purchaseUnlockAll();
      if (success) {
        return true;
      }
    } catch (e) {
      print('Payment error: $e');
    }
    return false;
  }

  Future<bool> purchaseMonthlySubscription() async {
    if (!AuthService.isSignedIn) return false;
    if (!BillingService.isAvailable) return false;
    
    try {
      final success = await BillingService.purchaseMonthlySubscription();
      if (success) {
        return true;
      }
    } catch (e) {
      print('Subscription error: $e');
    }
    return false;
  }

  Future<bool> unlockPromptWithAd(String promptId) async {
    try {
      final rewarded = await AdService.showRewardedAd();
      if (rewarded) {
        await _dataService.unlockPrompt(promptId);
        if (AuthService.isSignedIn) {
          await FirestoreService.unlockPrompt(AuthService.userId!, promptId);
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Ad unlock error: $e');
    }
    return false;
  }

  Future<void> showInterstitialAd() async {
    if (!_isAdFree) {
      await AdService.showInterstitialAd();
    }
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
    if (BillingService.isAvailable) {
      return BillingService.getSinglePromptPrice();
    }
    final pricingData = pricing;
    final currency = pricingData['currency'] ?? '₹';
    final price = pricingData['individual_prompt'] ?? 4;
    return '$currency$price';
  }

  // Get formatted price for lifetime access
  String getLifetimeAccessPrice() {
    if (BillingService.isAvailable) {
      return BillingService.getFormattedPrice();
    }
    final pricingData = pricing;
    final currency = pricingData['currency'] ?? '₹';
    final price = pricingData['lifetime_access'] ?? 999;
    return '$currency$price';
  }

  // Get formatted price (alias for getLifetimeAccessPrice)
  String getFormattedPrice() {
    return getLifetimeAccessPrice();
  }

  // Get monthly subscription price
  String getMonthlySubscriptionPrice() {
    if (BillingService.isAvailable) {
      return BillingService.getMonthlySubscriptionPrice();
    }
    final pricingData = pricing;
    final currency = pricingData['currency'] ?? '₹';
    final price = pricingData['monthly_subscription'] ?? 99;
    return '$currency$price/month';
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    await BillingService.restorePurchases();
    _hasLifetimeAccess = BillingService.hasLifetimeAccess;
    _hasActiveSubscription = BillingService.hasActiveSubscription;
    notifyListeners();
  }
}