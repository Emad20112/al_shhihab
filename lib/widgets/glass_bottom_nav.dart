import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/providers/app_providers.dart';
import '../core/providers/cart_provider.dart';
import '../core/utils/responsive_layout.dart';

class GlassBottomNav extends ConsumerStatefulWidget {
  final Function(int)? onItemTapped;
  final List<GlassNavItem> items;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool animate;

  const GlassBottomNav({
    super.key,
    this.onItemTapped,
    this.items = const [],
    this.height,
    this.margin,
    this.animate = true,
  });

  static List<GlassNavItem> get defaultItems => const [
    GlassNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      labelKey: 'home',
    ),
    GlassNavItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category_rounded,
      labelKey: 'categories',
    ),
    GlassNavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      labelKey: 'cart',
    ),
    GlassNavItem(
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
    final cartCount = ref.watch(cartItemCountProvider);
    final items = widget.items.isEmpty
        ? GlassBottomNav.defaultItems
        : widget.items;
    final barHeight =
        widget.height ?? ResponsiveLayout.bottomBarHeight(context);

    final minimum = widget.margin is EdgeInsets
        ? widget.margin! as EdgeInsets
        : EdgeInsets.zero;

    Widget navBar = SafeArea(
      top: false,
      minimum: minimum,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? 14 : 18,
            sigmaY: isDark ? 14 : 18,
          ),
          child: Container(
            height: barHeight,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF172331) : Colors.white)
                  .withValues(alpha: isDark ? 0.94 : 0.92),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return _buildNavItem(
                  context,
                  item,
                  index,
                  isActive: currentIndex == index,
                  isDark: isDark,
                  badgeCount: item.labelKey == 'cart'
                      ? cartCount
                      : item.badgeCount,
                );
              }),
            ),
          ),
        ),
      ),
    );

    if (!widget.animate) return navBar;

    return navBar
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 120),
          duration: const Duration(milliseconds: 300),
        )
        .slideY(
          begin: 0.35,
          end: 0,
          delay: const Duration(milliseconds: 120),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildNavItem(
    BuildContext context,
    GlassNavItem item,
    int index, {
    required bool isActive,
    required bool isDark,
    int? badgeCount,
  }) {
    final activeColor = isDark ? AppColors.neonCyan : AppColors.lightAccent;
    final mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.62)
        : AppColors.lightTextMuted;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref.read(navigationProvider.notifier).setIndex(index);
          widget.onItemTapped?.call(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            color: isActive
                ? activeColor.withValues(alpha: isDark ? 0.16 : 0.10)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 32.w.clamp(30, 36).toDouble(),
                    height: 28.h.clamp(26, 32).toDouble(),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: isActive
                          ? activeColor.withValues(alpha: isDark ? 0.22 : 0.14)
                          : Colors.transparent,
                    ),
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: isActive ? 22.sp : 21.sp,
                      color: isActive ? activeColor : mutedColor,
                    ),
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      right: -5,
                      top: -4,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 18.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.neonCyan : AppColors.error,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF172331)
                                : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF172331)
                                : Colors.white,
                            fontSize: 9.sp,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 3.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 10.sp.clamp(9, 11).toDouble(),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  height: 1.1,
                  color: isActive ? activeColor : mutedColor,
                ),
                child: Text(
                  item.labelKey.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return GlassBottomNav(
      onItemTapped: onItemTapped,
      items: items,
      animate: false,
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
    );
  }
}
