import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart'; // ✅ تم الاستيراد
import '../../core/providers/app_providers.dart';
import '../../data/dummy_data.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/glass_product_card.dart';
import '../products/product_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseMedia = MediaQuery.of(context);

    return MediaQuery(
      data: baseMedia.copyWith(textScaleFactor: 1.0),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glass App Bar
          SliverToBoxAdapter(
            child: GlassAppBar(
              userName: 'TechVault',
              notificationCount: 3,
              onSearchTap: () {
                // TODO: Navigate to search
              },
              onNotificationTap: () {
                // TODO: Show notifications
              },
            ),
          ),

          // Spacer
          // ✅ استبدال 16.h بـ spacingMD
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingMD)),

          // Section A: Hero Carousel
          SliverToBoxAdapter(child: _buildHeroCarousel(context, isDark)),

          // Spacer
          // ✅ استبدال 28.h بـ spacingXL (32) لتوحيد التباعد بين الأقسام
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingXL)),

          // Section B: Categories
          SliverToBoxAdapter(
            child: _buildCategoriesSection(context, isDark, ref),
          ),

          // Spacer
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingXL)),

          // Section Header: Featured Products
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              isDark,
              title: 'featured_products'.tr(),
              onViewAll: () {
                // TODO: Navigate to all products
              },
            ),
          ),

          // Section C: Featured Products Grid
          _buildFeaturedProductsGrid(context, isDark),

          // Bottom padding for nav bar
          // ✅ مسافة كبيرة مخصصة للنافيجيشن، يمكن إبقاؤها أو استخدام spacingHuge * 2
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION A: 3D HERO CAROUSEL
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroCarousel(BuildContext context, bool isDark) {
    final heroProducts = featuredProducts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
              // ✅ استبدال 20.w بـ spacingLG (24) لتوحيد الهوامش
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLG),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'discover'.tr(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h), // مسافة صغيرة جداً (spacingXXS)
                        Text(
                          'flash_deals'.tr(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppDimensions.spacingXS), // ✅ 8.w
                  // Animated dots indicator
                  _buildCarouselIndicator(isDark, heroProducts.length, 0),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: const Duration(milliseconds: AppDimensions.animationNormal))
            .slideX(begin: -0.1, end: 0),

        SizedBox(height: AppDimensions.spacingLG), // ✅ 20.h -> spacingLG (24)

        // Hero carousel
        SizedBox(
          height: 340.h, // ارتفاع مخصص للـ Carousel
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.8),
            itemCount: heroProducts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingXS), // ✅ 8.w
                child: HeroProductCard(
                  product: heroProducts[index],
                  animationDelay: Duration(milliseconds: 100 * index),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ProductDetailScreen(product: heroProducts[index]),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: AppDimensions.animationNormal),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselIndicator(bool isDark, int count, int current) {
    return Row(
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: AppDimensions.animationFast), // ✅ 200ms
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 24.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r), // نصف قطر صغير مخصص
            color: isActive
                ? (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                      .withValues(alpha: 0.3),
            boxShadow: isActive && isDark
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION B: CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCategoriesSection(
    BuildContext context,
    bool isDark,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _buildSectionHeader(
          context,
          isDark,
          title: 'all_categories'.tr(),
          onViewAll: () {
            ref.read(navigationProvider.notifier).goToCategories();
          },
        ),

        SizedBox(height: AppDimensions.spacingMD), // ✅ 16.h

        // Categories horizontal list
        SizedBox(
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // ✅ spacingLG (24) أو MD (16)
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMD), 
            itemCount: dummyCategories.length,
            itemBuilder: (context, index) {
              final category = dummyCategories[index];
              return _buildCategoryItem(context, isDark, category, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    bool isDark,
    CategoryModel category,
    int index,
  ) {
    final isArabic = context.locale.languageCode == 'ar';

    return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w), // مسافة صغيرة بين العناصر
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to category
            },
            child: Column(
              children: [
                // Glass circle with icon
                Container(
                  width: 70.w, // حجم ثابت للأيقونة
                  height: 70.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? category.color.withValues(alpha: 0.15)
                        : category.color.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isDark
                          ? category.color.withValues(alpha: 0.5)
                          : category.color.withValues(alpha: 0.3),
                      width: isDark ? 2 : 1.5,
                    ),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Center(
                        child: Icon(
                          category.icon,
                          size: 30.w, // يمكن استخدام iconLG
                          color: category.color,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppDimensions.spacingXS), // ✅ 8.h

                // Category name
                Text(
                  isArabic ? category.nameAr : category.name,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
        // ✅ استخدام staggerDelay الموحد
        .animate(delay: Duration(milliseconds: AppDimensions.staggerDelay * index))
        .fadeIn(duration: const Duration(milliseconds: AppDimensions.animationNormal))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: AppDimensions.animationNormal),
          curve: Curves.easeOutBack,
        );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION C: FEATURED PRODUCTS GRID
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFeaturedProductsGrid(BuildContext context, bool isDark) {
    final products = dummyProducts;

    return SliverPadding(
      // ✅ spacingMD (16)
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMD), 
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppDimensions.spacingMD, // ✅ 16.h
          crossAxisSpacing: AppDimensions.spacingSM, // ✅ 12.w
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return GlassProductCard(
            product: product,
            animationDelay: Duration(milliseconds: 80 * index),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProductDetailScreen(product: product),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  transitionDuration: const Duration(milliseconds: AppDimensions.animationNormal),
                ),
              );
            },
            onAddToCart: () {
              // TODO: Add to cart
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart'),
                  backgroundColor: isDark
                      ? AppColors.neonCyan
                      : AppColors.lightAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM), // ✅ 10 -> 12
                  ),
                ),
              );
            },
          );
        }, childCount: products.length),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark, {
    required String title,
    VoidCallback? onViewAll,
  }) {
    return Padding(
          // ✅ spacingLG (24) أو 20 حسب التفضيل، وحدناها هنا بـ LG
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLG),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSM, // ✅ 12.w
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.neonCyan.withValues(alpha: 0.1)
                          : AppColors.lightAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG), // ✅ 20.r
                      border: Border.all(
                        color: isDark
                            ? AppColors.neonCyan.withValues(alpha: 0.3)
                            : AppColors.lightAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'view_all'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.neonCyan
                                : AppColors.lightAccent,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14.w, // يمكن استخدام iconXS (16) أو تركها صغيرة
                          color: isDark
                              ? AppColors.neonCyan
                              : AppColors.lightAccent,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: AppDimensions.animationNormal))
        .slideX(begin: -0.05, end: 0);
  }
}