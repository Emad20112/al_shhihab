import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/dummy_data.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CATEGORIES SCREEN - All Categories Grid View
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Displays all available categories in a premium glassmorphism grid featuring:
/// • SliverGrid layout with GlassCategoryCard components
/// • Large glass circle icons with neon glow (dark mode)
/// • Staggered entry animations (fade + scale)
/// • Full RTL support for Arabic
/// ═══════════════════════════════════════════════════════════════════════════

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildHeader(context, isDark)),

        // Spacer
        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingLG)),

        // Categories Grid
        _buildCategoriesGrid(context, isDark),

        // Bottom padding for nav bar
        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLG,
            vertical: AppDimensions.spacingMD,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'all_categories'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppDimensions.spacingXS),
              Text(
                'browse_categories'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: Duration(milliseconds: AppDimensions.animationNormal))
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildCategoriesGrid(BuildContext context, bool isDark) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMD),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.spacingMD,
          crossAxisSpacing: AppDimensions.spacingMD,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final category = dummyCategories[index];
          return GlassCategoryCard(
            category: category,
            animationDelay: Duration(
              milliseconds: AppDimensions.staggerDelay * index,
            ),
            onTap: () {
              // TODO: Navigate to category products
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.locale.languageCode == 'ar'
                        ? 'تم اختيار ${category.nameAr}'
                        : '${category.name} selected',
                  ),
                  backgroundColor: isDark
                      ? AppColors.neonCyan
                      : AppColors.lightAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                ),
              );
            },
          );
        }, childCount: dummyCategories.length),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CATEGORY CARD - Individual Category Display
/// ═══════════════════════════════════════════════════════════════════════════

class GlassCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final Duration animationDelay;
  final VoidCallback? onTap;

  const GlassCategoryCard({
    super.key,
    required this.category,
    this.animationDelay = Duration.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isArabic = context.locale.languageCode == 'ar';

    Widget card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: category.color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  spreadRadius: -5,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? 15 : 20,
            sigmaY: isDark ? 15 : 20,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkGlassSurface.withOpacity(0.4)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(
                color: isDark
                    ? category.color.withOpacity(0.4)
                    : Colors.white.withOpacity(0.4),
                width: isDark ? AppDimensions.glassBorderWidth : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                splashColor: category.color.withOpacity(0.2),
                highlightColor: category.color.withOpacity(0.1),
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingMD),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Large Glass Circle with Icon
                      _buildIconCircle(isDark),

                      SizedBox(height: AppDimensions.spacingMD),

                      // Category Name
                      Text(
                        isArabic ? category.nameAr : category.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Product count placeholder
                      Text(
                        '${getProductsByCategory(category.id).length} ${'products'.tr()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                        textAlign: TextAlign.center,
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

    // Apply staggered animation
    return card
        .animate(delay: animationDelay)
        .fadeIn(
          duration: Duration(milliseconds: AppDimensions.animationNormal),
          curve: Curves.easeOut,
        )
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1, 1),
          duration: Duration(milliseconds: AppDimensions.animationSlow),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildIconCircle(bool isDark) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: category.color.withOpacity(isDark ? 0.15 : 0.1),
        border: Border.all(
          color: category.color.withOpacity(isDark ? 0.5 : 0.3),
          width: isDark ? 2 : 1.5,
        ),
        boxShadow: isDark
            ? [
                // Neon glow effect
                BoxShadow(
                  color: category.color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: category.color.withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ]
            : [
                BoxShadow(
                  color: category.color.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Icon(category.icon, size: 36.w, color: category.color),
          ),
        ),
      ),
    );
  }
}
