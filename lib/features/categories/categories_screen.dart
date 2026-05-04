import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/dummy_data.dart';
import '../shop/providers/shop_providers.dart';

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
    final categories =
        ref.watch(shopCategoriesProvider).value ?? dummyCategories;
    final products = ref.watch(shopProductsProvider).value ?? dummyProducts;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header with back button
        SliverToBoxAdapter(child: _buildHeader(context, isDark)),

        // Spacer
        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingLG)),

        // Categories Grid
        _buildCategoriesGrid(context, isDark, categories, products),

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
              // Back button row
              if (Navigator.of(context).canPop())
                Padding(
                  padding: EdgeInsets.only(bottom: AppDimensions.spacingSM),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 20.w,
                          color: isDark
                              ? AppColors.neonCyan
                              : AppColors.lightAccent,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'back'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.neonCyan
                                : AppColors.lightAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildCategoriesGrid(
    BuildContext context,
    bool isDark,
    List<CategoryModel> categories,
    List<ProductModel> products,
  ) {
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
          final category = categories[index];
          return GlassCategoryCard(
            category: category,
            productCount: products
                .where((product) => product.category == category.id)
                .length,
            animationDelay: Duration(
              milliseconds: (AppDimensions.staggerDelay * index).clamp(0, 400),
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
        }, childCount: categories.length),
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CATEGORY CARD - Individual Category Display
/// ═══════════════════════════════════════════════════════════════════════════

class GlassCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int productCount;
  final Duration animationDelay;
  final VoidCallback? onTap;

  const GlassCategoryCard({
    super.key,
    required this.category,
    required this.productCount,
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
                  color: category.color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Background Image
            Image.network(
              category.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: isDark
                    ? AppColors.darkGlassSurface
                    : AppColors.lightGlassSurface,
              ),
            ),

            // 2. Gradient Overlay for readability and premium look
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          Colors.transparent,
                          category.color.withValues(alpha: 0.2),
                          AppColors.darkGradientStart.withValues(alpha: 0.95),
                        ]
                      : [
                          Colors.transparent,
                          category.color.withValues(alpha: 0.1),
                          AppColors.lightGradientStart.withValues(alpha: 0.95),
                        ],
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),

            // 3. Subtle Glass Blur Effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5), // subtle blur
              child: Container(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),

            // 4. Elegant Glass Border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                border: Border.all(
                  color: isDark
                      ? category.color.withValues(alpha: 0.6)
                      : category.color.withValues(alpha: 0.4),
                  width: AppDimensions.glassBorderWidth > 0
                      ? AppDimensions.glassBorderWidth
                      : 1.5,
                ),
              ),
            ),

            // 5. InkWell for touch effects and Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: category.color.withValues(alpha: 0.3),
                highlightColor: category.color.withValues(alpha: 0.1),
                child: Padding(
                  padding: EdgeInsets.all(
                    AppDimensions.spacingSM,
                  ), // تم تقليله لمنع الـ Overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Icon inside a frosted circle
                      Align(
                        alignment: isArabic
                            ? Alignment.topLeft
                            : Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(8.w), // تصغير الـ padding
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: category.color.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            boxShadow: isDark
                                ? [
                                    BoxShadow(
                                      color: category.color.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            category.icon,
                            color: isDark
                                ? category.color
                                : category.color.withValues(alpha: 0.9),
                            size: 24.w, // تصغير الأيقونة
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Title
                      Text(
                        isArabic ? category.nameAr : category.name,
                        style: TextStyle(
                          fontSize: 15.sp, // تصغير حجم الخط
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          letterSpacing: 0.5,
                          shadows: isDark
                              ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // Decorative glowing divider line
                      Container(
                        height: 2.h,
                        width: 30.w,
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: category.color,
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      // Product Count
                      Text(
                        '$productCount ${'products'.tr()}',
                        style: TextStyle(
                          fontSize: 12.sp, // تصغير حجم خط المنتجات
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.85)
                              : AppColors.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
        .slideY(
          begin: 0.15,
          end: 0,
          duration: Duration(milliseconds: AppDimensions.animationSlow),
          curve: Curves.easeOutBack,
        );
  }
}
