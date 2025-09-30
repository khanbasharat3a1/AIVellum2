import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final pricing = provider.pricing;
            final unlockedCount = provider.unlockedPromptsCount;
            final totalCount = provider.totalPrompts;
            final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppConstants.backgroundColor,
                  elevation: 0,
                  title: Text(
                    'Premium',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Progress Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      decoration: BoxDecoration(
                        gradient: AppConstants.darkGradient,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: AppConstants.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Progress',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$unlockedCount of $totalCount prompts unlocked',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 8,
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            '${(progress * 100).toInt()}% Complete',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Lifetime Access Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        border: Border.all(
                          color: AppConstants.primaryColor.withOpacity(0.3), // Use vault red border for premium card
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppConstants.paddingS),
                                decoration: BoxDecoration(
                                  gradient: AppConstants.vaultRedGradient,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                ),
                                child: const Icon(
                                  Icons.all_inclusive,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lifetime Access',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Unlock all prompts forever',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          
                          // Features List
                          ...const [
                            '✨ Access to all premium prompts',
                            '🚀 New prompts added weekly',
                            '📱 Works across all devices',
                            '💡 Priority customer support',
                            '🎯 Advanced filtering & search',
                          ].map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                            child: Row(
                              children: [
                                Text(
                                  feature.split(' ')[0],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: AppConstants.paddingS),
                                Expanded(
                                  child: Text(
                                    feature.substring(feature.indexOf(' ') + 1),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          
                          const SizedBox(height: AppConstants.paddingL),
                          
                          // Pricing
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.getLifetimeAccessPrice(),
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor, // Use vault red for pricing
                                    ),
                                  ),
                                  Text(
                                    'One-time payment',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  _showPurchaseDialog(context, provider);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingXL,
                                    vertical: AppConstants.paddingM,
                                  ),
                                ),
                                child: const Text('Unlock All'),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppConstants.paddingM),
                          
                          // Restore Purchases Button
                          Center(
                            child: TextButton.icon(
                              onPressed: () => _restorePurchases(context, provider),
                              icon: const Icon(Icons.restore_rounded),
                              label: const Text('Restore Purchases'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppConstants.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingL)),

                // Monthly Subscription Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        border: Border.all(
                          color: AppConstants.vaultRed.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.vaultRed.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppConstants.paddingS),
                                decoration: BoxDecoration(
                                  gradient: AppConstants.vaultRedGradient,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                ),
                                child: const Icon(
                                  Icons.repeat,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppConstants.paddingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly Subscription',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Unlimited access with monthly billing',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          
                          // Features List
                          ...const [
                            '✨ Access to all premium prompts',
                            '🔄 Auto-renewal every month',
                            '📱 Works across all devices',
                            '💡 New prompts added weekly',
                            '🎯 Advanced filtering & search',
                          ].map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
                            child: Row(
                              children: [
                                Text(
                                  feature.split(' ')[0],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: AppConstants.paddingS),
                                Expanded(
                                  child: Text(
                                    feature.substring(feature.indexOf(' ') + 1),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          
                          const SizedBox(height: AppConstants.paddingL),
                          
                          // Pricing
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    provider.getMonthlySubscriptionPrice(),
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.vaultRed,
                                    ),
                                  ),
                                  Text(
                                    'Billed monthly',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppConstants.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  _showSubscriptionDialog(context, provider);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppConstants.vaultRed,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.paddingXL,
                                    vertical: AppConstants.paddingM,
                                  ),
                                ),
                                child: const Text('Subscribe'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingL)),

                // Individual Unlock Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Text(
                      'Or unlock individual prompts',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingM)),

                // Individual Pricing Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppConstants.paddingM),
                            decoration: BoxDecoration(
                              color: AppConstants.surfaceColor,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.payment,
                                  color: AppConstants.primaryColor, // Use vault red for payment icon
                                  size: 32,
                                ),
                                const SizedBox(height: AppConstants.paddingS),
                                Text(
                                  'Pay per Prompt',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingXS),
                                Text(
                                  '${provider.getIndividualPromptPrice()} each',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppConstants.paddingM),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(AppConstants.paddingM),
                            decoration: BoxDecoration(
                              color: AppConstants.surfaceColor,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  color: AppConstants.successColor,
                                  size: 32,
                                ),
                                const SizedBox(height: AppConstants.paddingS),
                                Text(
                                  'Watch Ad',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppConstants.paddingXS),
                                Text(
                                  'Free unlock',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingXL)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock All Prompts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will unlock all premium prompts for lifetime access.'),
            const SizedBox(height: 16),
            Text(
              'Price: ${provider.getLifetimeAccessPrice()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Continue with purchase?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text('Processing purchase...'),
                    ],
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
              
              final success = await provider.unlockAllPromptsWithPayment();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Purchase initiated! All prompts will unlock once payment is confirmed.'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Payment not available. Please try again later or unlock individual prompts.'),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  Future<void> _restorePurchases(BuildContext context, AppProvider provider) async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 8),
            Text('Restoring purchases...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      await provider.restorePurchases();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Purchases restored successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to restore purchases: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSubscriptionDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscribe to Premium'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will activate your monthly subscription and unlock all premium prompts.'),
            const SizedBox(height: 16),
            Text(
              'Price: ${provider.getMonthlySubscriptionPrice()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Your subscription will auto-renew monthly. Continue with subscription?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text('Processing subscription...'),
                    ],
                  ),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
              
              final success = await provider.purchaseMonthlySubscription();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Subscription initiated! All prompts will unlock once payment is confirmed.'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Subscription not available. Please try again later.'),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Subscribe'),
          ),
        ],
      ),
    );
  }
}