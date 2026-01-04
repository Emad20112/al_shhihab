import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../data/dummy_data.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS PRODUCT CARD - Premium Product Display
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A highly detailed glassmorphism product card.
///
/// Features:
/// • Dark Mode: Dark glass with neon price tag
/// • Light Mode: White frosted glass
/// • Scale on tap animation
/// • Network image with loading placeholder
/// • Discount badge
/// ═══════════════════════════════════════════════════════════════════════════

class GlassProductCard extends StatefulWidget {
  /// Product data
  final ProductModel product;

  /// Card width
  final double? width;

  /// Card height
  final double? height;

  /// Animation delay for staggered lists
  final Duration animationDelay;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when add to cart is tapped
  final VoidCallback? onAddToCart;

  /// Show add to cart button
  final bool showAddButton;

  const GlassProductCard({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.animationDelay = Duration.zero,
    this.onTap,
    this.onAddToCart,
    this.showAddButton = true,
  });

  @override
  State<GlassProductCard> createState() => _GlassProductCardState();
}

class _GlassProductCardState extends State<GlassProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;
    final isArabic = context.locale.languageCode == 'ar';

    Widget card = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        width: widget.width ?? 170.w,
        height: widget.height ?? 240.h,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        transformAlignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppColors.getBlurSigma(isDark),
              sigmaY: AppColors.getBlurSigma(isDark),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.getGlassSurface(
                  isDark,
                ).withValues(alpha: AppColors.getGlassOpacity(isDark)),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(
                  color: isDark
                      ? (_isPressed
                            ? AppColors.neonCyan.withValues(alpha: 0.5)
                            : AppColors.neonCyan.withValues(alpha: 0.2))
                      : Colors.white.withValues(alpha: 0.4),
                  width: isDark ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? (_isPressed
                              ? AppColors.neonCyan.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.3))
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: _isPressed ? 15 : 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  _buildImageSection(context, isDark, product),

                  // Content section
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            isArabic ? product.nameAr : product.name,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const Spacer(),

                          // Price row
                          _buildPriceRow(context, isDark, product),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Add entry animation
    return card
        .animate(delay: widget.animationDelay)
        .fadeIn(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildImageSection(
    BuildContext context,
    bool isDark,
    ProductModel product,
  ) {
    return Stack(
      children: [
        // Product image
        Container(
          height: 110.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLG),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusLG),
            ),
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isDark ? AppColors.neonCyan : AppColors.lightAccent,
                    ),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.devices_rounded,
                  size: 40.w,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            ),
          ),
        ),

        // Discount badge
        if (product.discountPercent != null)
          Positioned(
            top: 8.h,
            left: 8.w,
            child: _buildDiscountBadge(isDark, product.discountPercent!),
          ),

        // New badge
        if (product.isNew)
          Positioned(top: 8.h, right: 8.w, child: _buildNewBadge(isDark)),

        // Rating
        Positioned(
          bottom: 8.h,
          right: 8.w,
          child: _buildRatingBadge(isDark, product.rating),
        ),
      ],
    );
  }

  Widget _buildDiscountBadge(bool isDark, int percent) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonMagenta : AppColors.error,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.neonMagenta.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        '-$percent%',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNewBadge(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Text(
        'NEW',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.darkGradientStart : Colors.white,
        ),
      ),
    );
  }

  Widget _buildRatingBadge(bool isDark, double rating) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12.w, color: AppColors.neonOrange),
          SizedBox(width: 2.w),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    bool isDark,
    ProductModel product,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Original price (if discounted)
              if (product.originalPrice != null)
                Text(
                  '\$${product.originalPrice!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              // Current price - NEON in dark mode
              Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                  shadows: isDark
                      ? [
                          Shadow(
                            color: AppColors.neonCyan.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),

        // Add button
        if (widget.showAddButton)
          GestureDetector(
            onTap: widget.onAddToCart,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: isDark
                    ? [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.lightAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: Icon(
                Icons.add_rounded,
                size: 20.w,
                color: isDark ? AppColors.darkGradientStart : Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// HERO PRODUCT CARD - For 3D Pop-out Carousel
/// ═══════════════════════════════════════════════════════════════════════════

class HeroProductCard extends StatefulWidget {
  final ProductModel product;
  final Duration animationDelay;
  final VoidCallback? onTap;

  const HeroProductCard({
    super.key,
    required this.product,
    this.animationDelay = Duration.zero,
    this.onTap,
  });

  @override
  State<HeroProductCard> createState() => _HeroProductCardState();
}

class _HeroProductCardState extends State<HeroProductCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;
    final isArabic = context.locale.languageCode == 'ar';

    Widget card = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        width: 260.w,
        height: 280.h,
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        transformAlignment: Alignment.center,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Glass card at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppColors.getBlurSigma(isDark),
                    sigmaY: AppColors.getBlurSigma(isDark),
                  ),
                  child: Container(
                    height: 160.h,
                    padding: EdgeInsets.fromLTRB(16.w, 50.h, 16.w, 12.h),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.darkGlassSurface.withValues(
                                  alpha: 0.6,
                                ),
                                AppColors.darkGlassSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.5),
                                Colors.white.withValues(alpha: 0.3),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXL,
                      ),
                      border: Border.all(
                        color: isDark
                            ? AppColors.neonCyan.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.5),
                        width: isDark ? 2 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? AppColors.neonCyan.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category tag
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.neonMagenta.withValues(alpha: 0.2)
                                : AppColors.lightAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.neonMagenta
                                  : AppColors.lightAccent,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // Title
                        Flexible(
                          child: Text(
                            isArabic ? product.nameAr : product.name,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // Price + Button row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.originalPrice != null)
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
                                Text(
                                  '\$${product.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.neonCyan
                                        : AppColors.lightAccent,
                                    shadows: isDark
                                        ? [
                                            Shadow(
                                              color: AppColors.neonCyan
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ],
                            ),

                            // Buy button
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.neonCyan
                                    : AppColors.lightAccent,
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? AppColors.neonCyan
                                                : AppColors.lightAccent)
                                            .withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                'buy_now'.tr(),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkGradientStart
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Product image - POPS OUT of the card
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Hero(
                tag: 'product_${product.id}',
                child: Container(
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
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
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                isDark
                                    ? AppColors.neonCyan
                                    : AppColors.lightAccent,
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
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.devices_rounded,
                            size: 60.w,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Discount badge
            if (product.discountPercent != null)
              Positioned(
                top: 12.h,
                left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.neonMagenta : AppColors.error,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: AppColors.neonMagenta.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 10,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    '-${product.discountPercent}% ${'discount'.tr()}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return card
        .animate(delay: widget.animationDelay)
        .fadeIn(duration: const Duration(milliseconds: 500))
        .slideX(
          begin: 0.1,
          end: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
  }
}
