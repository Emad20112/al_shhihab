import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart'; // ✅ تم الاستيراد
import '../../core/providers/cart_provider.dart';
import '../../data/dummy_data.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: _buildBottomBar(context, ref, isDark, isArabic),
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
                    ? [AppColors.darkGradientStart, AppColors.darkGradientMiddle, AppColors.darkGradientEnd]
                    : [AppColors.lightGradientStart, AppColors.lightGradientMiddle, AppColors.lightGradientEnd],
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
                    ? [AppColors.neonCyan.withValues(alpha: 0.1), Colors.transparent]
                    : [AppColors.lightAccent.withValues(alpha: 0.08), Colors.transparent],
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
      // ✅ استبدال 16.w و 8.h بـ spacingMD و spacingXS
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD, 
        vertical: AppDimensions.spacingXS
      ),
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
              SizedBox(width: AppDimensions.spacingXS), // ✅ 8.w
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
    .fadeIn(duration: const Duration(milliseconds: AppDimensions.animationNormal))
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
        // ✅ استبدال 14.r بـ radiusSM (12) لتوحيد الانحناءات
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44.w, // حجم زر مخصص، يمكن إبقاؤه أو استخدام buttonHeightSM
            height: 44.w,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM), // ✅
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
                width: AppDimensions.glassBorderWidth, // ✅ استخدام السمك الموحد
              ),
            ),
            child: Icon(
              icon,
              size: 22.w, // يمكن استخدام iconMD (24) أو تركه
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
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
      // ✅ استبدال 40.w بـ spacingXXL (48) أو spacingXL (32) - اخترنا XL للتقريب
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXL, 
        vertical: AppDimensions.spacingMD // ✅ 16.h
      ),
      child: Hero(
        tag: 'product_${product.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL), // ✅ 24.r -> radiusXL
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL), // ✅
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkGlassSurface : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL), // ✅
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
                  color: isDark ? AppColors.darkGlassSurface : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL), // ✅
                ),
                child: Icon(
                  Icons.devices_rounded,
                  size: 80.w, // حجم كبير خاص
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(
      delay: const Duration(milliseconds: 200), // يمكن استخدام animationFast
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
    )
    .scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      delay: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
      curve: Curves.easeOutBack,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GLASS DETAIL SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDetailSheet(BuildContext context, bool isDark, bool isArabic) {
    return ClipRRect(
      // ✅ استبدال 32.r بـ radiusXXL
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXXL)),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppColors.getBlurSigma(isDark),
          sigmaY: AppColors.getBlurSigma(isDark),
        ),
        child: Container(
          width: double.infinity,
          // ✅ استبدال الحشوات بـ spacingLG (24) و spacingLG للـ 20 لتوحيدها
          padding: EdgeInsets.fromLTRB(
            AppDimensions.spacingLG, 
            AppDimensions.spacingLG, 
            AppDimensions.spacingLG, 
            120.h
          ),
          decoration: BoxDecoration(
            color: AppColors.getGlassSurface(isDark).withValues(alpha: AppColors.getGlassOpacity(isDark) + 0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXXL)), // ✅
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
                width: AppDimensions.glassBorderWidth, // ✅
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
                    color: (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              SizedBox(height: AppDimensions.spacingLG), // ✅ 20.h -> 24

              // Category & Rating row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingSM, vertical: 6.h), // ✅ 12.w -> SM
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.neonMagenta.withValues(alpha: 0.2)
                          : AppColors.lightAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG), // ✅ 20.r
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
                        color: isDark ? AppColors.neonMagenta : AppColors.lightAccent,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  // Rating
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: AppDimensions.iconSM, color: AppColors.neonOrange), // ✅ 20.w
                      SizedBox(width: 4.w),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${product.reviewCount})',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: AppDimensions.spacingMD), // ✅ 16.h

              // Product name
              Text(
                isArabic ? product.nameAr : product.name,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),

              SizedBox(height: AppDimensions.spacingMD), // ✅ 16.h

              // Description
              Text(
                isArabic ? product.descriptionAr : product.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),

              SizedBox(height: AppDimensions.spacingLG), // ✅ 24.h

              // Specs section
              if (product.specs.isNotEmpty) ...[
                Text(
                  'specs'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingSM), // ✅ 12.h
                _buildSpecsGrid(context, isDark),
              ],

              SizedBox(height: AppDimensions.spacingLG), // ✅ 24.h

              // Color options (if available)
              if (product.colors.isNotEmpty) ...[
                Text(
                  'available_colors'.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingSM), // ✅ 12.h
                _buildColorOptions(context, isDark),
              ],
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(
      delay: const Duration(milliseconds: AppDimensions.animationNormal),
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
    )
    .slideY(
      begin: 0.2,
      end: 0,
      delay: const Duration(milliseconds: AppDimensions.animationNormal),
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
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
        // ✅ استبدال 12.r بـ radiusSM
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
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
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
    .fadeIn(duration: const Duration(milliseconds: AppDimensions.animationNormal))
    .scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
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
          // ✅ استبدال 12.w بـ spacingSM
          margin: EdgeInsets.only(right: AppDimensions.spacingSM),
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
        .fadeIn(duration: const Duration(milliseconds: AppDimensions.animationNormal))
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: AppDimensions.animationNormal),
          curve: Curves.easeOutBack,
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOTTOM ACTION BAR
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    bool isArabic,
  ) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          // ✅ توحيد الحشوات بـ spacingSM (10/12) و spacingMD (16)
          padding: EdgeInsets.fromLTRB(
            AppDimensions.spacingSM, 
            AppDimensions.spacingMD, 
            AppDimensions.spacingSM, 
            28.h + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.getGlassSurface(isDark).withValues(alpha: AppColors.getGlassOpacity(isDark) + 0.2),
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
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingXS), // ✅ 8.w
                        ],
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                            shadows: isDark
                                ? [
                                    Shadow(
                                      color: AppColors.neonCyan.withValues(alpha: 0.5),
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
                  ref.read(cartProvider.notifier).addItem(product);
                  final itemCount = ref.read(cartItemCountProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: isDark ? AppColors.darkGradientStart : Colors.white,
                            size: AppDimensions.iconSM, // ✅ 20.w
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              '${isArabic ? product.nameAr : product.name} ${'added_to_cart'.tr()}',
                              style: TextStyle(
                                color: isDark ? AppColors.darkGradientStart : Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkGradientStart.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSM), // ✅ 12.r
                            ),
                            child: Text(
                              '$itemCount',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkGradientStart : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM), // ✅ 12.r
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 13.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.neonCyan, AppColors.neonBlue]
                          : [AppColors.lightAccent, AppColors.lightAccentSecondary],
                    ),
                    // ✅ استبدال 16.r بـ radiusMD
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppColors.neonCyan : AppColors.lightAccent)
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
                        size: AppDimensions.iconSM, // ✅ 20.w
                        color: isDark ? AppColors.darkGradientStart : Colors.white,
                      ),
                      SizedBox(width: AppDimensions.spacingXS), // ✅ 8.w
                      Text(
                        'add_to_cart'.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkGradientStart : Colors.white,
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
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
    )
    .slideY(
      begin: 1,
      end: 0,
      delay: const Duration(milliseconds: 400),
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
      curve: Curves.easeOutCubic,
    );
  }
}