import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/providers/cart_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CART ICON - Cart Icon with Animated Badge
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Features:
/// • Glass-styled cart icon
/// • Animated item count badge
/// • Neon glow effects in dark mode
/// • Pulse animation on count change
/// ═══════════════════════════════════════════════════════════════════════════

class GlassCartIcon extends ConsumerWidget {
  /// Icon size
  final double? size;

  /// Custom color (overrides theme colors)
  final Color? color;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Show badge even when count is 0
  final bool showBadgeWhenEmpty;

  const GlassCartIcon({
    super.key,
    this.size,
    this.color,
    this.onTap,
    this.showBadgeWhenEmpty = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemCount = ref.watch(cartItemCountProvider);
    final iconSize = size ?? 24.w;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: iconSize + 12.w,
        height: iconSize + 8.h,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Cart icon
            Positioned(
              left: 0,
              bottom: 0,
              child: Icon(
                Icons.shopping_cart_rounded,
                size: iconSize,
                color:
                    color ??
                    (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary),
              ),
            ),

            // Badge
            if (itemCount > 0 || showBadgeWhenEmpty)
              Positioned(
                right: 0,
                top: 0,
                child: _CartBadge(count: itemCount, isDark: isDark),
              ),
          ],
        ),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// CART BADGE - Animated count badge
/// ═══════════════════════════════════════════════════════════════════════════

class _CartBadge extends StatelessWidget {
  final int count;
  final bool isDark;

  const _CartBadge({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();

    return ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.neonMagenta, AppColors.neonCyan]
                      : [AppColors.lightAccent, AppColors.lightAccentSecondary],
                ),
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark ? AppColors.neonMagenta : AppColors.lightAccent)
                            .withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  displayCount,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkGradientStart : Colors.white,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(
          key: ValueKey(count), // Re-animate when count changes
        )
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
        );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CART ICON BUTTON - Standalone tappable cart icon
/// ═══════════════════════════════════════════════════════════════════════════

class GlassCartIconButton extends ConsumerWidget {
  /// Callback when tapped
  final VoidCallback? onTap;

  /// Button size
  final double? size;

  const GlassCartIconButton({super.key, this.onTap, this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemCount = ref.watch(cartItemCountProvider);
    final buttonSize = size ?? 44.w;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cart icon centered
                Center(
                  child: Icon(
                    Icons.shopping_cart_rounded,
                    size: 22.w,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),

                // Badge
                if (itemCount > 0)
                  Positioned(
                    right: -4.w,
                    top: -4.h,
                    child: _CartBadge(count: itemCount, isDark: isDark),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
