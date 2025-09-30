import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/premium_upgrade_dialog.dart';

class PremiumStatusWidget extends StatelessWidget {
  const PremiumStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.hasLifetimeAccess) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingS,
            ),
            decoration: BoxDecoration(
              gradient: AppConstants.vaultRedGradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              boxShadow: [AppConstants.premiumShadow],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  provider.hasLifetimeAccess ? 'Lifetime' : 'Premium',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return GestureDetector(
          onTap: () => PremiumUpgradeDialog.showUpgradeDialog(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingS,
            ),
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
              border: Border.all(
                color: AppConstants.vaultRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upgrade_rounded,
                  color: AppConstants.vaultRed,
                  size: 16,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  'Upgrade',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppConstants.vaultRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}