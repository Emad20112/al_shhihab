import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/providers/app_providers.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS BOTTOM NAVIGATION - Premium Floating Navigation Bar
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A floating glassmorphism bottom navigation bar.
///
/// • Light Mode: Frosted glass with bold active icon
/// • Dark Mode: Smoked glass with NEON GLOW behind active icon
/// ═══════════════════════════════════════════════════════════════════════════

class GlassBottomNav extends ConsumerStatefulWidget {
  /// Callback when a nav item is tapped
  final Function(int)? onItemTapped;

  /// Navigation items
  final List<GlassNavItem> items;

  /// Custom height
  final double? height;

  /// Custom margin
  final EdgeInsetsGeometry? margin;

  /// Enable entry animation
  final bool animate;

  const GlassBottomNav({
    super.key,
    this.onItemTapped,
    this.items = const [],
    this.height,
    this.margin,
    this.animate = true,
  });

  /// Default navigation items for the electronics store
  static List<GlassNavItem> get defaultItems => [
    const GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      labelKey: 'home',
    ),
    const GlassNavItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category_rounded,
      labelKey: 'categories',
    ),
    const GlassNavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      labelKey: 'cart',
      badgeCount: 3, // Example badge
    ),
    const GlassNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      labelKey: 'settings',
    ),
  ];

  @override
  ConsumerState<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends ConsumerState<GlassBottomNav> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(navigationProvider);
    final items = widget.items.isEmpty
        ? GlassBottomNav.defaultItems
        : widget.items;
    final height = widget.height ?? 70.h; // Fixed height

    Widget navBar = Container(
      height: height,
      margin:
          widget.margin ??
          EdgeInsets.only(left: 16.w, right: 16.w, bottom: 20.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppColors.getBlurSigma(isDark),
            sigmaY: AppColors.getBlurSigma(isDark),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.getGlassSurface(
                isDark,
              ).withValues(alpha: AppColors.getGlassOpacity(isDark) + 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.4),
                width: isDark ? 1.5 : 1,
              ),
              // Outer glow for dark mode
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: AppColors.neonCyan.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                items.length,
                (index) => _buildNavItem(
                  context,
                  items[index],
                  index,
                  currentIndex == index,
                  isDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.animate) {
      return navBar
          .animate()
          .fadeIn(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
          )
          .slideY(
            begin: 1,
            end: 0,
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
          );
    }

    return navBar;
  }

  Widget _buildNavItem(
    BuildContext context,
    GlassNavItem item,
    int index,
    bool isActive,
    bool isDark,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(navigationProvider.notifier).setIndex(index);
          widget.onItemTapped?.call(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with optional badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Neon glow background for dark mode active state
                    if (isActive && isDark)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.neonCyan.withValues(
                                  alpha: 0.6,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: AppColors.neonMagenta.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? (isDark
                                  ? AppColors.neonCyan.withValues(alpha: 0.2)
                                  : AppColors.lightAccent.withValues(
                                      alpha: 0.15,
                                    ))
                            : Colors.transparent,
                      ),
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: isActive ? 24.w : 20.w,
                        color: isActive
                            ? (isDark
                                  ? AppColors.neonCyan
                                  : AppColors.lightAccent)
                            : (isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted),
                      ),
                    ),
                    // Badge
                    if (item.badgeCount != null && item.badgeCount! > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.neonMagenta
                                : AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: AppColors.neonMagenta.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18.w,
                            minHeight: 18.w,
                          ),
                          child: Center(
                            child: Text(
                              item.badgeCount! > 99
                                  ? '99+'
                                  : item.badgeCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isActive ? 10.sp : 9.sp,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                        : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                    // Text glow for dark mode
                    shadows: isActive && isDark
                        ? [
                            Shadow(
                              color: AppColors.neonCyan.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(item.labelKey.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Data class for navigation items
class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  final int? badgeCount;

  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    this.badgeCount,
  });
}

/// ═══════════════════════════════════════════════════════════════════════════
/// FLOATING ACTION BUTTON STYLE NAV (Alternative design)
/// ═══════════════════════════════════════════════════════════════════════════

class GlassBottomNavFAB extends ConsumerWidget {
  final Function(int)? onItemTapped;
  final List<GlassNavItem> items;

  const GlassBottomNavFAB({
    super.key,
    this.onItemTapped,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ref.watch(navigationProvider);
    final navItems = items.isEmpty ? GlassBottomNav.defaultItems : items;

    return Container(
      margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 30.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 70.h,
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                navItems.length,
                (index) => _buildFABItem(
                  context,
                  ref,
                  navItems[index],
                  index,
                  currentIndex == index,
                  isDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFABItem(
    BuildContext context,
    WidgetRef ref,
    GlassNavItem item,
    int index,
    bool isActive,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(navigationProvider.notifier).setIndex(index);
        onItemTapped?.call(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 56.w : 48.w,
        height: isActive ? 56.w : 48.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? (isDark ? AppColors.neonCyan : AppColors.lightAccent)
              : Colors.transparent,
          boxShadow: isActive && isDark
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          isActive ? item.activeIcon : item.icon,
          color: isActive
              ? (isDark ? AppColors.darkGradientStart : Colors.white)
              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          size: isActive ? 28.w : 24.w,
        ),
      ),
    );
  }
}
