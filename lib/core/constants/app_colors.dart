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

  /// Primary gradient colors for light mode background
  static const Color lightGradientStart = Color(0xFFE8F4FD); // Soft ice blue
  static const Color lightGradientMiddle = Color(0xFFF0E6FA); // Lavender mist
  static const Color lightGradientEnd = Color(0xFFFDE8F0); // Soft pink

  /// Glass surface colors for light mode
  static const Color lightGlassSurface = Colors.white;
  static const double lightGlassOpacity = 0.25;
  static const double lightGlassBorderOpacity = 0.3;

  /// Light mode text colors
  static const Color lightTextPrimary = Color(0xFF1A1A2E); // Deep charcoal
  static const Color lightTextSecondary = Color(0xFF4A4A6A); // Soft gray-purple
  static const Color lightTextMuted = Color(0xFF8A8AAA); // Muted gray

  /// Light mode accent
  static const Color lightAccent = Color(0xFF6C63FF); // Soft purple
  static const Color lightAccentSecondary = Color(0xFF00D9FF); // Cyan

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE: "Smoked Glass" 🌙
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary gradient colors for dark mode background
  static const Color darkGradientStart = Color(0xFF0D0D1A); // Deep space
  static const Color darkGradientMiddle = Color(0xFF1A1A3E); // Midnight purple
  static const Color darkGradientEnd = Color(0xFF0A1628); // Deep ocean

  /// Glass surface colors for dark mode
  static const Color darkGlassSurface = Color(0xFF1A1A2E);
  static const double darkGlassOpacity = 0.35;
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
  // GLASS BLUR SETTINGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Light mode blur (higher for frosted effect)
  static const double lightBlurSigma = 20.0;

  /// Dark mode blur (moderate for smoked effect)
  static const double darkBlurSigma = 15.0;

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
}
