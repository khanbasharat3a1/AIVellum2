import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/pro_promotion_dialog.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    await Future.delayed(const Duration(milliseconds: 800));
    await appProvider.initialize();
    
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 1200));
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
      _showProPromotionIfNeeded();
    }
  }

  Future<void> _showProPromotionIfNeeded() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getInt('pro_dialog_last_shown') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceLastShown = (now - lastShown) / (1000 * 60 * 60 * 24);

    if (daysSinceLastShown >= 2 || lastShown == 0) {
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const ProPromotionDialog(),
        );
        await prefs.setInt('pro_dialog_last_shown', now);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.surfaceColor,
              AppConstants.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo Container
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppConstants.vaultRedGradient,
                              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                              boxShadow: [
                                AppConstants.premiumShadow,
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 60,
                              height: 60,
                              color: AppConstants.textOnDark,
                            ),
                          ),
                          
                          const SizedBox(height: AppConstants.paddingXL),
                          
                          // App Name
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          
                          const SizedBox(height: AppConstants.paddingS),
                          
                          // App Tagline
                          Text(
                            AppConstants.appTagline,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppConstants.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: AppConstants.paddingXL * 2),
                          
                          // Loading Section
                          Consumer<AppProvider>(
                            builder: (context, provider, child) {
                              if (provider.error.isNotEmpty) {
                                return Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppConstants.paddingM),
                                      decoration: BoxDecoration(
                                        color: AppConstants.errorColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                      ),
                                      child: Icon(
                                        Icons.error_outline_rounded,
                                        color: AppConstants.errorColor,
                                        size: AppConstants.iconSizeLarge,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.paddingM),
                                    Text(
                                      'Failed to load data',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppConstants.errorColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.paddingS),
                                    Text(
                                      'Please check your connection',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppConstants.paddingL),
                                    OutlinedButton.icon(
                                      onPressed: provider.initialize,
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: const Text('Retry'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppConstants.errorColor,
                                        side: BorderSide(color: AppConstants.errorColor.withOpacity(0.3)),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              
                              return Column(
                                children: [
                                  // Custom Loading Indicator
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppConstants.vaultRed.withOpacity(0.8),
                                      ),
                                      backgroundColor: AppConstants.textTertiary.withOpacity(0.2),
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.paddingL),
                                  Text(
                                    'Loading your prompts...',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppConstants.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: AppConstants.paddingXL),
                          
                          // Bottom branding
                          Text(
                            'Powered by AI',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppConstants.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}