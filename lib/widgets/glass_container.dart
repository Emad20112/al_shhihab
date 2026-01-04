import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CONTAINER - Premium Glassmorphism Widget
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A reusable glassmorphism container that automatically adapts to theme:
/// • Light Mode: Frosted white surface with soft shadows
/// • Dark Mode: Smoked dark surface with NEON GRADIENT BORDERS
///
/// Features:
/// ✦ BackdropFilter blur effect
/// ✦ Theme-aware styling
/// ✦ Automatic neon borders in dark mode
/// ✦ Customizable blur, opacity, radius
/// ✦ Optional entry animations
/// ✦ Neon glow effect for dark mode
/// ═══════════════════════════════════════════════════════════════════════════

class GlassContainer extends StatelessWidget {
  /// Child widget to display inside the container
  final Widget child;

  /// Padding inside the glass container
  final EdgeInsetsGeometry? padding;

  /// Margin around the glass container
  final EdgeInsetsGeometry? margin;

  /// Border radius of the container
  final double? borderRadius;

  /// Custom blur sigma (overrides theme default)
  final double? blurSigma;

  /// Custom surface opacity (overrides theme default)
  final double? opacity;

  /// Width of the container (null for flexible)
  final double? width;

  /// Height of the container (null for flexible)
  final double? height;

  /// Enable neon border in dark mode (default: true)
  final bool enableNeonBorder;

  /// Custom neon border colors (for dark mode)
  final List<Color>? neonBorderColors;

  /// Border width for neon effect
  final double? borderWidth;

  /// Enable entry animation
  final bool animate;

  /// Animation delay (for staggered animations)
  final Duration animationDelay;

  /// Enable neon glow effect in dark mode
  final bool enableNeonGlow;

  /// Glow spread radius
  final double glowSpread;

  /// Glow blur radius
  final double glowBlur;

  /// Callback when tapped
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma,
    this.opacity,
    this.width,
    this.height,
    this.enableNeonBorder = true,
    this.neonBorderColors,
    this.borderWidth,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.enableNeonGlow = false,
    this.glowSpread = 2,
    this.glowBlur = 15,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? AppColors.getBlurSigma(isDark);
    final double effectiveOpacity =
        opacity ?? AppColors.getGlassOpacity(isDark);
    final double effectiveRadius = borderRadius ?? AppDimensions.radiusLG;
    final double effectiveBorderWidth =
        borderWidth ??
        (isDark
            ? AppDimensions.neonBorderWidth
            : AppDimensions.glassBorderWidth);

