import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../services/billing_service.dart';

class BillingTestScreen extends StatefulWidget {
  const BillingTestScreen({super.key});

  @override
  State<BillingTestScreen> createState() => _BillingTestScreenState();
}

class _BillingTestScreenState extends State<BillingTestScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Billing Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Billing Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppConstants.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Billing Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      _buildStatusRow('Store Available', BillingService.isAvailable),
                      _buildStatusRow('Lifetime Access', BillingService.hasLifetimeAccess),
                      _buildStatusRow('Products Loaded', BillingService.products.isNotEmpty),
                      const SizedBox(height: AppConstants.paddingM),
                      Text('Products Count: ${BillingService.products.length}'),
                      if (BillingService.products.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.paddingS),
                        ...BillingService.products.map((product) => 
                          Text('${product.id}: ${product.price}')
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                // Test Buttons
                Text(
                  'Test Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),

                // Test Single Purchase
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _testSinglePurchase(provider),
                    child: _isLoading 
                        ? const CircularProgressIndicator()
                        : Text('Test Single Purchase (${provider.getIndividualPromptPrice()})'),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingM),

                // Test Lifetime Purchase
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _testLifetimePurchase(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator()
                        : Text('Test Lifetime Purchase (${provider.getLifetimeAccessPrice()})'),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingM),

                // Restore Purchases
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => _restorePurchases(provider),
                    child: const Text('Restore Purchases'),
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                // Stats
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: AppConstants.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Stats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      Text('Total Prompts: ${provider.totalPrompts}'),
                      Text('Unlocked Prompts: ${provider.unlockedPromptsCount}'),
                      Text('Premium Prompts: ${provider.premiumPromptsCount}'),
                      Text('Free Prompts: ${provider.freePromptsCount}'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Row(
        children: [
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: AppConstants.paddingS),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _testSinglePurchase(AppProvider provider) async {
    setState(() => _isLoading = true);
    
    try {
      // Use the first premium prompt for testing
      final premiumPrompts = provider.prompts.where((p) => p.isPremium && !p.isUnlocked).toList();
      if (premiumPrompts.isEmpty) {
        _showMessage('No locked premium prompts available for testing');
        return;
      }

      final success = await provider.unlockPromptWithPayment(premiumPrompts.first.id);
      _showMessage(success ? 'Purchase initiated successfully!' : 'Purchase failed');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testLifetimePurchase(AppProvider provider) async {
    setState(() => _isLoading = true);
    
    try {
      final success = await provider.unlockAllPromptsWithPayment();
      _showMessage(success ? 'Lifetime purchase initiated successfully!' : 'Purchase failed');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases(AppProvider provider) async {
    setState(() => _isLoading = true);
    
    try {
      await provider.restorePurchases();
      _showMessage('Purchases restored successfully!');
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}