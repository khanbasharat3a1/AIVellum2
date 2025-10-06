import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../models/prompt.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';

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
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
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
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
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
                              icon: Icons.play_circle_outline_rounded,
                              title: 'Watch Ad',
                              subtitle: 'Unlock by watching a short video ad',
                              buttonText: 'Watch Ad',
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
          setState(() => _isUnlocking = false);
          Navigator.pop(context, true);
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
          setState(() => _isUnlocking = false);
          Navigator.pop(context, true);
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