    // Determine border colors
    final List<Color> borderColors = _getBorderColors(isDark);

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveRadius),
        // Neon glow effect for dark mode
        boxShadow: _buildShadows(isDark, effectiveRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              // Glass surface
              color: AppColors.getGlassSurface(
                isDark,
              ).withOpacity(effectiveOpacity),
              borderRadius: BorderRadius.circular(effectiveRadius),
              // Border - Neon gradient for dark mode, subtle white for light mode
              border: _buildBorder(
                isDark,
                borderColors,
                effectiveBorderWidth,
                effectiveRadius,
              ),
            ),
            padding: padding ?? EdgeInsets.all(AppDimensions.glassInnerPadding),
            child: child,
          ),
        ),
      ),
    );

    // Wrap with InkWell if onTap is provided
    if (onTap != null) {
      container = GestureDetector(onTap: onTap, child: container);
    }

    // Add entry animation if enabled
    if (animate) {
      return container
          .animate(delay: animationDelay)
          .fadeIn(
            duration: Duration(milliseconds: AppDimensions.animationNormal),
            curve: Curves.easeOut,
          )
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: Duration(milliseconds: AppDimensions.animationNormal),
            curve: Curves.easeOut,
          );
    }

    return container;
  }

  /// Build the border based on theme mode
  Border? _buildBorder(
    bool isDark,
    List<Color> borderColors,
    double width,
    double radius,
  ) {
    if (isDark && enableNeonBorder) {
      // For dark mode, we use a gradient border effect
      // Since Border doesn't support gradients directly, we use a solid color
      // The gradient effect is achieved via the CustomPaint in GlassContainerWithGradientBorder
      return Border.all(
        color: borderColors.first.withOpacity(0.7),
        width: width,
      );
    } else {
      // Light mode - subtle white border
      return Border.all(
        color: Colors.white.withOpacity(AppColors.lightGlassBorderOpacity),
        width: width,
      );
    }
  }

  /// Build shadows based on theme mode
  List<BoxShadow> _buildShadows(bool isDark, double radius) {
    if (isDark) {
      // Dark mode shadows with optional neon glow
      final shadows = <BoxShadow>[
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: -5,
          offset: const Offset(0, 10),
        ),
      ];

      // Add neon glow if enabled
      if (enableNeonGlow) {
        shadows.add(
          BoxShadow(
            color: (neonBorderColors?.first ?? AppColors.neonCyan).withOpacity(
              0.3,
            ),
            blurRadius: glowBlur,
            spreadRadius: glowSpread,
          ),
        );
      }

      return shadows;
    } else {
      // Light mode - soft diffused shadows
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 30,
          spreadRadius: -5,
          offset: const Offset(0, 15),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 20,
          spreadRadius: -10,
          offset: const Offset(0, -5),
        ),
      ];
    }
  }

  /// Get border colors based on theme and customization
  List<Color> _getBorderColors(bool isDark) {
    if (neonBorderColors != null && neonBorderColors!.isNotEmpty) {
      return neonBorderColors!;
    }
    if (isDark && enableNeonBorder) {
      return [AppColors.neonCyan, AppColors.neonMagenta, AppColors.neonBlue];
    }
    return [Colors.white];
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CONTAINER WITH GRADIENT BORDER
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Advanced version with true gradient border for stunning dark mode visuals.
/// Uses CustomPainter for precise gradient border rendering.
/// ═══════════════════════════════════════════════════════════════════════════

class GlassContainerGradientBorder extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? blurSigma;
  final double? opacity;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;
  final double borderWidth;
  final bool animate;
  final Duration animationDelay;
  final VoidCallback? onTap;

  const GlassContainerGradientBorder({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma,
    this.opacity,
    this.width,
    this.height,
    this.gradientColors,
    this.borderWidth = 2.0,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double effectiveBlur = blurSigma ?? AppColors.getBlurSigma(isDark);
    final double effectiveOpacity =
        opacity ?? AppColors.getGlassOpacity(isDark);
    final double effectiveRadius = borderRadius ?? AppDimensions.radiusLG;

    final List<Color> colors =
        gradientColors ??
        (isDark
            ? [AppColors.neonCyan, AppColors.neonMagenta, AppColors.neonBlue]
            : [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.2)]);

    Widget container = Container(
      width: width,
      height: height,
      margin: margin,
      child: CustomPaint(
        painter: _GradientBorderPainter(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: effectiveRadius,
          borderWidth: borderWidth,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: effectiveBlur,
              sigmaY: effectiveBlur,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getGlassSurface(
                  isDark,
                ).withOpacity(effectiveOpacity),
                borderRadius: BorderRadius.circular(effectiveRadius),
              ),
              padding:
                  padding ?? EdgeInsets.all(AppDimensions.glassInnerPadding),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      container = GestureDetector(onTap: onTap, child: container);
    }

    if (animate) {
      return container
          .animate(delay: animationDelay)
          .fadeIn(
            duration: Duration(milliseconds: AppDimensions.animationNormal),
          )
          .scale(
            begin: const Offset(0.95, 0.95),
            duration: Duration(milliseconds: AppDimensions.animationNormal),
          );
    }

    return container;
  }
}

/// Custom painter for gradient border
class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderRadius;
  final double borderWidth;

  _GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth;
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CONTAINER PRESETS
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Pre-configured glass containers for common use cases.
/// ═══════════════════════════════════════════════════════════════════════════

/// Card-style glass container (for product cards, etc.)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Duration animationDelay;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: padding ?? EdgeInsets.all(12.w),
      margin: margin ?? EdgeInsets.all(8.w),
      borderRadius: AppDimensions.radiusLG,
      width: width,
      height: height,
      enableNeonBorder: true,
      enableNeonGlow: true,
      glowBlur: 10,
      glowSpread: 1,
      animationDelay: animationDelay,
      onTap: onTap,
      child: child,
    );
  }
}

/// Subtle glass container (less prominent, for backgrounds)
class GlassContainerSubtle extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainerSubtle({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: padding,
      margin: margin,
      blurSigma: isDark ? 8 : 12,
      opacity: isDark ? 0.15 : 0.15,
      enableNeonBorder: false,
      animate: false,
      child: child,
    );
  }
}

/// Prominent glass container (for featured content)
class GlassContainerFeatured extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Duration animationDelay;

  const GlassContainerFeatured({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainerGradientBorder(
      padding: padding ?? EdgeInsets.all(20.w),
      margin: margin ?? EdgeInsets.all(12.w),
      borderRadius: AppDimensions.radiusXL,
      borderWidth: isDark ? 2.5 : 1.5,
      animationDelay: animationDelay,
      child: child,
    );
  }
}
