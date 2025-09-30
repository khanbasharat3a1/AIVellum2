import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Aivellum';
  static const String appTagline = 'Premium AI Prompts Vault';
  static const String packageName = 'com.khanbasharat.aivellum';
  
  // Debug Mode (set to false for production)
  static const bool isDebugMode = false;


  // Vault Red Brand Color Scheme
  static const Color vaultRed = Color(0xFFFF3131); // Primary brand color
  static const Color vaultRedLight = Color(0xFFFF6B6B); // Lighter variant
  static const Color vaultRedDark = Color(0xFFE02424); // Darker variant
  
  // Main UI Colors
  static const Color primaryColor = Color(0xFF1F2937); // Dark gray for primary elements
  static const Color secondaryColor = Color(0xFF374151); // Medium gray for secondary
  static const Color accentColor = Color(0xFF6B7280); // Light gray for accents
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA); // Very light gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFF9FAFB); // Slightly off-white
  
  // Status Colors
  static const Color successColor = Color(0xFF059669);
  static const Color warningColor = Color(0xFFD97706);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color infoColor = Color(0xFF2563EB);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Almost black
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray
  static const Color textOnDark = Color(0xFFFFFFFF); // White on dark backgrounds
  static const Color borderColor = Color(0xFFE5E7EB); // Light border color

  // Gradients
  static const LinearGradient vaultRedGradient = LinearGradient(
    colors: [vaultRed, vaultRedLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFFF3F4F6), backgroundColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Difficulty Colors
  static const Map<String, Color> difficultyColors = {
    'Beginner': successColor,
    'Intermediate': warningColor,
    'Advanced': vaultRed,
  };
  
  // Category Colors (subtle backgrounds)
  static const Map<String, Color> categoryColors = {
    'money_making': Color(0xFFFEF3C7), // Light yellow
    'business_strategy': Color(0xFFDDD6FE), // Light purple
    'freelancing': Color(0xFFBFDBFE), // Light blue
    'marketing_sales': Color(0xFFBBF7D0), // Light green
    'writing': Color(0xFFFECDD3), // Light pink
    'content_creation': Color(0xFFE0E7FF), // Light indigo
    'development_tech': Color(0xFFD1FAE5), // Light emerald
    'productivity': Color(0xFFFED7AA), // Light orange
    'social_media': Color(0xFFE879F9), // Light magenta
    'learning_education': Color(0xFFC7D2FE), // Light violet
    'psychology': Color(0xFFFDE68A), // Light amber
    'fitness_health': Color(0xFFA7F3D0), // Light teal
    'ai_art': Color(0xFFF3E8FF), // Light fuchsia
    'research_analysis': Color(0xFFCFD8DC), // Light blue gray
  };

  // Premium Features
  static const int maxFreePrompts = 5;
  static const int maxRewardAdUnlocks = 3;
  static const int promptsPerPage = 20;
  
  // UI Constants
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  
  // Premium UI Elements
  static const BoxShadow premiumShadow = BoxShadow(
    color: Color(0x1AFF3131), // Vault red with low opacity
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0A000000), // Black with very low opacity
    blurRadius: 8,
    offset: Offset(0, 2),
  );
}