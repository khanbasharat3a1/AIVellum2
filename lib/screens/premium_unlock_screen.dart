import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../models/prompt.dart';
import '../services/ads_service.dart';

class PremiumUnlockScreen extends StatefulWidget {
  final Prompt prompt;

  const PremiumUnlockScreen({
    super.key,
    required this.prompt,
  });

  @override
  State<PremiumUnlockScreen> createState() => _PremiumUnlockScreenState();
}

class _PremiumUnlockScreenState extends State<PremiumUnlockScreen> {
  bool _isUnlocking = false;

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
          body: Padding(
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

                        // Watch Ad Option
                        _buildUnlockOption(
                          context: context,
                          icon: Icons.play_circle_outline_rounded,
                          title: 'Watch an Ad',
                          subtitle: 'Free unlock by watching a short video ad',
                          buttonText: 'Watch Ad',
                          onTap: _unlockWithAd,
                          isPrimary: true,
                        ),

                        const SizedBox(height: AppConstants.paddingM),

                        // Payment Option
                        _buildUnlockOption(
                          context: context,
                          icon: Icons.payment_rounded,
                          title: 'Pay ${provider.getIndividualPromptPrice()}',
                          subtitle: 'Instant unlock with secure payment',
                          buttonText: 'Pay Now',
                          onTap: _unlockWithPayment,
                          isPrimary: false,
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

  Future<void> _unlockWithAd() async {
    setState(() {
      _isUnlocking = true;
    });

    try {
      // Check ad limits first
      final canShow = await AdsService.canShowRewardedAd();
      if (!canShow) {
        final limitMessage = await AdsService.getAdLimitMessage();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(limitMessage ?? 'Ad not available right now.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final provider = Provider.of<AppProvider>(context, listen: false);
      final success = await provider.unlockPromptWithAd(widget.prompt.id);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prompt unlocked successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad not available. Please try again later.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  Future<void> _unlockWithPayment() async {
    setState(() {
      _isUnlocking = true;
    });

    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final success = await provider.unlockPromptWithPayment(widget.prompt.id);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Purchase successful! Prompt unlocked.'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Wait a moment for the purchase to process, then close
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Payment not available. Please try watching an ad instead.'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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