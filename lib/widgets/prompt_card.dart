import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/prompt.dart';
import '../providers/app_provider.dart';
import '../screens/prompt_detail_screen.dart';

class PromptCard extends StatelessWidget {
  final Prompt prompt;
  final bool isCompact;

  const PromptCard({
    super.key,
    required this.prompt,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final category = provider.getCategoryById(prompt.categoryId);
    final categoryColor = AppConstants.categoryColors[prompt.categoryId] ?? AppConstants.cardColor;

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: prompt.isPremium && !prompt.isUnlocked
              ? AppConstants.vaultRed.withOpacity(0.2)
              : AppConstants.textTertiary.withOpacity(0.1),
          width: prompt.isPremium && !prompt.isUnlocked ? 1.5 : 1,
        ),
        boxShadow: [
          if (prompt.isPremium && !prompt.isUnlocked) AppConstants.premiumShadow
          else AppConstants.cardShadow,
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PromptDetailScreen(prompt: prompt),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Category Badge
                    if (category != null)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingM,
                            vertical: AppConstants.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(AppConstants.radiusL),
                            border: Border.all(
                              color: AppConstants.textTertiary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.icon,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: AppConstants.paddingS),
                              Flexible(
                                child: Text(
                                  category.name,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppConstants.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Spacer(),

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
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.vaultRed.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              size: 14,
                              color: AppConstants.textOnDark,
                            ),
                            const SizedBox(width: AppConstants.paddingS),
                            Text(
                              'Premium',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppConstants.textOnDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Favorite Button
                    const SizedBox(width: AppConstants.paddingS),
                    Container(
                      decoration: BoxDecoration(
                        color: prompt.isFavorite 
                            ? AppConstants.vaultRed.withOpacity(0.1)
                            : AppConstants.cardColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: IconButton(
                        onPressed: () => provider.toggleFavorite(prompt.id),
                        icon: Icon(
                          prompt.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          color: prompt.isFavorite ? AppConstants.vaultRed : AppConstants.textTertiary,
                          size: AppConstants.iconSizeSmall,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.paddingM),

                // Title
                Text(
                  prompt.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textPrimary,
                  ),
                  maxLines: isCompact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppConstants.paddingS),

                // Description
                Text(
                  prompt.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: isCompact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),

                if (!isCompact) ...[
                  const SizedBox(height: AppConstants.paddingM),

                  // Tags
                  if (prompt.tags.isNotEmpty)
                    Wrap(
                      spacing: AppConstants.paddingS,
                      runSpacing: AppConstants.paddingS,
                      children: prompt.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingM,
                            vertical: AppConstants.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.cardColor,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            border: Border.all(
                              color: AppConstants.textTertiary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppConstants.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: AppConstants.paddingM),

                  // Footer
                  Row(
                    children: [
                      // Difficulty Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                          vertical: AppConstants.paddingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.difficultyColors[prompt.difficulty]?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          border: Border.all(
                            color: AppConstants.difficultyColors[prompt.difficulty]?.withOpacity(0.3) ?? 
                                   AppConstants.textTertiary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              size: 12,
                              color: AppConstants.difficultyColors[prompt.difficulty],
                            ),
                            const SizedBox(width: AppConstants.paddingS),
                            Text(
                              prompt.difficulty,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppConstants.difficultyColors[prompt.difficulty],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppConstants.paddingM),

                      // Estimated Time
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppConstants.textTertiary,
                          ),
                          const SizedBox(width: AppConstants.paddingS),
                          Text(
                            prompt.estimatedTime,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppConstants.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Action Button
                      if (prompt.isPremium && !prompt.isUnlocked)
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppConstants.vaultRedGradient,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PromptDetailScreen(prompt: prompt),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingM,
                                  vertical: AppConstants.paddingS,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.lock_open_rounded,
                                      size: 14,
                                      color: AppConstants.textOnDark,
                                    ),
                                    const SizedBox(width: AppConstants.paddingS),
                                    Text(
                                      'Unlock',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppConstants.textOnDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PromptDetailScreen(prompt: prompt),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.paddingM,
                                  vertical: AppConstants.paddingS,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: AppConstants.textOnDark,
                                    ),
                                    const SizedBox(width: AppConstants.paddingS),
                                    Text(
                                      'View',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppConstants.textOnDark,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}