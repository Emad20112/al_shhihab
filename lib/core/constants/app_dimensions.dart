import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP DIMENSIONS - Responsive Sizing System
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Uses flutter_screenutil for adaptive sizing across all devices.
/// All values are designed for a base design of 375x812 (iPhone X).
/// ═══════════════════════════════════════════════════════════════════════════

class AppDimensions {
  AppDimensions._();

  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING
  // ═══════════════════════════════════════════════════════════════════════════

  static double get spacingXXS => 4.w;
  static double get spacingXS => 8.w;
  static double get spacingSM => 12.w;
  static double get spacingMD => 16.w;
  static double get spacingLG => 24.w;
  static double get spacingXL => 32.w;
  static double get spacingXXL => 48.w;
  static double get spacingHuge => 64.w;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════════════════════════════════

  static double get radiusXS => 8.r;
  static double get radiusSM => 12.r;
  static double get radiusMD => 16.r;
  static double get radiusLG => 20.r;
  static double get radiusXL => 24.r;
  static double get radiusXXL => 32.r;
  static double get radiusFull => 100.r;

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASS CONTAINER SPECIFIC
  // ═══════════════════════════════════════════════════════════════════════════

  /// Default border width for glass containers
  static double get glassBorderWidth => 1.5.w;

  /// Neon border width for dark mode
  static double get neonBorderWidth => 2.w;

  /// Default padding inside glass containers
  static double get glassInnerPadding => 16.w;

  /// Default margin around glass containers
  static double get glassOuterMargin => 12.w;

  // ═══════════════════════════════════════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════════════════════════════════════

  static double get iconXS => 16.w;
  static double get iconSM => 20.w;
  static double get iconMD => 24.w;
  static double get iconLG => 32.w;
  static double get iconXL => 48.w;

  // ═══════════════════════════════════════════════════════════════════════════
  // BUTTON DIMENSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static double get buttonHeightSM => 40.h;
  static double get buttonHeightMD => 48.h;
  static double get buttonHeightLG => 56.h;

  // ═══════════════════════════════════════════════════════════════════════════
  // CARD DIMENSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  static double get productCardWidth => 160.w;
  static double get productCardHeight => 220.h;
  static double get categoryCardSize => 100.w;

  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION
  // ═══════════════════════════════════════════════════════════════════════════

  static double get bottomNavHeight => 80.h;
  static double get appBarHeight => 60.h;

  // ═══════════════════════════════════════════════════════════════════════════
  // AVATAR SIZES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Large avatar (profile headers)
  static double get avatarSizeLG => 70.w;

  /// Avatar inner circle (for gradient border effect)
  static double get avatarSizeInner => 64.w;

  /// Avatar icon size
  static double get avatarIconSize => 32.w;

  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS (in milliseconds)
  // ═══════════════════════════════════════════════════════════════════════════

  static const int animationFast = 200;
  static const int animationNormal = 300;
  static const int animationSlow = 500;
  static const int animationVerySlow = 800;

  /// Stagger delay for list item animations
  static const int staggerDelay = 50;
}
