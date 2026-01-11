import 'package:flutter/material.dart';

/// GripCoach Theme Configuration
class GripCoachTheme {
  // Primary colors
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color primaryMedium = Color(0xFF16213E);
  static const Color primaryLight = Color(0xFF0F3460);

  // Accent colors
  static const Color accentBlue = Color(0xFF4DA8DA);
  static const Color accentPurple = Color(0xFF9B59B6);

  // Traction colors
  static const Color tractionGreen = Color(0xFF2ECC71);
  static const Color tractionYellow = Color(0xFFF39C12);
  static const Color tractionRed = Color(0xFFE74C3C);
  static const Color tractionRedFlash = Color(0xFFFF4757);

  // LED bar colors
  static const Color ledOff = Color(0xFF2D2D2D);
  static const Color ledGreenDim = Color(0xFF1A5C32);
  static const Color ledYellowDim = Color(0xFF5C4A1A);
  static const Color ledRedDim = Color(0xFF5C1A1A);

  // UI colors
  static const Color surfaceColor = Color(0xFF1E1E2E);
  static const Color cardColor = Color(0xFF252538);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6C6C6C);

  // Status colors
  static const Color warningOrange = Color(0xFFE67E22);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color infoBlueDark = Color(0xFF2980B9);

  // Motion lock banner
  static const Color lockBannerRed = Color(0xFFE74C3C);
  static const Color lockBannerText = Colors.white;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: accentBlue,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentPurple,
        surface: surfaceColor,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryMedium,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentBlue,
          side: const BorderSide(color: accentBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentBlue,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: accentBlue,
        inactiveTrackColor: ledOff,
        thumbColor: accentBlue,
        overlayColor: Color(0x294DA8DA),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentBlue;
          }
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentBlue.withValues(alpha: 0.5);
          }
          return ledOff;
        }),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textMuted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  // Helper method to get traction color based on fraction
  static Color getTractionColor(double fraction) {
    if (fraction > 1.0) return tractionRedFlash;
    if (fraction >= 0.85) return tractionRed;
    if (fraction >= 0.60) return tractionYellow;
    return tractionGreen;
  }

  // Helper method to get traction color with hysteresis
  static Color getTractionColorWithHysteresis(
    double fraction,
    Color previousColor, {
    double hysteresis = 0.03,
  }) {
    // Apply hysteresis to prevent flickering
    double effectiveFraction = fraction;

    if (previousColor == tractionGreen && fraction < 0.60 + hysteresis) {
      return tractionGreen;
    }
    if (previousColor == tractionYellow) {
      if (fraction < 0.60 - hysteresis) return tractionGreen;
      if (fraction < 0.85 + hysteresis) return tractionYellow;
    }
    if (previousColor == tractionRed) {
      if (fraction < 0.85 - hysteresis) return tractionYellow;
      if (fraction < 1.0) return tractionRed;
    }

    return getTractionColor(effectiveFraction);
  }

  // Road condition colors
  static Color getRoadConditionColor(String condition) {
    switch (condition) {
      case 'dry':
        return successGreen;
      case 'wet':
        return accentBlue;
      case 'snow':
        return const Color(0xFFE8E8E8);
      case 'ice':
        return const Color(0xFF87CEEB);
      default:
        return textMuted;
    }
  }
}
