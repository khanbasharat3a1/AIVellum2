import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_constants.dart';
import '../models/prompt.dart';
import '../providers/app_provider.dart';
import 'premium_unlock_screen.dart';

class PromptDetailScreen extends StatelessWidget {
  final Prompt prompt;

  const PromptDetailScreen({
    super.key,
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final category = provider.getCategoryById(prompt.categoryId);
          final isUnlocked = prompt.isUnlocked || !prompt.isPremium;
          final categoryColor = AppConstants.categoryColors[prompt.categoryId] ?? AppConstants.cardColor;

          return CustomScrollView(
            slivers: [
              // Custom App Bar with Hero Section
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: AppConstants.surfaceColor,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                    boxShadow: [AppConstants.cardShadow],
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: prompt.isFavorite 
                          ? AppConstants.vaultRed.withOpacity(0.1)
                          : AppConstants.surfaceColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      boxShadow: [AppConstants.cardShadow],
                    ),
                    child: IconButton(
                      onPressed: () => provider.toggleFavorite(prompt.id),
                      icon: Icon(
                        prompt.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: prompt.isFavorite ? AppConstants.vaultRed : AppConstants.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      boxShadow: [AppConstants.cardShadow],
                    ),
                    child: IconButton(
                      onPressed: isUnlocked ? () => _sharePrompt(context) : null,
                      icon: Icon(
                        Icons.share_rounded,
                        color: isUnlocked ? AppConstants.textPrimary : AppConstants.textTertiary,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          categoryColor.withOpacity(0.3),
                          AppConstants.surfaceColor,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60), // Space for app bar
                            
                            // Category Badge
                            if (category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingM,
                                  vertical: AppConstants.paddingS,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                  border: Border.all(
                                    color: AppConstants.textTertiary.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      category.icon,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: AppConstants.paddingS),
                                    Text(
                                      category.name,
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppConstants.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            const SizedBox(height: AppConstants.paddingM),
                            
                            // Title
                            Text(
                              prompt.title,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textPrimary,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: AppConstants.paddingM),
                            
                            // Premium Badge
                            if (prompt.isPremium && !prompt.isUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingM,
                                  vertical: AppConstants.paddingS,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppConstants.vaultRedGradient,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                  boxShadow: [AppConstants.premiumShadow],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 16,
                                      color: AppConstants.textOnDark,
                                    ),
                                    const SizedBox(width: AppConstants.paddingS),
                                    Text(
                                      'Premium Content',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: AppConstants.textOnDark,
                                        fontWeight: FontWeight.w700,
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
                ),
              ),

              // Content Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.paddingL),
                        decoration: BoxDecoration(
                          color: AppConstants.surfaceColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: AppConstants.textTertiary.withOpacity(0.1),
                          ),
                          boxShadow: [AppConstants.cardShadow],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description_rounded,
                                  color: AppConstants.textSecondary,
                                  size: AppConstants.iconSizeSmall,
                                ),
                                const SizedBox(width: AppConstants.paddingS),
                                Text(
                                  'Description',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.paddingM),
                            Text(
                              prompt.description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: AppConstants.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingL),

                      // Metadata Row
                      Row(
                        children: [
                          // Difficulty Badge
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppConstants.paddingM),
                              decoration: BoxDecoration(
                                color: AppConstants.difficultyColors[prompt.difficulty]?.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                border: Border.all(
                                  color: AppConstants.difficultyColors[prompt.difficulty]?.withOpacity(0.3) ?? 
                                         AppConstants.textTertiary.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    color: AppConstants.difficultyColors[prompt.difficulty],
                                    size: AppConstants.iconSizeMedium,
                                  ),
                                  const SizedBox(height: AppConstants.paddingS),
                                  Text(
                                    'Difficulty',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppConstants.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    prompt.difficulty,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppConstants.difficultyColors[prompt.difficulty],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: AppConstants.paddingM),

                          // Time Badge
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(AppConstants.paddingM),
                              decoration: BoxDecoration(
                                color: AppConstants.infoColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                border: Border.all(
                                  color: AppConstants.infoColor.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    color: AppConstants.infoColor,
                                    size: AppConstants.iconSizeMedium,
                                  ),
                                  const SizedBox(height: AppConstants.paddingS),
                                  Text(
                                    'Duration',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppConstants.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    prompt.estimatedTime,
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: AppConstants.infoColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingL),

                      // Tags Section
                      if (prompt.tags.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingM),
                        Wrap(
                          spacing: AppConstants.paddingS,
                          runSpacing: AppConstants.paddingS,
                          children: prompt.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingM,
                                vertical: AppConstants.paddingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.cardColor,
                                borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                border: Border.all(
                                  color: AppConstants.textTertiary.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppConstants.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppConstants.paddingL),
                      ],

                      // Content Section
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppConstants.surfaceColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          border: Border.all(
                            color: isUnlocked 
                                ? AppConstants.successColor.withOpacity(0.3)
                                : AppConstants.vaultRed.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            if (!isUnlocked) AppConstants.premiumShadow
                            else AppConstants.cardShadow,
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(AppConstants.paddingL),
                              decoration: BoxDecoration(
                                color: isUnlocked 
                                    ? AppConstants.successColor.withOpacity(0.05)
                                    : AppConstants.vaultRed.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(AppConstants.radiusM),
                                  topRight: Radius.circular(AppConstants.radiusM),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                                    color: isUnlocked ? AppConstants.successColor : AppConstants.vaultRed,
                                    size: AppConstants.iconSizeSmall,
                                  ),
                                  const SizedBox(width: AppConstants.paddingS),
                                  Text(
                                    isUnlocked ? 'Prompt Content' : 'Premium Content',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isUnlocked ? AppConstants.successColor : AppConstants.vaultRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingL),
                              child: !isUnlocked 
                                  ? _buildLockedContent(context, provider)
                                  : _buildUnlockedContent(context),
                            ),
                          ],
                        ),
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
    );
  }

  Widget _buildLockedContent(BuildContext context, AppProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingXL),
          decoration: BoxDecoration(
            color: AppConstants.backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppConstants.textTertiary.withOpacity(0.2),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: BoxDecoration(
                  gradient: AppConstants.vaultRedGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 48,
                  color: AppConstants.textOnDark,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              Text(
                'Unlock Premium Content',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              Text(
                'Get access to the full prompt content and start creating amazing results',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppConstants.paddingL),
        
        // Unlock Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showUnlockScreen(context),
            icon: const Icon(Icons.lock_open_rounded),
            label: const Text('Unlock Premium Content'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.vaultRed,
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingL),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockedContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          prompt.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingL),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _sharePrompt(context),
                icon: const Icon(Icons.share_rounded),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: prompt.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Prompt copied to clipboard!'),
          ],
        ),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusS),
        ),
      ),
    );
  }

  void _sharePrompt(BuildContext context) {
    Share.share(
      '${prompt.title}\n\n${prompt.description}\n\nGet more AI prompts at Aivellum!',
      subject: prompt.title,
    );
  }

  Future<void> _showUnlockScreen(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => PremiumUnlockScreen(prompt: prompt),
      ),
    );
    
    // If prompt was unlocked, the screen will rebuild automatically
    // due to the provider notifying listeners
  }
}