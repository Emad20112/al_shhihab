import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../data/dummy_data.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// PRODUCT DETAIL SCREEN - Immersive Product Experience
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Features:
/// • Dynamic blurred background from product image
/// • Hero animation transition from product card
/// • Glass sheet with product details
/// • Specs displayed in glass chips
/// • Fixed bottom bar with price and Add to Cart
/// ═══════════════════════════════════════════════════════════════════════════

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkGradientStart : Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Layer 1: Blurred atmospheric background
          _buildAtmosphericBackground(context, isDark),

          // Layer 2: Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(context, isDark),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Hero product image
                        _buildHeroImage(context, isDark),

                        // Glass detail sheet
                        _buildDetailSheet(context, isDark, isArabic),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Layer 3: Fixed bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context, isDark),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ATMOSPHERIC BACKGROUND
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAtmosphericBackground(BuildContext context, bool isDark) {
    return Positioned.fill(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkGradientStart,
                        AppColors.darkGradientMiddle,
                        AppColors.darkGradientEnd,
                      ]
                    : [
                        AppColors.lightGradientStart,
                        AppColors.lightGradientMiddle,
                        AppColors.lightGradientEnd,
                      ],
              ),
            ),
          ),

          // Blurred product image overlay
          Opacity(
            opacity: isDark ? 0.4 : 0.25,
            child: Transform.scale(
              scale: 1.5,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          // Color overlay for depth
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5,
                colors: isDark
                    ? [
                        AppColors.neonCyan.withValues(alpha: 0.1),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.lightAccent.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CUSTOM APP BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              _buildGlassButton(
                context,
                isDark,
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),

              // Actions
              Row(
                children: [
                  _buildGlassButton(
                    context,
                    isDark,
                    icon: Icons.share_rounded,
                    onTap: () {
                      // TODO: Share product
                    },
                  ),
                  SizedBox(width: 8.w),
                  _buildGlassButton(
                    context,
                    isDark,
                    icon: Icons.favorite_border_rounded,
                    onTap: () {
                      // TODO: Add to favorites
                    },
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: -0.5, end: 0);
  }

  Widget _buildGlassButton(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44.w,
            height: 44.w,
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
            child: Icon(
              icon,
              size: 22.w,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HERO PRODUCT IMAGE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeroImage(BuildContext context, bool isDark) {
    return Container(
          height: 280.h,
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
          child: Hero(
            tag: 'product_${product.id}',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.neonCyan.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkGlassSurface
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            isDark ? AppColors.neonCyan : AppColors.lightAccent,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkGlassSurface
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.devices_rounded,
                      size: 80.w,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASS DETAIL SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDetailSheet(BuildContext context, bool isDark, bool isArabic) {
    return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppColors.getBlurSigma(isDark),
              sigmaY: AppColors.getBlurSigma(isDark),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
              decoration: BoxDecoration(
                color: AppColors.getGlassSurface(
                  isDark,
                ).withValues(alpha: AppColors.getGlassOpacity(isDark) + 0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.neonCyan.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkTextMuted.withValues(alpha: 0.5)
                            : AppColors.lightTextMuted.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Category & Rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.neonMagenta.withValues(alpha: 0.2)
                              : AppColors.lightAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isDark
                                ? AppColors.neonMagenta.withValues(alpha: 0.3)
                                : AppColors.lightAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.neonMagenta
                                : AppColors.lightAccent,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 20.w,
                            color: AppColors.neonOrange,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '(${product.reviewCount})',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Product name
                  Text(
                    isArabic ? product.nameAr : product.name,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Description
                  Text(
                    isArabic ? product.descriptionAr : product.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Specs section
                  if (product.specs.isNotEmpty) ...[
                    Text(
                      'specs'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildSpecsGrid(context, isDark),
                  ],

                  SizedBox(height: 24.h),

                  // Color options (if available)
                  if (product.colors.isNotEmpty) ...[
                    Text(
                      'available_colors'.tr(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildColorOptions(context, isDark),
                  ],
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.2,
          end: 0,
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildSpecsGrid(BuildContext context, bool isDark) {
    final specs = product.specs.entries.toList();
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: specs.asMap().entries.map((entry) {
        final index = entry.key;
        final spec = entry.value;
        return _buildSpecChip(context, isDark, spec.key, spec.value, index);
      }).toList(),
    );
  }

  Widget _buildSpecChip(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    int index,
  ) {
    return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkGlassSurface.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark
                  ? AppColors.neonCyan.withValues(alpha: 0.2)
                  : AppColors.lightAccent.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildColorOptions(BuildContext context, bool isDark) {
    return Row(
      children: product.colors.asMap().entries.map((entry) {
        final index = entry.key;
        final colorHex = entry.value;
        final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

        return Container(
              margin: EdgeInsets.only(right: 12.w),
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn(duration: const Duration(milliseconds: 300))
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1, 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
            );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM ACTION BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomBar(BuildContext context, bool isDark) {
    return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                10.w,
                16.h,
                10.w,
                28.h + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.getGlassSurface(
                  isDark,
                ).withValues(alpha: AppColors.getGlassOpacity(isDark) + 0.2),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.neonCyan.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Price section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'price'.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            if (product.originalPrice != null) ...[
                              Text(
                                '\$${product.originalPrice!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.neonCyan
                                    : AppColors.lightAccent,
                                shadows: isDark
                                    ? [
                                        Shadow(
                                          color: AppColors.neonCyan.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Add to Cart button
                  GestureDetector(
                    onTap: () {
                      // TODO: Add to cart
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} ${'add_to_cart'.tr()}',
                          ),
                          backgroundColor: isDark
                              ? AppColors.neonCyan
                              : AppColors.lightAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 13.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [AppColors.neonCyan, AppColors.neonBlue]
                              : [
                                  AppColors.lightAccent,
                                  AppColors.lightAccentSecondary,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isDark
                                        ? AppColors.neonCyan
                                        : AppColors.lightAccent)
                                    .withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart_rounded,
                            size: 20.w,
                            color: isDark
                                ? AppColors.darkGradientStart
                                : Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'add_to_cart'.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkGradientStart
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 1,
          end: 0,
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }
}
