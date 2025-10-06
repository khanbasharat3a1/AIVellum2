import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../models/prompt.dart';

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

                            // Monthly Subscription Option
                            _buildUnlockOption(
                              context: context,
                              icon: Icons.repeat_rounded,
                              title: 'Subscribe ${provider.getMonthlySubscriptionPrice()}',
                              subtitle: 'Unlock all prompts with monthly subscription',
                              buttonText: 'Subscribe',
                              onTap: _unlockWithSubscription,
                              isPrimary: true,
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
    setState(() {
      _isUnlocking = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Check if already unlocked
      if (provider.isPromptUnlocked(widget.prompt.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('This prompt is already unlocked!')),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
        return;
      }
      
      final success = await provider.unlockPromptWithPayment(widget.prompt.id);

      if (!mounted) return;

      if (success) {
        // Wait for purchase to complete and verify unlock
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (provider.isPromptUnlocked(widget.prompt.id)) {
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
          
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // Payment initiated but not completed yet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.pending_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Payment is processing. Please wait...')),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Payment failed or was canceled. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Payment error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }

  Future<void> _unlockWithSubscription() async {
    setState(() {
      _isUnlocking = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // Check if already subscribed
      if (provider.isUserSubscribed) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('You already have an active subscription!')),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
        return;
      }
      
      final success = await provider.purchaseMonthlySubscription();

      if (!mounted) return;

      if (success) {
        // Wait for subscription to activate and verify
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (provider.isUserSubscribed) {
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
          
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // Subscription initiated but not completed yet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.pending_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Subscription is processing. Please wait...')),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Subscription failed or was canceled. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Subscription error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUnlocking = false;
        });
      }
    }
  }
}