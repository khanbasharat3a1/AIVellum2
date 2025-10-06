import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'database_service.dart';
import '../constants/billing_constants.dart';

class BillingService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static final Set<String> _ids = {
    BillingConstants.unlockAllPromptsId,
    BillingConstants.unlockSinglePromptId,
    BillingConstants.premiumMonthlyId,
  };
  
  static List<ProductDetails> products = [];
  static bool _isAvailable = false;
  static bool _hasLifetimeAccess = false;
  static bool _hasActiveSubscription = false;
  static late StreamSubscription<List<PurchaseDetails>> _subscription;
  static String? _pendingPromptId;
  static Function(String promptId, bool isLifetime, bool isSubscription)? _onPurchaseComplete;

  static bool get isAvailable => _isAvailable;
  static bool get hasLifetimeAccess => _hasLifetimeAccess;
  static bool get hasActiveSubscription => _hasActiveSubscription;
  static bool get isUserSubscribed => _hasLifetimeAccess || _hasActiveSubscription;
  
  static void setPurchaseCompleteCallback(Function(String promptId, bool isLifetime, bool isSubscription)? callback) {
    _onPurchaseComplete = callback;
  }

  static Future<void> initialize() async {
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      print('Store not available - this is normal in debug mode');
      return;
    }

    try {
      await initStore();
      listenPurchases();
      _hasLifetimeAccess = await DatabaseService.hasLifetimeAccess();
      _hasActiveSubscription = await DatabaseService.hasActiveSubscription();
    } catch (e) {
      print('Billing initialization error: $e');
      print('This is expected until app is uploaded to Play Console');
    }
  }

  static Future<void> initStore() async {
    final response = await _iap.queryProductDetails(_ids);
    products = response.productDetails;
    
    print('Products loaded: ${products.length}');
    for (var product in products) {
      print('Product: ${product.id} - ${product.title} - ${product.price}');
    }
    
    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }
  }

  static void listenPurchases() {
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        print('Purchase status: ${purchase.status} for ${purchase.productID}');
        
        if (purchase.status == PurchaseStatus.purchased) {
          print('Processing purchase: ${purchase.productID}');
          
          // Unlock content FIRST before completing purchase
          if (purchase.productID == BillingConstants.unlockAllPromptsId) {
            _unlockAllPrompts();
          } else if (purchase.productID == BillingConstants.unlockSinglePromptId) {
            final promptId = _pendingPromptId ?? 'fallback';
            _unlockSinglePrompt(promptId);
            _pendingPromptId = null;
          } else if (purchase.productID == BillingConstants.premiumMonthlyId) {
            _activateSubscription();
          }
          
          // Complete purchase AFTER unlocking to ensure content is available
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          
        } else if (purchase.status == PurchaseStatus.error) {
          print('Purchase error: ${purchase.error}');
          _pendingPromptId = null;
          _onPurchaseComplete?.call('error', false, false);
        } else if (purchase.status == PurchaseStatus.canceled) {
          print('Purchase canceled: ${purchase.productID}');
          _pendingPromptId = null;
          _onPurchaseComplete?.call('canceled', false, false);
        } else if (purchase.status == PurchaseStatus.pending) {
          print('Purchase pending: ${purchase.productID}');
          _onPurchaseComplete?.call('pending', false, false);
        }
      }
    });
  }





  static Future<bool> purchaseUnlockAll() async {
    if (!_isAvailable || products.isEmpty) {
      print('Store not available or no products loaded');
      return false;
    }

    try {
      final product = products.firstWhere(
        (p) => p.id == BillingConstants.unlockAllPromptsId,
        orElse: () => throw Exception('Product not found'),
      );
      
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  static Future<bool> purchaseSinglePrompt(String promptId) async {
    if (!_isAvailable || products.isEmpty) {
      print('Store not available or no products loaded');
      return false;
    }

    try {
      final product = products.firstWhere(
        (p) => p.id == BillingConstants.unlockSinglePromptId,
        orElse: () => throw Exception('Product not found'),
      );
      
      _pendingPromptId = promptId;
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('Purchase error: $e');
      _pendingPromptId = null;
      return false;
    }
  }

  static Future<bool> purchaseMonthlySubscription() async {
    if (!_isAvailable || products.isEmpty) {
      print('Store not available or no products loaded');
      return false;
    }

    try {
      final product = products.firstWhere(
        (p) => p.id == BillingConstants.premiumMonthlyId,
        orElse: () => throw Exception('Product not found'),
      );
      
      final purchaseParam = PurchaseParam(productDetails: product);
      // Use buyNonConsumable for auto-renewable subscriptions on both platforms
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('Subscription purchase error: $e');
      return false;
    }
  }



  static Future<void> _unlockAllPrompts() async {
    try {
      // Mark all prompts as unlocked in database
      await DatabaseService.unlockAllPromptsLifetime();
      _hasLifetimeAccess = true;
      print('All prompts unlocked in database');
      
      // Notify listeners that purchase was successful
      _onPurchaseComplete?.call('all', true, false);
    } catch (e) {
      print('Error unlocking all prompts: $e');
    }
  }

  static Future<void> _unlockSinglePrompt(String promptId) async {
    try {
      // Mark single prompt as unlocked in database
      await DatabaseService.unlockPrompt(promptId);
      print('Prompt $promptId unlocked in database');
      
      // Notify listeners that purchase was successful
      _onPurchaseComplete?.call(promptId, false, false);
    } catch (e) {
      print('Error unlocking single prompt: $e');
    }
  }

  static Future<void> _activateSubscription() async {
    try {
      // Mark subscription as active in database
      await DatabaseService.activateSubscription();
      _hasActiveSubscription = true;
      print('Monthly subscription activated in database');
      
      // Notify listeners that subscription was successful
      _onPurchaseComplete?.call('subscription', false, true);
    } catch (e) {
      print('Error activating subscription: $e');
    }
  }



  static String getFormattedPrice() {
    if (products.isEmpty) return '₹999';
    
    try {
      final product = products.firstWhere((p) => p.id == BillingConstants.unlockAllPromptsId);
      return product.price;
    } catch (e) {
      return '₹999';
    }
  }

  static String getSinglePromptPrice() {
    if (products.isEmpty) return '₹4';
    
    try {
      final product = products.firstWhere((p) => p.id == BillingConstants.unlockSinglePromptId);
      return product.price;
    } catch (e) {
      return '₹4';
    }
  }

  static String getMonthlySubscriptionPrice() {
    if (products.isEmpty) return '₹99/month';
    
    try {
      final product = products.firstWhere((p) => p.id == BillingConstants.premiumMonthlyId);
      return product.price;
    } catch (e) {
      return '₹99/month';
    }
  }

  static Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _iap.restorePurchases();
      // Refresh subscription status after restore
      _hasLifetimeAccess = await DatabaseService.hasLifetimeAccess();
      _hasActiveSubscription = await DatabaseService.hasActiveSubscription();
    } catch (e) {
      print('Restore purchases error: $e');
    }
  }

  static void dispose() {
    _subscription.cancel();
  }
}