import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../screens/premium_screen.dart';

class PremiumUpgradeDialog extends StatelessWidget {
  final bool showOnStartup;
  
  const PremiumUpgradeDialog({
    super.key,
    this.showOnStartup = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            decoration: BoxDecoration(
              gradient: AppConstants.vaultRedGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.vaultRed.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Icon
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingL),
                
                // Title
                Text(
                  showOnStartup ? 'Welcome to Aivellum!' : 'Upgrade to Premium',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingM),
                
                // Description
                Text(
                  showOnStartup 
                    ? 'Unlock the full power of AI with premium prompts designed by experts.'
                    : 'Get unlimited access to all premium AI prompts and boost your productivity.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingL),
                
                // Features
                ...const [
                  '🚀 Access to 100+ premium prompts',
                  '💡 New prompts added weekly',
                  '⚡ Unlimited usage',
                  '🎯 Expert-crafted content',
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
                const SizedBox(height: AppConstants.paddingL),
                
                // Pricing Options
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Monthly',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            provider.getFormattedPrice(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Cancel anytime',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Lifetime',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            provider.getLifetimeAccessPrice(),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'One-time payment',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.paddingL),
                
                // Action Buttons
                Row(
                  children: [
                    if (!showOnStartup)
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.8),
                          ),
                          child: const Text('Maybe Later'),
                        ),
                      ),
                    if (!showOnStartup) const SizedBox(width: AppConstants.paddingM),
                    Expanded(
                      flex: showOnStartup ? 1 : 2,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PremiumScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppConstants.vaultRed,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          ),
                        ),
                        child: Text(
                          showOnStartup ? 'Explore Premium' : 'Upgrade Now',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (showOnStartup) ...[
                  const SizedBox(height: AppConstants.paddingM),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.8),
                    ),
                    child: const Text('Continue with Free Version'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static void showUpgradeDialog(BuildContext context, {bool showOnStartup = false}) {
    showDialog(
      context: context,
      barrierDismissible: !showOnStartup,
      builder: (context) => PremiumUpgradeDialog(showOnStartup: showOnStartup),
    );
  }
}