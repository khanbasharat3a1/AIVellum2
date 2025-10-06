import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/prompt_card.dart';
import '../widgets/pro_banner_widget.dart';
import '../services/ad_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdService.createBannerAd()..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final favoritePrompts = provider.favoritePrompts;

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppConstants.backgroundColor,
                  elevation: 0,
                  title: Text(
                    'Favorites',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Pro Banner
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingM),
                    child: ProBannerWidget(),
                  ),
                ),

                // Empty State or Content
                if (favoritePrompts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 80,
                            color: AppConstants.textTertiary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          Text(
                            'No favorites yet',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingS),
                          Text(
                            'Tap the heart icon on any prompt to add it to your favorites',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.paddingL),
                          ElevatedButton(
                            onPressed: () => provider.setCurrentIndex(1),
                            child: const Text('Browse Prompts'),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Stats
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.paddingM),
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: AppConstants.primaryColor, // Use vault red for favorites
                              size: 24,
                            ),
                            const SizedBox(width: AppConstants.paddingM),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${favoritePrompts.length} Favorite Prompts',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Your curated collection',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppConstants.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Favorite Prompts List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final prompt = favoritePrompts[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: AppConstants.paddingM,
                            right: AppConstants.paddingM,
                            bottom: index == favoritePrompts.length - 1 
                                ? AppConstants.paddingXL 
                                : AppConstants.paddingS,
                          ),
                          child: PromptCard(prompt: prompt),
                        );
                      },
                      childCount: favoritePrompts.length,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingL)),

                  // Banner Ad
                  if (_bannerAd != null)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                        height: 50,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingXL)),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}