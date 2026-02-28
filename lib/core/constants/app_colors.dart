import 'package:flutter/material.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP COLORS - Glassmorphism Color System
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Two distinct visual themes:
/// • Light Mode: "Frosted Ice" - Soft, pastel, blurry
/// • Dark Mode: "Smoked Glass" - Deep dark, neon accents, glossy edges
/// ═══════════════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE: "Frosted Ice" ❄️
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary gradient colors for light mode background (softer, more pastel)
  static const Color lightGradientStart = Color(0xFFF8FBFF); // Very soft blue
  static const Color lightGradientMiddle = Color(
    0xFFFAF7FE,
  ); // Very soft lavender
  static const Color lightGradientEnd = Color(0xFFFFF9FB); // Very soft pink

  /// Glass surface colors for light mode
  static const Color lightGlassSurface = Colors.white;
  static const double lightGlassOpacity =
      0.60; // Increased for better visibility
  static const double lightGlassBorderOpacity = 0.4;

  /// Light mode text colors (enhanced for WCAG AAA contrast)
  static const Color lightTextPrimary = Color(
    0xFF1A1A2E,
  ); // Deep charcoal (7:1 contrast)
  static const Color lightTextSecondary = Color(
    0xFF3A3A5A,
  ); // Darker gray-purple (better contrast)
  static const Color lightTextMuted = Color(0xFF6A6A8A); // Visible muted gray

  /// Light mode accent (reduced saturation for calm feel)
  static const Color lightAccent = Color(0xFF6C63FF); // Soft purple
  static const Color lightAccentSecondary = Color(0xFF00D9FF); // Cyan
  static const Color lightAccentSoft = Color(
    0xFF8B7FFF,
  ); // Softer purple variant
  static const Color lightAccentPastel = Color(0xFFB8AEFF); // Very light purple
  static const Color lightCyanSoft = Color(0xFF7DD3FC); // Soft cyan variant

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE: "Smoked Glass" 🌙
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary gradient colors for dark mode background
  static const Color darkGradientStart = Color(0xFF0D0D1A); // Deep space
  static const Color darkGradientMiddle = Color(0xFF1A1A3E); // Midnight purple
  static const Color darkGradientEnd = Color(0xFF0A1628); // Deep ocean

  /// Glass surface colors for dark mode
  static const Color darkGlassSurface = Color(0xFF1A1A2E);
  static const double darkGlassOpacity =
      0.30; // Reduced from 0.35 for subtler effect
  static const double darkGlassBorderOpacity = 0.5;

  /// Dark mode text colors
  static const Color darkTextPrimary = Color(
    0xFFF5F5FF,
  ); // Pure white with hint of blue
  static const Color darkTextSecondary = Color(0xFFB8B8D0); // Soft silver
  static const Color darkTextMuted = Color(0xFF6A6A8A); // Muted purple-gray

  // ═══════════════════════════════════════════════════════════════════════════
  // NEON ACCENT COLORS (Primarily for Dark Mode) ⚡
  // ═══════════════════════════════════════════════════════════════════════════

  /// Neon Cyan - Primary neon accent
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonCyanGlow = Color(0x4000F5FF);

  /// Neon Magenta - Secondary neon accent
  static const Color neonMagenta = Color(0xFFFF00E5);
  static const Color neonMagentaGlow = Color(0x40FF00E5);

  /// Neon Electric Blue - Accent for CTAs
  static const Color neonBlue = Color(0xFF00A3FF);
  static const Color neonBlueGlow = Color(0x4000A3FF);

  /// Neon Green - Success states
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonGreenGlow = Color(0x4000FF88);

  /// Neon Orange - Warnings and highlights
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonOrangeGlow = Color(0x40FF6B00);

  /// Neon Purple - Special elements
  static const Color neonPurple = Color(0xFFBB00FF);
  static const Color neonPurpleGlow = Color(0x40BB00FF);

  // ═══════════════════════════════════════════════════════════════════════════
  // UX ENHANCEMENTS - Reduced Glow & Better Readability
  // ═══════════════════════════════════════════════════════════════════════════

  /// Reduced neon glow for secondary elements (less visual fatigue)
  static const double neonGlowReduced = 0.15;
  static const double neonGlowSubtle = 0.08;
  static const double neonGlowStrong = 0.4;

  /// Text overlay colors for improved readability
  static const Color textOverlayDark = Color(0xCC000000); // 80% black
  static const Color textOverlayDarkSubtle = Color(0x66000000); // 40% black
  static const Color textOverlayLight = Color(0x99FFFFFF); // 60% white

  /// Soft shadow colors for depth without harshness
  static const Color softShadowDark = Color(0x33000000); // 20% black
  static const Color softShadowNeon = Color(0x2600F5FF); // 15% neon cyan

  /// Light mode specific shadows
  static const Color lightShadowSoft = Color(
    0x0A000000,
  ); // 4% black - subtle depth
  static const Color lightShadowMedium = Color(
    0x14000000,
  ); // 8% black - card elevation
  static const Color lightShadowStrong = Color(
    0x1F000000,
  ); // 12% black - prominent elements

  /// Gradient overlay for image text readability
  static LinearGradient get imageTextGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
    stops: const [0.5, 1.0],
  );

  /// Light mode overlay for subtle backgrounds
  static const Color lightOverlay = Color(0x0FFFFFFF); // 6% white
  static const Color lightOverlayStrong = Color(0x1AFFFFFF); // 10% white

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASS BLUR SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Light mode blur (higher for frosted effect)
  static const double lightBlurSigma = 20.0;

  /// Dark mode blur (moderate for smoked effect)
  static const double darkBlurSigma = 15.0;

  /// Reduced blur for atmospheric backgrounds
  static const double atmosphericBlurSigma = 35.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF00B0FF);

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

  /// Neon border gradient for dark mode glass containers
  static const LinearGradient neonBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonCyan, neonMagenta, neonBlue],
  );

  /// Subtle neon border gradient (lower opacity)
  static LinearGradient get neonBorderGradientSubtle => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      neonCyan.withOpacity(0.5),
      neonMagenta.withOpacity(0.5),
      neonBlue.withOpacity(0.5),
    ],
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

  /// Get primary text color based on theme
  static Color getTextPrimary(bool isDark) {
    return isDark ? darkTextPrimary : lightTextPrimary;
  }

  /// Get secondary text color based on theme
  static Color getTextSecondary(bool isDark) {
    return isDark ? darkTextSecondary : lightTextSecondary;
  }

  /// Get background gradient based on theme
  static LinearGradient getBackgroundGradient(bool isDark) {
    return isDark ? darkBackgroundGradient : lightBackgroundGradient;
  }

  /// Get text color with enhanced readability overlay
  static Color getReadableTextColor(bool isDark, {bool emphasize = false}) {
    if (isDark) {
      return emphasize ? darkTextPrimary : darkTextSecondary;
    }
    return emphasize ? lightTextPrimary : lightTextSecondary;
  }

  /// Get neon glow with reduced intensity for secondary elements
  static Color getNeonGlow(Color neonColor, {bool subtle = false}) {
    return neonColor.withOpacity(subtle ? neonGlowSubtle : neonGlowReduced);
  }

  /// Get shadow color for depth
  static Color getSoftShadow(bool isDark, {bool useNeon = false}) {
    if (isDark && useNeon) {
      return softShadowNeon;
    }
    return isDark ? softShadowDark : lightShadowMedium;
  }

  /// Get card shadow based on theme (dual-layer for light mode)
  static List<BoxShadow> getCardShadow(bool isDark, {bool elevated = false}) {
    if (isDark) {
      return [
        BoxShadow(
          color: softShadowDark,
          blurRadius: elevated ? 15.0 : 10.0,
          offset: const Offset(0, 8),
        ),
      ];
    }
    // Light mode: dual-layer shadow for elegant depth
    return [
      BoxShadow(
        color: lightShadowSoft,
        blurRadius: 16,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: lightShadowSoft,
        blurRadius: 32,
        offset: const Offset(0, 8),
        spreadRadius: 0,
      ),
    ];
  }

  /// Get accent color with optional soft variant for light mode
  static Color getAccentColor(bool isDark, {bool soft = false}) {
    if (isDark) {
      return neonCyan;
    }
    return soft ? lightAccentSoft : lightAccent;
  }
}
