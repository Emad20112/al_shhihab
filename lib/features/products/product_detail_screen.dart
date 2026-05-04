import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/utils/responsive_layout.dart';
import '../../data/dummy_data.dart';
import '../../widgets/rfq_bottom_sheet.dart';

class ProductDetailScreen extends ConsumerWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final productName = isArabic ? product.nameAr : product.name;
    final background = isDark
        ? const Color(0xFF080A0D)
        : const Color(0xFFF7F4EA);
    final horizontalPadding = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: _PurchaseBar(product: product),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            return Center(
              child: ConstrainedBox(
                constraints: ResponsiveLayout.pageConstraints(context),
                child: isWide
                    ? _WideProductView(
                        product: product,
                        productName: productName,
                        horizontalPadding: horizontalPadding,
                      )
                    : _CompactProductView(
                        product: product,
                        productName: productName,
                        horizontalPadding: horizontalPadding,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompactProductView extends StatelessWidget {
  final ProductModel product;
  final String productName;
  final double horizontalPadding;

  const _CompactProductView({
    required this.product,
    required this.productName,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _ProductGallery(
            product: product,
            height: ResponsiveLayout.productHeroHeight(context),
            overlay: _TopActions(product: product),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            18.h,
            horizontalPadding,
            110.h,
          ),
          sliver: SliverToBoxAdapter(
            child: _ProductInfo(product: product, productName: productName),
          ),
        ),
      ],
    );
  }
}

class _WideProductView extends StatelessWidget {
  final ProductModel product;
  final String productName;
  final double horizontalPadding;

  const _WideProductView({
    required this.product,
    required this.productName,
    required this.horizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        20.h,
        horizontalPadding,
        112.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: _ProductGallery(
              product: product,
              height: ResponsiveLayout.productHeroHeight(context),
              overlay: _TopActions(product: product),
            ),
          ),
          SizedBox(width: 28.w),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _ProductInfo(product: product, productName: productName),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActions extends StatelessWidget {
  final ProductModel product;

  const _TopActions({required this.product});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return PositionedDirectional(
      top: 12.h,
      start: 12.w,
      end: 12.w,
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          _RoundIconButton(
            icon: Icons.ios_share_rounded,
            tooltip: isArabic ? 'مشاركة' : 'Share',
            onTap: () {},
          ),
          SizedBox(width: 8.w),
          _RoundIconButton(
            icon: Icons.favorite_border_rounded,
            tooltip: 'added_to_wishlist'.tr(),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('added_to_wishlist'.tr()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.68),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 42.w.clamp(40, 46).toDouble(),
            height: 42.w.clamp(40, 46).toDouble(),
            child: Icon(
              icon,
              size: 21.sp,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductGallery extends StatelessWidget {
  final ProductModel product;
  final double height;
  final Widget overlay;

  const _ProductGallery({
    required this.product,
    required this.height,
    required this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111418) : Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'product-${product.id}',
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => ColoredBox(
                color: isDark
                    ? const Color(0xFF15191F)
                    : const Color(0xFFEFE8D6),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.neonCyan,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => ColoredBox(
                color: isDark
                    ? const Color(0xFF15191F)
                    : const Color(0xFFEFE8D6),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: isDark ? Colors.white54 : Colors.black38,
                  size: 42.sp,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.34),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.22),
                  ],
                ),
              ),
            ),
          ),
          overlay,
          PositionedDirectional(
            start: 16.w,
            bottom: 16.h,
            child: _AvailabilityPill(product: product),
          ),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final ProductModel product;
  final String productName;

  const _ProductInfo({required this.product, required this.productName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final mutedColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _SmallTag(label: product.category),
            if (product.isNew) _SmallTag(label: 'NEW'),
            if (product.discountPercent != null)
              _SmallTag(label: '${product.discountPercent}%-'),
          ],
        ),
        SizedBox(height: 14.h),
        Text(
          productName,
          style: TextStyle(
            color: textColor,
            fontSize: 28.sp.clamp(24, 34).toDouble(),
            height: 1.15,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _RatingBadge(product: product),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                '${product.reviewCount} ${'reviews'.tr()}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: mutedColor, fontSize: 12.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        _PriceBlock(product: product),
        SizedBox(height: 22.h),
        _Section(
          title: 'description'.tr(),
          child: Text(
            isArabic ? product.descriptionAr : product.description,
            style: TextStyle(
              color: mutedColor,
              fontSize: 14.sp,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (product.colors.isNotEmpty) ...[
          SizedBox(height: 20.h),
          _Section(
            title: 'available_colors'.tr(),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: product.colors.map(_ColorDot.new).toList(),
            ),
          ),
        ],
        if (product.specs.isNotEmpty) ...[
          SizedBox(height: 20.h),
          _Section(
            title: 'specs'.tr(),
            child: Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: product.specs.entries
                  .map(
                    (entry) => _SpecTile(label: entry.key, value: entry.value),
                  )
                  .toList(),
            ),
          ),
        ],
        SizedBox(height: 20.h),
        _PromiseStrip(product: product),
      ],
    );
  }
}

class _SmallTag extends StatelessWidget {
  final String label;

  const _SmallTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  final ProductModel product;

  const _AvailabilityPill({required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: inStock ? AppColors.neonCyan : AppColors.error,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            inStock ? 'in_stock'.tr() : 'out_of_stock'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final ProductModel product;

  const _RatingBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 16.sp, color: AppColors.neonCyan),
          SizedBox(width: 4.w),
          Text(
            product.rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.neonCyan,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  final ProductModel product;

  const _PriceBlock({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final unit = isArabic ? product.unitAr : product.unit;
    final priceColor = isDark ? Colors.white : AppColors.lightTextPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              '\$${product.price.toStringAsFixed(0)} / $unit',
              style: TextStyle(
                color: priceColor,
                fontSize: 26.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        if (product.originalPrice != null) ...[
          SizedBox(width: 12.w),
          Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              '\$${product.originalPrice!.toStringAsFixed(0)}',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 10.h),
        child,
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final String hex;

  const _ColorDot(this.hex);

  @override
  Widget build(BuildContext context) {
    final color = _parseHexColor(hex);
    return Container(
      width: 34.w.clamp(32, 38).toDouble(),
      height: 34.w.clamp(32, 38).toDouble(),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.computeLuminance() > 0.72
              ? Colors.black.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.30),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Color _parseHexColor(String value) {
    final clean = value.replaceAll('#', '');
    if (clean.length != 6) return AppColors.neonCyan;
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class _SpecTile extends StatelessWidget {
  final String label;
  final String value;

  const _SpecTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: ResponsiveLayout.isCompact(context) ? double.infinity : 220.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.055)
            : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.neonCyan,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AppColors.lightTextMuted,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontSize: 13.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromiseStrip extends StatelessWidget {
  final ProductModel product;

  const _PromiseStrip({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final promises = [
      (Icons.local_shipping_rounded, 'free_shipping'.tr()),
      (
        Icons.inventory_2_rounded,
        '${product.stockCount} ${isArabic ? 'بالمخزون' : 'left'}',
      ),
      (Icons.verified_user_rounded, isArabic ? 'دفع آمن' : 'Secure checkout'),
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: promises.map((promise) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(promise.$1, color: AppColors.neonCyan, size: 18.sp),
              SizedBox(width: 7.w),
              Text(
                promise.$2,
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PurchaseBar extends ConsumerWidget {
  final ProductModel product;

  const _PurchaseBar({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final unit = isArabic ? product.unitAr : product.unit;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          ResponsiveLayout.horizontalPadding(context),
          10.h,
          ResponsiveLayout.horizontalPadding(context),
          10.h,
        ),
        decoration: BoxDecoration(
          color: (isDark ? const Color(0xFF111820) : Colors.white).withValues(
            alpha: 0.96,
          ),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: ResponsiveLayout.pageConstraints(context),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '\$${product.price.toStringAsFixed(0)} / $unit',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              _QuoteButton(product: product),
              SizedBox(width: 10.w),
              FilledButton.icon(
                onPressed: product.inStock
                    ? () {
                        ref.read(cartProvider.notifier).addItem(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('product_added'.tr()),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text('add_to_cart'.tr()),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonCyan,
                  foregroundColor: const Color(0xFF111111),
                  disabledBackgroundColor: Colors.grey.withValues(alpha: 0.35),
                  minimumSize: Size(132.w, 48.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteButton extends StatelessWidget {
  final ProductModel product;

  const _QuoteButton({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: 'request_quote'.tr(),
      child: Material(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => RFQBottomSheet(product: product),
            );
          },
          child: SizedBox(
            width: 50.w,
            height: 48.h,
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              size: 21.sp,
            ),
          ),
        ),
      ),
    );
  }
}
