import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import '../widgets/prompt_card.dart';
import '../widgets/search_bar_widget.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, child) {
            final searchResults = provider.searchQuery.isNotEmpty 
                ? provider.getSearchResults() 
                : <dynamic>[];
            
            final selectedCategoryPrompts = provider.selectedCategoryId != null
                ? provider.getPromptsByCategory(provider.selectedCategoryId!)
                : <dynamic>[];

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppConstants.backgroundColor,
                  elevation: 0,
                  title: Text(
                    provider.searchQuery.isNotEmpty 
                        ? 'Search Results'
                        : provider.selectedCategoryId != null
                            ? provider.getCategoryById(provider.selectedCategoryId!)?.name ?? 'Categories'
                            : 'Categories',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    if (provider.selectedCategoryId != null)
                      IconButton(
                        onPressed: () => provider.setSelectedCategory(null),
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    child: SearchBarWidget(
                      onChanged: provider.setSearchQuery,
                    ),
                  ),
                ),

                // Show search results if searching
                if (provider.searchQuery.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                      child: Text(
                        '${searchResults.length} results found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingM)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final prompt = searchResults[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: AppConstants.paddingM,
                            right: AppConstants.paddingM,
                            bottom: index == searchResults.length - 1 
                                ? AppConstants.paddingXL 
                                : AppConstants.paddingS,
                          ),
                          child: PromptCard(prompt: prompt),
                        );
                      },
                      childCount: searchResults.length,
                    ),
                  ),
                ]
                // Show category prompts if category selected
                else if (provider.selectedCategoryId != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                      child: Text(
                        '${selectedCategoryPrompts.length} prompts in this category',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppConstants.paddingM)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final prompt = selectedCategoryPrompts[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            left: AppConstants.paddingM,
                            right: AppConstants.paddingM,
                            bottom: index == selectedCategoryPrompts.length - 1 
                                ? AppConstants.paddingXL 
                                : AppConstants.paddingS,
                          ),
                          child: PromptCard(prompt: prompt),
                        );
                      },
                      childCount: selectedCategoryPrompts.length,
                    ),
                  ),
                ]
                // Show all categories
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Text(
                        'Browse Categories',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1, // Reduced aspect ratio to give more height
                        crossAxisSpacing: AppConstants.paddingM,
                        mainAxisSpacing: AppConstants.paddingM,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = provider.categories[index];
                          final promptCount = provider.getPromptsByCategory(category.id).length;
                          
                          return GestureDetector(
                            onTap: () => provider.setSelectedCategory(category.id),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppConstants.categoryColors[category.id]?.withOpacity(0.2) ?? AppConstants.cardColor,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                    ),
                                    child: Center(
                                      child: Text(
                                        category.icon,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.paddingS),
                                  Flexible(
                                    child: Text(
                                      category.name,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.paddingXS),
                                  Text(
                                    '$promptCount prompts',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppConstants.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: provider.categories.length,
                      ),
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