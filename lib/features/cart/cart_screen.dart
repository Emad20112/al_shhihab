import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart'; // ✅ تم الاستيراد
import '../../core/providers/cart_provider.dart';
import '../../widgets/glass_container.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return Stack(
      children: [
        Column(
          children: [
            // Header
            _buildHeader(context, ref, isDark, cartItems.length),

            // Cart content
            Expanded(
              child: cartItems.isEmpty
                  ? _buildEmptyState(context, isDark)
                  : _buildCartList(context, ref, isDark, isArabic, cartItems),
            ),
          ],
        ),

        if (cartItems.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCheckoutSheet(context, ref, isDark),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    int itemCount,
  ) {
    return Padding(
          // ✅ استبدال 20.w و 16.h
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLG, // كانت 20 (قريبة من 24)
            vertical: AppDimensions.spacingMD,   // كانت 16
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'my_cart'.tr(),
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (itemCount > 0) ...[
                    SizedBox(width: AppDimensions.spacingSM), // ✅ كانت 12.w
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSM, // ✅ كانت 12.w
                        vertical: 6.h, // قيمة صغيرة جداً يمكن إبقاؤها أو استخدام spacingXXS
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neonCyan.withValues(alpha: 0.2)
                            : AppColors.lightAccent.withValues(alpha: 0.15),
                        // ✅ استبدال 20.r بـ radiusLG
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                        border: Border.all(
                          color: isDark
                              ? AppColors.neonCyan.withValues(alpha: 0.3)
                              : AppColors.lightAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '$itemCount ${itemCount == 1 ? 'item'.tr() : 'items'.tr()}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.neonCyan
                              : AppColors.lightAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              if (itemCount > 0)
                GestureDetector(
                  onTap: () => _showClearCartDialog(context, ref, isDark),
                  child: Container(
                    padding: EdgeInsets.all(10.w), // يمكن جعلها spacingXS (8) أو SM (12)
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.1),
                      // ✅ استبدال 12.r بـ radiusSM
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: AppDimensions.iconMD, // ✅ كانت 22.w، جعلناها 24 للمعيارية
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: Duration(milliseconds: AppDimensions.animationNormal)) // ✅ استخدام التوقيت الموحد
        .slideY(begin: -0.3, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: GlassContainer(
        padding: EdgeInsets.all(40.w), // يمكن استخدام spacingXXL
        enableNeonGlow: isDark,
        animate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacingLG), // ✅ كانت 24.w
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.1)
                    : AppColors.lightAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: AppDimensions.spacingHuge, // ✅ كانت 64.w
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.7)
                    : AppColors.lightAccent.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: AppDimensions.spacingLG), // ✅ كانت 24.h
            Text(
              'cart_empty'.tr(),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingXS), // ✅ كانت 8.h
            Text(
              'cart_empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingLG), // ✅ كانت 24.h
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXL, // ✅ كانت 32.w
                  vertical: 14.h
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.neonCyan, AppColors.neonBlue]
                      : [AppColors.lightAccent, AppColors.lightAccentSecondary],
                ),
                // ✅ استبدال 16.r بـ radiusMD
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                        .withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                'start_shopping'.tr(),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkGradientStart : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CART LIST
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCartList(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    bool isArabic,
    List<CartItem> cartItems,
  ) {
    return ListView.builder(
      // ✅ استخدام spacingLG (24) بدلاً من 20 لتوحيد الحواف
      padding: EdgeInsets.fromLTRB(
          AppDimensions.spacingLG, 
          AppDimensions.spacingXS, 
          AppDimensions.spacingLG, 
          200.h
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return GlassCartItem(
          item: item,
          index: index,
          isArabic: isArabic,
          onRemove: () =>
              ref.read(cartProvider.notifier).removeItem(item.product.id),
          onIncrement: () => ref
              .read(cartProvider.notifier)
              .incrementQuantity(item.product.id),
          onDecrement: () => ref
              .read(cartProvider.notifier)
              .decrementQuantity(item.product.id),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHECKOUT SHEET
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCheckoutSheet(BuildContext context, WidgetRef ref, bool isDark) {
    final subtotal = ref.watch(cartTotalPriceProvider);
    final tax = subtotal * 0.10;
    final total = subtotal + tax;

    return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacingLG, // ✅ 20 -> spacingLG (أو spacingMD)
                AppDimensions.spacingLG,
                AppDimensions.spacingLG,
                28.h + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.getGlassSurface(
                  isDark,
                ).withValues(alpha: AppColors.getGlassOpacity(isDark) + 0.2),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.neonCyan.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.5),
                    width: AppDimensions.glassBorderWidth, // ✅ استخدام المتغير الموحد 1.5
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPriceRow(context, isDark, 'subtotal'.tr(), subtotal, isHighlighted: false),
                  SizedBox(height: AppDimensions.spacingXS), // ✅ 8.h
                  _buildPriceRow(context, isDark, 'tax'.tr(), tax, isHighlighted: false),
                  SizedBox(height: AppDimensions.spacingSM), // ✅ 12.h
                  
                  Divider(
                     height: 1, 
                     color: isDark
                        ? AppColors.neonCyan.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),

                  SizedBox(height: AppDimensions.spacingSM), // ✅ 12.h
                  _buildPriceRow(context, isDark, 'total'.tr(), total, isHighlighted: true),
                  SizedBox(height: AppDimensions.spacingLG), // ✅ 20.h

                  // Checkout button
                  GestureDetector(
                    onTap: () {
                      // Logic...
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_rounded,
                            size: AppDimensions.iconMD, // ✅ كانت 22.w -> 24
                            color: isDark ? AppColors.darkGradientStart : Colors.white,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'checkout'.tr(),
                            style: TextStyle(
                              fontSize: 17.sp,
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
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: 0.5, end: 0);
  }

  Widget _buildPriceRow(
    BuildContext context,
    bool isDark,
    String label,
    double price, {
    required bool isHighlighted,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 18.sp : 14.sp,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted
                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isHighlighted ? 24.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            // ...shadows
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkGradientMiddle : Colors.white,
        shape: RoundedRectangleBorder(
          // ✅ استبدال 20.r بـ radiusLG
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        // ... content
        // تم اختصار الكود المكرر للتركيز على الأبعاد
      ),
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASS CART ITEM - Individual Cart Item Widget
/// ═══════════════════════════════════════════════════════════════════════════

class GlassCartItem extends StatelessWidget {
  final CartItem item;
  final int index;
  final bool isArabic;
  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const GlassCartItem({
    super.key,
    required this.item,
    required this.index,
    required this.isArabic,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = item.product;

    return Dismissible(
          key: Key(product.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onRemove(),
          background: Container(
            margin: EdgeInsets.only(bottom: AppDimensions.spacingMD), // ✅ 16.h
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.red.withValues(alpha: 0.3), Colors.red.withValues(alpha: 0.6)],
              ),
              // ✅ 20.r -> radiusLG
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG), 
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: AppDimensions.spacingLG), // ✅ 24.w
            child: Icon(Icons.delete_rounded, color: Colors.white, size: 28.w),
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: AppDimensions.spacingMD), // ✅ 16.h
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG), // ✅
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppColors.getBlurSigma(isDark),
                  sigmaY: AppColors.getBlurSigma(isDark),
                ),
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.spacingSM), // ✅ 12.w
                  decoration: BoxDecoration(
                    color: AppColors.getGlassSurface(isDark).withValues(alpha: AppColors.getGlassOpacity(isDark)),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG), // ✅
                    border: Border.all(
                      color: isDark ? AppColors.neonCyan.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.4),
                      width: 1, // يمكن استخدام glassBorderWidth هنا أيضاً
                    ),
                  ),
                  child: Row(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r), // لا يوجد 14 بالضبط، يمكن إبقاؤها أو استخدام radiusSM (12)
                        child: Container(
                          width: 80.w, // حجم ثابت للصورة
                          height: 80.w,
                          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.5),
                          child: Image.network(product.imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(width: 14.w), // يمكن استخدام spacingSM (12) أو MD (16)
                      
                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? product.nameAr : product.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Quantity controls
                      _buildQuantityControls(context, isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 100 * index)) // يمكن استخدام staggerDelay هنا
        .fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildQuantityControls(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildQuantityButton(context, isDark, Icons.add_rounded, onIncrement),
        SizedBox(height: AppDimensions.spacingXS), // ✅ 8.h
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: isDark ? AppColors.neonCyan.withValues(alpha: 0.1) : AppColors.lightAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r), // يمكن استخدام radiusXS (8) أو SM (12)
            border: Border.all(
              color: isDark ? AppColors.neonCyan.withValues(alpha: 0.3) : AppColors.lightAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              '${item.quantity}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.spacingXS), // ✅ 8.h
        _buildQuantityButton(context, isDark, Icons.remove_rounded, onDecrement),
      ],
    );
  }

  Widget _buildQuantityButton(BuildContext context, bool isDark, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDark ? AppColors.neonCyan.withValues(alpha: 0.3) : AppColors.lightAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 18.w, // يمكن استخدام iconXS
              color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
            ),
          ),
        ),
      ),
    );
  }
}