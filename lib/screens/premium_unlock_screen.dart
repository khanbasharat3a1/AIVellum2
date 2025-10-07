import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../models/prompt.dart';
import '../services/ad_service.dart';

class PremiumUnlockScreen extends StatefulWidget {
  final Prompt prompt;

  const PremiumUnlockScreen({
    super.key,
    required this.prompt,
  });

  @override
  State<PremiumUnlockScreen> createState() => _PremiumUnlockScreenState();
}

class _PremiumUnlockScreenState extends State<PremiumUnlockScreen> with TickerProviderStateMixin {
  bool _isUnlocking = false;
  RewardedAd? _rewardedAd;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _loadRewardedAd() async {
    _rewardedAd = await AdService.loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppConstants.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Unlock Premium Prompt',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Prompt Preview
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppConstants.paddingL),
                              decoration: BoxDecoration(
                                gradient: AppConstants.vaultRedGradient,
                                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                boxShadow: [AppConstants.premiumShadow],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(AppConstants.paddingS),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                        ),
                                        child: const Icon(
                                          Icons.auto_awesome_rounded,
                                          color: AppConstants.textOnDark,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: AppConstants.paddingS),
                                      Expanded(
                                        child: Text(
                                          widget.prompt.title,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: AppConstants.textOnDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppConstants.paddingM),
                                  Text(
                                    widget.prompt.description,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppConstants.textOnDark.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppConstants.paddingXL),

                            // Unlock Options
                            Text(
                              'Choose how to unlock this premium prompt:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingL),

                            // AivellumPro Option
                            _buildProOption(context),

                            const SizedBox(height: AppConstants.paddingM),

                            // Individual Payment Option
                            _buildUnlockOption(
                              context: context,
                              icon: Icons.payment_rounded,
                              title: 'Pay ${provider.getIndividualPromptPrice()}',
                              subtitle: 'Instant unlock with secure payment',
                              buttonText: 'Pay Now',
                              onTap: _unlockWithPayment,
                              isPrimary: false,
                            ),

                            const SizedBox(height: AppConstants.paddingM),

                            // Watch Ad Option
                            _buildUnlockOption(
                              context: context,
                              icon: Icons.play_circle_outline,
                              title: 'Watch Ad',
                              subtitle: 'Unlock this prompt for free',
                              buttonText: 'Watch',
                              onTap: _unlockWithAd,
                              isPrimary: false,
                            ),

                            const SizedBox(height: AppConstants.paddingM),

                            // Monthly Subscription Option (only if not subscribed)
                            if (!provider.isUserSubscribed)
                              _buildUnlockOption(
                                context: context,
                                icon: Icons.repeat_rounded,
                                title: 'Subscribe ${provider.getMonthlySubscriptionPrice()}',
                                subtitle: 'Unlock all prompts with monthly subscription',
                                buttonText: 'Subscribe',
                                onTap: _unlockWithSubscription,
                                isPrimary: true,
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(AppConstants.paddingL),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    const SizedBox(width: AppConstants.paddingM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            provider.hasLifetimeAccess ? 'Lifetime Access Active' : 'Subscription Active',
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const SizedBox(height: AppConstants.paddingXS),
                                          Text(
                                            provider.hasLifetimeAccess 
                                                ? 'You have unlimited access to all prompts'
                                                : 'All prompts are unlocked with your subscription',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Note
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(
                          color: AppConstants.borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppConstants.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Expanded(
                            child: Text(
                              'Once unlocked, you\'ll have permanent access to this prompt.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppConstants.textSecondary,
                              ),
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
        );
      },
    );
  }

  Widget _buildUnlockOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: isPrimary ? AppConstants.vaultRed.withOpacity(0.3) : AppConstants.borderColor,
        ),
        boxShadow: isPrimary ? [AppConstants.premiumShadow.copyWith(blurRadius: 10)] : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: BoxDecoration(
              color: isPrimary ? AppConstants.vaultRed.withOpacity(0.1) : AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              icon,
              color: isPrimary ? AppConstants.vaultRed : AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXS),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          ElevatedButton(
            onPressed: _isUnlocking ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? AppConstants.vaultRed : AppConstants.primaryColor,
              foregroundColor: AppConstants.textOnDark,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingL,
                vertical: AppConstants.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: _isUnlocking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppConstants.textOnDark),
                    ),
                  )
                : Text(buttonText),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockWithPayment() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    if (!AuthService.isSignedIn) {
      _showAuthRequired();
      return;
    }

    if (provider.isPromptUnlocked(widget.prompt.id)) {
      if (mounted) Navigator.pop(context, true);
      return;
    }

    setState(() => _isUnlocking = true);

    try {
      final success = await provider.unlockPromptWithPayment(widget.prompt.id);

      if (!mounted) return;

      if (success) {
        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          // Show success animation
          _scaleController.forward();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Successful!',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Prompt unlocked and ready to use',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          
          // Wait for smooth transition
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          setState(() => _isUnlocking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment canceled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUnlocking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildProOption(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppConstants.vaultRed.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppConstants.vaultRed.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.vaultRed.withOpacity(0.1),
                      AppConstants.vaultRedLight.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset('assets/images/logoPremium.png', width: 32, height: 32),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Aivellum',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppConstants.vaultRedGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [AppConstants.premiumShadow],
                          ),
                          child: Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All prompts • Ad-free • No tracking',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _openProApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.vaultRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Get Pro Version',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProApp() async {
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.khanbasharat.aivellumpro');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _unlockWithAd() async {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad not ready. Please try again.')),
      );
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        await provider.unlockPromptWithAd(widget.prompt.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prompt unlocked!'),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
    );
    _rewardedAd = null;
  }

  Future<void> _unlockWithSubscription() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    if (!AuthService.isSignedIn) {
      _showAuthRequired();
      return;
    }

    if (provider.isUserSubscribed) {
      if (mounted) Navigator.pop(context, true);
      return;
    }

    setState(() => _isUnlocking = true);

    try {
      final success = await provider.purchaseMonthlySubscription();

      if (!mounted) return;

      if (success) {
        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          // Show success animation
          _scaleController.forward();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subscription Activated!',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'All premium prompts are now unlocked',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          
          // Wait for smooth transition
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } else {
        if (mounted) {
          setState(() => _isUnlocking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription canceled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUnlocking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unlockWithAd() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    setState(() => _isUnlocking = true);

    try {
      final success = await provider.unlockPromptWithAd(widget.prompt.id);

      if (!mounted) return;

      if (success) {
        // Wait for state to update
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          setState(() => _isUnlocking = false);
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          setState(() => _isUnlocking = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad not available'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUnlocking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAuthRequired() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }
}