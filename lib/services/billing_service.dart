import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'database_service.dart';
import '../constants/billing_constants.dart';

class BillingService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static final Set<String> _ids = {
    BillingConstants.unlockAllPromptsId,
    BillingConstants.unlockSinglePromptId,
  };
  
  static List<ProductDetails> products = [];
  static bool _isAvailable = false;
  static bool _hasLifetimeAccess = false;
  static late StreamSubscription<List<PurchaseDetails>> _subscription;
  static String? _pendingPromptId;

  static bool get isAvailable => _isAvailable;
  static bool get hasLifetimeAccess => _hasLifetimeAccess;

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
        if (purchase.status == PurchaseStatus.purchased) {
          print('Purchased: ${purchase.productID}');
          if (purchase.productID == BillingConstants.unlockAllPromptsId) {
            _unlockAllPrompts();
          } else if (purchase.productID == BillingConstants.unlockSinglePromptId && _pendingPromptId != null) {
            _unlockSinglePrompt(_pendingPromptId!);
            _pendingPromptId = null;
          }
          
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
        } else if (purchase.status == PurchaseStatus.error) {
          print('Purchase error: ${purchase.error}');
          _pendingPromptId = null;
        } else if (purchase.status == PurchaseStatus.canceled) {
          print('Purchase canceled: ${purchase.productID}');
          _pendingPromptId = null;
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



  static Future<void> _unlockAllPrompts() async {
    // Mark all prompts as unlocked in database
    await DatabaseService.unlockAllPromptsLifetime();
    _hasLifetimeAccess = true;
    print('All prompts unlocked in database');
  }

  static Future<void> _unlockSinglePrompt(String promptId) async {
    // Mark single prompt as unlocked in database
    await DatabaseService.unlockPrompt(promptId);
    print('Prompt $promptId unlocked in database');
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

  static Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    try {
      await _iap.restorePurchases();
    } catch (e) {
      print('Restore purchases error: $e');
    }
  }

  static void dispose() {
    _subscription.cancel();
  }
}