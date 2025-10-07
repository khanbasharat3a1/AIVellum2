import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final unlockedCount = provider.unlockedPromptsCount;
            final totalCount = provider.totalPrompts;
            final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppConstants.backgroundColor,
                  elevation: 0,
                  title: Text(
                    'Unlock Prompts',
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
                              const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
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

                // AivellumPro Premium Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingXL),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        border: Border.all(color: AppConstants.vaultRed.withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.vaultRed.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppConstants.vaultRed.withOpacity(0.1),
                                  AppConstants.vaultRedLight.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/logoPremium.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Aivellum',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppConstants.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppConstants.vaultRedGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [AppConstants.premiumShadow],
                                ),
                                child: Text(
                                  'PRO',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            'The Ultimate AI Prompts Experience',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.paddingXL),
                          Container(
                            padding: const EdgeInsets.all(AppConstants.paddingL),
                            decoration: BoxDecoration(
                              color: AppConstants.cardColor,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(color: AppConstants.borderColor),
                            ),
                            child: Column(
                              children: [
                                _buildFeature(context, Icons.auto_awesome, 'All Prompts Unlocked Forever', AppConstants.vaultRed),
                                _buildFeature(context, Icons.block, 'Completely Ad-Free', AppConstants.successColor),
                                _buildFeature(context, Icons.security, 'No Tracking or Analytics', AppConstants.infoColor),
                                _buildFeature(context, Icons.update, 'Lifetime Updates', Color(0xFF8B5CF6)),
                                _buildFeature(context, Icons.offline_bolt, 'Full Offline Access', AppConstants.warningColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingXL),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _launchProApp(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.vaultRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingL),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.shopping_bag, size: 20),
                                  const SizedBox(width: AppConstants.paddingS),
                                  Text(
                                    'Get Aivellum Pro',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingXL)),

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
                            padding: const EdgeInsets.all(AppConstants.paddingL),
                            decoration: BoxDecoration(
                              color: AppConstants.surfaceColor,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(color: AppConstants.borderColor),
                              boxShadow: [AppConstants.cardShadow],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.infoColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.payment, color: AppConstants.infoColor, size: 28),
                                ),
                                const SizedBox(height: AppConstants.paddingM),
                                Text(
                                  'Pay per Prompt',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppConstants.paddingXS),
                                Text(
                                  '${provider.getIndividualPromptPrice()} each',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                            padding: const EdgeInsets.all(AppConstants.paddingL),
                            decoration: BoxDecoration(
                              color: AppConstants.surfaceColor,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(color: AppConstants.borderColor),
                              boxShadow: [AppConstants.cardShadow],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.play_circle_outline, color: AppConstants.successColor, size: 28),
                                ),
                                const SizedBox(height: AppConstants.paddingM),
                                Text(
                                  'Watch Ad',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppConstants.paddingXS),
                                Text(
                                  'Free unlock',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

                const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingXL * 2)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingS),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppConstants.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchProApp(BuildContext context) async {
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.khanbasharat.aivellumpro');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Play Store')),
        );
      }
    }
  }
}
