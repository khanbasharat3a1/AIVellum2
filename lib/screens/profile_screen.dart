import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';

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
          if (!AuthService.isSignedIn) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline, size: 80, color: AppConstants.textTertiary),
                    const SizedBox(height: AppConstants.paddingL),
                    Text('Not Signed In', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppConstants.paddingS),
                    Text('Sign in to sync your data and purchases', 
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppConstants.textSecondary)),
                    const SizedBox(height: AppConstants.paddingXL),
                    ElevatedButton.icon(
                      onPressed: () => _signIn(context, provider),
                      icon: const Icon(Icons.login),
                      label: const Text('Sign In with Google'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final user = AuthService.currentUser!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              children: [
                // Profile Header
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
                        backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                        child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
                      ),
                      const SizedBox(height: AppConstants.paddingM),
                      Text(user.displayName ?? 'User', 
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppConstants.paddingXS),
                      Text(user.email ?? '', 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingL),

                // Account Status
                _buildInfoCard(
                  context,
                  'Account Status',
                  [
                    _buildInfoRow(context, 'Subscription', provider.hasActiveSubscription ? 'Active' : 'None', 
                      provider.hasActiveSubscription ? Colors.green : AppConstants.textSecondary),
                    _buildInfoRow(context, 'Lifetime Access', provider.hasLifetimeAccess ? 'Yes' : 'No',
                      provider.hasLifetimeAccess ? Colors.green : AppConstants.textSecondary),
                    _buildInfoRow(context, 'Ad-Free', provider.isAdFree ? 'Yes' : 'No',
                      provider.isAdFree ? Colors.green : AppConstants.textSecondary),
                  ],
                ),

                const SizedBox(height: AppConstants.paddingM),

                // Stats
                _buildInfoCard(
                  context,
                  'Your Stats',
                  [
                    _buildInfoRow(context, 'Prompts Unlocked', '${provider.unlockedPromptsCount}', AppConstants.primaryColor),
                    _buildInfoRow(context, 'Favorites', '${provider.favoritePromptsCount}', AppConstants.vaultRed),
                    _buildInfoRow(context, 'Total Prompts', '${provider.totalPrompts}', AppConstants.textSecondary),
                  ],
                ),

                const SizedBox(height: AppConstants.paddingXL),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _signOut(context, provider),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red.shade300),
                      foregroundColor: Colors.red,
                    ),
                  ),
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

  void _signIn(BuildContext context, AppProvider provider) async {
    await provider.signInWithGoogle();
    if (AuthService.isSignedIn && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${AuthService.currentUser?.displayName ?? "User"}!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _signOut(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signed out successfully'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
