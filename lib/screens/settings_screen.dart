import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import 'billing_test_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppConstants.backgroundColor,
                  elevation: 0,
                  title: Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Profile Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingL),
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.paddingL),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppConstants.primaryColor,
                            AppConstants.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 32,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome to ${AppConstants.appName}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${provider.unlockedPromptsCount}/${provider.totalPrompts} prompts unlocked',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Settings Sections
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Section
                        _buildSectionTitle(context, 'App'),
                        _buildSettingsCard(
                          context,
                          [
                            _buildSettingsTile(
                              context,
                              icon: Icons.share,
                              title: 'Share App',
                              subtitle: 'Tell your friends about ${AppConstants.appName}',
                              onTap: () => _shareApp(),
                            ),
                            _buildSettingsTile(
                              context,
                              icon: Icons.star_rate,
                              title: 'Rate App',
                              subtitle: 'Rate us on the Play Store',
                              onTap: () => _rateApp(),
                            ),
                            _buildSettingsTile(
                              context,
                              icon: Icons.feedback,
                              title: 'Feedback',
                              subtitle: 'Send us your feedback',
                              onTap: () => _sendFeedback(),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.paddingL),

                        // Support Section
                        _buildSectionTitle(context, 'Support'),
                        _buildSettingsCard(
                          context,
                          [
                            _buildSettingsTile(
                              context,
                              icon: Icons.help_outline,
                              title: 'Help & FAQ',
                              subtitle: 'Get help and find answers',
                              onTap: () => _openHelp(),
                            ),
                            _buildSettingsTile(
                              context,
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'Read our privacy policy',
                              onTap: () => _openPrivacyPolicy(),
                            ),
                            _buildSettingsTile(
                              context,
                              icon: Icons.description_outlined,
                              title: 'Terms of Service',
                              subtitle: 'Read our terms of service',
                              onTap: () => _openTerms(),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.paddingL),

                        // Developer Section (only show in debug mode)
                        if (AppConstants.isDebugMode) ...[
                          _buildSectionTitle(context, 'Developer'),
                          _buildSettingsCard(
                            context,
                            [
                              _buildSettingsTile(
                                context,
                                icon: Icons.payment,
                                title: 'Billing Test',
                                subtitle: 'Test Google Play billing functionality',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BillingTestScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                        ],

                        // About Section
                        _buildSectionTitle(context, 'About'),
                        _buildSettingsCard(
                          context,
                          [
                            _buildSettingsTile(
                              context,
                              icon: Icons.info_outline,
                              title: 'App Version',
                              subtitle: 'Version 1.1.0',
                              showArrow: false,
                            ),
                            _buildSettingsTile(
                              context,
                              icon: Icons.code,
                              title: 'Developer',
                              subtitle: 'Built with ❤️ by AIVELLUM team for AI enthusiasts',
                              showArrow: false,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.paddingXL),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.paddingS,
        bottom: AppConstants.paddingS,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppConstants.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppConstants.paddingS),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
        child: Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppConstants.textSecondary,
        ),
      ),
      trailing: showArrow
          ? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppConstants.textTertiary,
            )
          : null,
      onTap: onTap,
    );
  }

  void _shareApp() {
    Share.share(
      'Check out ${AppConstants.appName} - Premium AI Prompts Vault! '
      'Get access to hundreds of high-quality AI prompts for creators and entrepreneurs. '
      'Download now: https://play.google.com/store/apps/details?id=${AppConstants.packageName}',
      subject: 'Check out ${AppConstants.appName}!',
    );
  }

  void _rateApp() {
    launchUrl(
      Uri.parse('https://play.google.com/store/apps/details?id=${AppConstants.packageName}'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _sendFeedback() {
    launchUrl(
      Uri.parse('mailto:khanbasharat3a1@gmail.com?subject=Feedback for ${AppConstants.appName}'),
    );
  }

  void _openHelp() {
    launchUrl(
      Uri.parse('https://www.khanbasharat.com/p/about-us-aivellum.html'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openPrivacyPolicy() {
    launchUrl(
      Uri.parse('https://www.khanbasharat.com/p/privacy-policy-aivellum.html'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openTerms() {
    launchUrl(
      Uri.parse('https://www.khanbasharat.com/p/terms-and-conditions-aivellum.html'),
      mode: LaunchMode.externalApplication,
    );
  }
}