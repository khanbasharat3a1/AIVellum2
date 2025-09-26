import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'favorites_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: IndexedStack(
            index: provider.currentIndex,
            children: const [
              HomeScreen(),
              CategoriesScreen(),
              FavoritesScreen(),
              PremiumScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingS,
                  vertical: AppConstants.paddingS,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.home_rounded,
                      outlineIcon: Icons.home_outlined,
                      label: 'Home',
                      index: 0,
                      isSelected: provider.currentIndex == 0,
                      onTap: () => provider.setCurrentIndex(0),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.category_rounded,
                      outlineIcon: Icons.category_outlined,
                      label: 'Categories',
                      index: 1,
                      isSelected: provider.currentIndex == 1,
                      onTap: () => provider.setCurrentIndex(1),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.favorite_rounded,
                      outlineIcon: Icons.favorite_outline_rounded,
                      label: 'Favorites',
                      index: 2,
                      isSelected: provider.currentIndex == 2,
                      onTap: () => provider.setCurrentIndex(2),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.workspace_premium_rounded,
                      outlineIcon: Icons.workspace_premium_outlined,
                      label: 'Premium',
                      index: 3,
                      isSelected: provider.currentIndex == 3,
                      onTap: () => provider.setCurrentIndex(3),
                      isPremium: true,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.settings_rounded,
                      outlineIcon: Icons.settings_outlined,
                      label: 'Settings',
                      index: 4,
                      isSelected: provider.currentIndex == 4,
                      onTap: () => provider.setCurrentIndex(4),
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

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData outlineIcon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.paddingS,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingS),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (isPremium ? AppConstants.vaultRed : AppConstants.primaryColor).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Icon(
                  isSelected ? icon : outlineIcon,
                  size: AppConstants.iconSizeMedium,
                  color: isSelected 
                      ? (isPremium ? AppConstants.vaultRed : AppConstants.primaryColor)
                      : AppConstants.textTertiary,
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingXS),
              
              // Label
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected 
                      ? (isPremium ? AppConstants.vaultRed : AppConstants.primaryColor)
                      : AppConstants.textTertiary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Selection indicator
              if (isSelected) ...[
                const SizedBox(height: AppConstants.paddingXS),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isPremium ? AppConstants.vaultRed : AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}