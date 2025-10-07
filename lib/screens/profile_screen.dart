import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingXL),
                  decoration: BoxDecoration(
                    gradient: AppConstants.darkGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        child: const Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      Text('Local User', 
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                FutureBuilder<DateTime?>(
                  future: DatabaseService.getSubscriptionEndDate(),
                  builder: (context, snapshot) {
                    final endDate = snapshot.data;
                    final daysLeft = endDate != null ? endDate.difference(DateTime.now()).inDays : 0;
                    
                    return _buildInfoCard(
                      context,
                      'Account Status',
                      [
                        _buildInfoRow(context, 'Subscription', provider.hasActiveSubscription ? 'Active' : 'None', 
                          provider.hasActiveSubscription ? Colors.green : AppConstants.textSecondary),
                        if (provider.hasActiveSubscription && endDate != null)
                          _buildInfoRow(context, 'Expires In', '$daysLeft days', 
                            daysLeft <= 3 ? Colors.orange : Colors.green),
                        _buildInfoRow(context, 'Lifetime Access', provider.hasLifetimeAccess ? 'Yes' : 'No',
                          provider.hasLifetimeAccess ? Colors.green : AppConstants.textSecondary),
                        _buildInfoRow(context, 'Ad-Free', provider.isAdFree ? 'Yes' : 'No',
                          provider.isAdFree ? Colors.green : AppConstants.textSecondary),
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppConstants.paddingM),

                _buildInfoCard(
                  context,
                  'Your Stats',
                  [
                    _buildInfoRow(context, 'Prompts Unlocked', '${provider.unlockedPromptsCount}', AppConstants.primaryColor),
                    _buildInfoRow(context, 'Favorites', '${provider.favoritePromptsCount}', AppConstants.vaultRed),
                    _buildInfoRow(context, 'Total Prompts', '${provider.totalPrompts}', AppConstants.textSecondary),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [AppConstants.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppConstants.paddingM),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: valueColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
