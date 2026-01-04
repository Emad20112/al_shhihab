import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../widgets/glass_container.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CART SCREEN - Shopping Cart with Glassmorphism Design
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Features:
/// • Glassmorphism cart items
/// • Swipe-to-delete with red glow
/// • Quantity controls (+/-)
/// • Fixed checkout bottom sheet
/// • Empty state with icon
/// ═══════════════════════════════════════════════════════════════════════════

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return Stack(
      children: [
        // Main content
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

        // Checkout bottom sheet (only show if cart has items)
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title with count
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
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.neonCyan.withValues(alpha: 0.2)
                            : AppColors.lightAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
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

              // Clear cart button
              if (itemCount > 0)
                GestureDetector(
                  onTap: () => _showClearCartDialog(context, ref, isDark),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 22.w,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideY(begin: -0.3, end: 0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: GlassContainer(
        padding: EdgeInsets.all(40.w),
        enableNeonGlow: isDark,
        animate: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cart icon
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.1)
                    : AppColors.lightAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 64.w,
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.7)
                    : AppColors.lightAccent.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 24.h),
            // Title
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
            SizedBox(height: 8.h),
            // Subtitle
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
            SizedBox(height: 24.h),
            // Shop now button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.neonCyan, AppColors.neonBlue]
                      : [AppColors.lightAccent, AppColors.lightAccentSecondary],
                ),
                borderRadius: BorderRadius.circular(16.r),
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
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 200.h),
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
    final tax = subtotal * 0.10; // 10% tax
    final total = subtotal + tax;

    return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20.w,
                20.h,
                20.w,
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
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtotal
                  _buildPriceRow(
                    context,
                    isDark,
                    'subtotal'.tr(),
                    subtotal,
                    isHighlighted: false,
                  ),

                  SizedBox(height: 8.h),

                  // Tax
                  _buildPriceRow(
                    context,
                    isDark,
                    'tax'.tr(),
                    tax,
                    isHighlighted: false,
                  ),

                  SizedBox(height: 12.h),

                  // Divider
                  Container(
                    height: 1,
                    color: isDark
                        ? AppColors.neonCyan.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),

                  SizedBox(height: 12.h),

                  // Total
                  _buildPriceRow(
                    context,
                    isDark,
                    'total'.tr(),
                    total,
                    isHighlighted: true,
                  ),

                  SizedBox(height: 20.h),

                  // Checkout button
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to checkout
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('checkout_coming_soon'.tr()),
                          backgroundColor: isDark
                              ? AppColors.neonCyan
                              : AppColors.lightAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_rounded,
                            size: 22.w,
                            color: isDark
                                ? AppColors.darkGradientStart
                                : Colors.white,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'checkout'.tr(),
                            style: TextStyle(
                              fontSize: 17.sp,
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
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.5,
          end: 0,
          delay: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
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
                ? (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary)
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
          ),
        ),
        Text(
          '\$${price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isHighlighted ? 24.sp : 14.sp,
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
            shadows: isHighlighted && isDark
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showClearCartDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkGradientMiddle : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'clear_cart'.tr(),
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'clear_cart_confirm'.tr(),
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: Text(
              'clear'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
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
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.red.withValues(alpha: 0.3),
                  Colors.red.withValues(alpha: 0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 24.w),
            child: Icon(Icons.delete_rounded, color: Colors.white, size: 28.w),
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppColors.getBlurSigma(isDark),
                  sigmaY: AppColors.getBlurSigma(isDark),
                ),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.getGlassSurface(
                      isDark,
                    ).withValues(alpha: AppColors.getGlassOpacity(isDark)),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.neonCyan.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Product image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.white.withValues(alpha: 0.5),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.devices_rounded,
                                size: 30.w,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 14.w),

                      // Product info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              isArabic ? product.nameAr : product.name,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 6.h),

                            // Price
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.sp,
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
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
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
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: const Duration(milliseconds: 400))
        .slideX(
          begin: 0.2,
          end: 0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildQuantityControls(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Increment button
        _buildQuantityButton(context, isDark, Icons.add_rounded, onIncrement),

        SizedBox(height: 8.h),

        // Quantity display
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.neonCyan.withValues(alpha: 0.1)
                : AppColors.lightAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isDark
                  ? AppColors.neonCyan.withValues(alpha: 0.3)
                  : AppColors.lightAccent.withValues(alpha: 0.3),
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

        SizedBox(height: 8.h),

        // Decrement button
        _buildQuantityButton(
          context,
          isDark,
          Icons.remove_rounded,
          onDecrement,
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    bool isDark,
    IconData icon,
    VoidCallback onTap,
  ) {
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
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isDark
                    ? AppColors.neonCyan.withValues(alpha: 0.3)
                    : AppColors.lightAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              icon,
              size: 18.w,
              color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
            ),
          ),
        ),
      ),
    );
  }
}
