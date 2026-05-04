import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP COLORS - Glassmorphism Color System
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Two distinct visual themes:
/// • Light Mode: "Frosted Ice" - Soft, pastel, blurry
/// • Dark Mode: "Dark Luxury" - Deep black, gold accents, elegant
/// ═══════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE: "Frosted Ice" ❄️
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary gradient colors for light mode background
  static const Color lightGradientStart = Color(0xFFEFEDDA); // Ivory
  static const Color lightGradientMiddle = Color(0xFFE8E6D3); // Slightly darker
  static const Color lightGradientEnd = Color(0xFFEFEDDA); // Ivory

  static const Color lightGlassSurface = Colors.white;
  static const double lightGlassOpacity = 0.40; // Lower opacity for ivory
  static const double lightGlassBorderOpacity = 0.3;

  /// Light mode text colors (Midnight Blue variants)
  static const Color lightTextPrimary = Color(0xFF101B3A); // Midnight Blue
  static const Color lightTextSecondary = Color(0xFF283253); 
  static const Color lightTextMuted = Color(0xFF707A9A); 

  /// Light mode accent
  static const Color lightAccent = Color(0xFF101B3A); // Midnight Blue
  static const Color lightAccentSecondary = Color(0xFF283253); 
  static const Color lightAccentSoft = Color(0xFF4A557A); 

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE: "Dark Luxury" ✨
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary gradient colors for dark mode background
  static const Color darkGradientStart = Color(0xFF0B0B0B); // Deep black
  static const Color darkGradientMiddle = Color(0xFF0F0F0F); // Slightly lighter
  static const Color darkGradientEnd = Color(0xFF0B0B0B); // Deep black

  /// Glass surface colors for dark mode
  static const Color darkGlassSurface = Color(0xFF1A1A1A);
  static const double darkGlassOpacity =
      0.30; // Reduced from 0.35 for subtler effect

  /// Dark mode text colors
  static const Color darkTextPrimary = Color(
    0xFFFFFFFF,
  ); // Pure white
  static const Color darkTextSecondary = Color(0xFFAAAAAA); // Light gray
  static const Color darkTextMuted = Color(0xFF666666); // Muted gray

  // ═══════════════════════════════════════════════════════════════════════════
  // LUXURY GOLD ACCENT COLORS (Primarily for Dark Mode) ✨
  // ═══════════════════════════════════════════════════════════════════════════

  /// Luxury Gold - Primary accent
  static const Color neonCyan = Color(0xFFD4AF37);

  /// Light Gold - Secondary accent
  static const Color neonMagenta = Color(0xFFC9A84C);

  /// Dark Gold - Accent for CTAs
  static const Color neonBlue = Color(0xFFB8962E);

  /// Gold Green - Success states (warm gold-green)
  static const Color neonGreen = Color(0xFF8B9A46);

  /// Gold Amber - Warnings and highlights
  static const Color neonOrange = Color(0xFFE8C547);

  /// Deep Gold - Special elements
  static const Color neonPurple = Color(0xFFA8842D);

  /// Bright Gold for gradient endpoints
  static const Color goldLight = Color(0xFFF5D76E);
  static const Color goldDark = Color(0xFFB8962E);

  // ═══════════════════════════════════════════════════════════════════════════
  // UX ENHANCEMENTS - Reduced Glow & Better Readability
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reduced glow for secondary elements (less visual fatigue)
  static const double neonGlowReduced = 0.15;
  static const double neonGlowSubtle = 0.08;

  /// Soft shadow colors for depth without harshness
  static const Color softShadowDark = Color(0x4D000000); // 30% black
  static const Color softShadowNeon = Color(0x26D4AF37); // 15% gold

  /// Light mode specific shadows
  static const Color lightShadowSoft = Color(
    0x0A000000,
  ); // 4% black - subtle depth
  static const Color lightShadowMedium = Color(
    0x14000000,
  ); // 8% black - card elevation

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASS BLUR SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Light mode blur (higher for frosted effect)
  static const double lightBlurSigma = 20.0;

  /// Dark mode blur (moderate for luxury effect)
  static const double darkBlurSigma = 15.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color error = Color(0xFFFF1744);

  // ═══════════════════════════════════════════════════════════════════════════
  // GRADIENT PRESETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Light mode background gradient
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGradientStart, lightGradientMiddle, lightGradientEnd],
    stops: [0.0, 0.5, 1.0],
  );

  /// Dark mode background gradient
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGradientStart, darkGradientMiddle, darkGradientEnd],
    stops: [0.0, 0.5, 1.0],
  );

  /// Gold gradient for CTA buttons
  static const LinearGradient goldButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4AF37), Color(0xFFF5D76E)],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get glass surface color based on theme
  static Color getGlassSurface(bool isDark) {
    return isDark ? darkGlassSurface : lightGlassSurface;
  }

  /// Get glass opacity based on theme
  static double getGlassOpacity(bool isDark) {
    return isDark ? darkGlassOpacity : lightGlassOpacity;
  }

  /// Get blur sigma based on theme
  static double getBlurSigma(bool isDark) {
    return isDark ? darkBlurSigma : lightBlurSigma;
  }

  /// Get gold glow with reduced intensity for secondary elements
  static Color getNeonGlow(Color neonColor, {bool subtle = false}) {
    return neonColor.withValues(
      alpha: subtle ? neonGlowSubtle : neonGlowReduced,
    );
  }

  /// Get shadow color for depth
  static Color getSoftShadow(bool isDark, {bool useNeon = false}) {
    if (isDark && useNeon) {
      return softShadowNeon;
    }
    return isDark ? softShadowDark : lightShadowMedium;
  }

  /// Get accent color with optional soft variant for light mode
  static Color getAccentColor(bool isDark, {bool soft = false}) {
    if (isDark) {
      return neonCyan;
    }
    return soft ? lightAccentSoft : lightAccent;
  }
}
