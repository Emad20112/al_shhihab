import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS SETTING TILE - Premium Glassmorphism Settings Tile
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A reusable settings tile with glass background featuring:
/// • BackdropFilter blur effect
/// • Leading icon with neon color in dark mode
/// • Title and optional subtitle
/// • Trailing widget (Switch, arrow, or custom)
/// • Staggered entry animation
/// ═══════════════════════════════════════════════════════════════════════════

class GlassSettingTile extends StatelessWidget {
  /// Leading icon
  final IconData icon;

  /// Icon color (uses neon cyan in dark mode if not specified)
  final Color? iconColor;

  /// Main title text
  final String title;

  /// Optional subtitle text
  final String? subtitle;

  /// Trailing widget (e.g., Switch, Icon, or custom widget)
  final Widget? trailing;

  /// Called when the tile is tapped
  final VoidCallback? onTap;

  /// Animation delay for staggered entry
  final Duration animationDelay;

  /// Whether to show a divider at the bottom
  final bool showDivider;

  /// Custom border radius
  final double? borderRadius;

  const GlassSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.animationDelay = Duration.zero,
    this.showDivider = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double effectiveRadius = borderRadius ?? AppDimensions.radiusLG;
    final Color effectiveIconColor =
        iconColor ?? (isDark ? AppColors.neonCyan : AppColors.lightAccent);

    Widget tile = Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD,
        vertical: AppDimensions.spacingXS / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveRadius),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? 15 : 20,
            sigmaY: isDark ? 15 : 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkGlassSurface.withOpacity(0.35)
                  : Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(effectiveRadius),
              border: Border.all(
                color: isDark
                    ? effectiveIconColor.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
                width: isDark ? 1.5 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(effectiveRadius),
                splashColor: effectiveIconColor.withOpacity(0.1),
                highlightColor: effectiveIconColor.withOpacity(0.05),
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingMD),
                  child: Row(
                    children: [
                      // Leading icon container
                      _buildIconContainer(isDark, effectiveIconColor),

                      SizedBox(width: AppDimensions.spacingMD),

                      // Title and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: 2.h),
                              Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Trailing widget
                      if (trailing != null) trailing!,

                      // Default arrow if no trailing and has onTap
                      if (trailing == null && onTap != null)
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                          size: 24.w,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Apply animation
    return tile
        .animate(delay: animationDelay)
        .fadeIn(
          duration: Duration(milliseconds: AppDimensions.animationNormal),
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.05,
          end: 0,
          duration: Duration(milliseconds: AppDimensions.animationNormal),
          curve: Curves.easeOut,
        );
  }

  Widget _buildIconContainer(bool isDark, Color iconColor) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: iconColor.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: iconColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: iconColor, size: 22.w),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS SETTING SECTION - Groups multiple tiles together
/// ═══════════════════════════════════════════════════════════════════════════

class GlassSettingSection extends StatelessWidget {
  /// Section title
  final String? title;

  /// Child tiles
  final List<Widget> children;

  /// Animation delay for the section header
  final Duration animationDelay;

  const GlassSettingSection({
    super.key,
    this.title,
    required this.children,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
                padding: EdgeInsets.only(
                  left: AppDimensions.spacingLG,
                  right: AppDimensions.spacingLG,
                  bottom: AppDimensions.spacingSM,
                ),
                child: Text(
                  title!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark
                        ? AppColors.neonCyan.withOpacity(0.7)
                        : AppColors.lightAccent.withOpacity(0.8),
                  ),
                ),
              )
              .animate(delay: animationDelay)
              .fadeIn(
                duration: Duration(milliseconds: AppDimensions.animationNormal),
              )
              .slideX(begin: -0.05, end: 0),
        ...children,
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS TOGGLE SWITCH - Premium styled switch
/// ═══════════════════════════════════════════════════════════════════════════

class GlassToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const GlassToggleSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.neonCyan : AppColors.lightAccent;
    final inactiveColor = isDark
        ? AppColors.darkTextMuted.withOpacity(0.3)
        : AppColors.lightTextMuted.withOpacity(0.3);

    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      activeTrackColor: activeColor.withOpacity(0.3),
      inactiveThumbColor: isDark
          ? AppColors.darkTextMuted
          : AppColors.lightTextMuted,
      inactiveTrackColor: inactiveColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
