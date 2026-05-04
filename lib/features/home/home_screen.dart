import 'dart:async';
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
import '../advertising/providers/advertising_providers.dart';
import '../products/product_detail_screen.dart';
import '../search/search_screen.dart';
import '../shop/providers/shop_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseMedia = MediaQuery.of(context);
    final offersState = ref.watch(homeAdvertisementsProvider);
    final products = ref.watch(shopProductsProvider).value ?? dummyProducts;
    final categories =
        ref.watch(shopCategoriesProvider).value ?? dummyCategories;

    return MediaQuery(
      data: baseMedia.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glass App Bar
          SliverToBoxAdapter(
            child: GlassAppBar(
              userName: 'StyleHub',
              notificationCount: 3,
              onSearchTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SearchScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              onNotificationTap: () {
                // TODO: Show notifications
              },
            ),
          ),

          // Spacer
          // ✅ استبدال 16.h بـ spacingMD
          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingMD)),

          // Section A: MySQL exclusive offers
          SliverToBoxAdapter(
            child: offersState.when(
              data: (offers) => _OffersCarouselSection(
                offers: offers,
                products: products,
                isDark: isDark,
              ),
              loading: () => _OffersLoadingSection(isDark: isDark),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingXL)),

          // Section B: Categories
          SliverToBoxAdapter(
            child: _buildCategoriesSection(context, isDark, ref, categories),
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
          _buildFeaturedProductsGrid(context, isDark, products),

          // Bottom padding for nav bar
          // ✅ مسافة كبيرة مخصصة للنافيجيشن، يمكن إبقاؤها أو استخدام spacingHuge * 2
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(
    BuildContext context,
    bool isDark,
    WidgetRef ref,
    List<CategoryModel> categories,
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
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMD),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
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
      child:
          GestureDetector(
                onTap: () {
                  // TODO: Navigate to category
                },
                child: Container(
                  width: 115.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: AppColors.lightShadowMedium,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Background Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLG,
                        ),
                        child: Image.network(
                          category.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: isDark
                                    ? AppColors.darkGlassSurface
                                    : AppColors.lightGlassSurface,
                              ),
                        ),
                      ),

                      // 2. Glassmorphism Blur Effect overlay
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLG,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDark
                                    ? [
                                        category.color.withValues(alpha: 0.1),
                                        AppColors.darkGradientStart.withValues(
                                          alpha: 0.85,
                                        ),
                                      ]
                                    : [
                                        category.color.withValues(alpha: 0.05),
                                        AppColors.lightGlassSurface.withValues(
                                          alpha: 0.85,
                                        ),
                                      ],
                                stops: const [0.3, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 3. Elegant Border
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLG,
                          ),
                          border: Border.all(
                            color: isDark
                                ? category.color.withValues(alpha: 0.4)
                                : category.color.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),

                      // 4. Content
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top: Icon inside a tiny glass circle
                            Align(
                              alignment: isArabic
                                  ? Alignment.topLeft
                                  : Alignment.topRight,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: category.color.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: category.color.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 1,
                                  ),
                                  boxShadow: isDark
                                      ? [
                                          BoxShadow(
                                            color: category.color.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  category.icon,
                                  color: isDark
                                      ? category.color
                                      : category.color.withValues(alpha: 0.9),
                                  size: 22.w,
                                ),
                              ),
                            ),

                            // Bottom: Category Name
                            Text(
                              isArabic ? category.nameAr : category.name,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate(
                delay: Duration(
                  milliseconds: (AppDimensions.staggerDelay * index).clamp(
                    0,
                    400,
                  ),
                ),
              )
              .fadeIn(
                duration: const Duration(
                  milliseconds: AppDimensions.animationNormal,
                ),
              )
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutBack),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION C: FEATURED PRODUCTS GRID
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildFeaturedProductsGrid(
    BuildContext context,
    bool isDark,
    List<ProductModel> products,
  ) {
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
                  transitionDuration: const Duration(
                    milliseconds: AppDimensions.animationNormal,
                  ),
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
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSM,
                    ), // ✅ 10 -> 12
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLG,
                      ), // ✅ 20.r
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
        .fadeIn(
          duration: const Duration(milliseconds: AppDimensions.animationNormal),
        )
        .slideX(begin: -0.05, end: 0);
  }
}

class _AdBadge extends StatelessWidget {
  const _AdBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OffersLoadingSection extends StatelessWidget {
  const _OffersLoadingSection({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 140.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color:
                      (isDark
                              ? AppColors.darkGlassSurface
                              : AppColors.lightGlassSurface)
                          .withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 190.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color:
                      (isDark
                              ? AppColors.darkGlassSurface
                              : AppColors.lightGlassSurface)
                          .withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacingLG),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingLG),
          child: Container(
            height: 300.h,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkGlassSurface
                  : AppColors.lightGlassSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
          ),
        ),
      ],
    );
  }
}

class _OffersCarouselSection extends StatefulWidget {
  const _OffersCarouselSection({
    required this.offers,
    required this.products,
    required this.isDark,
  });

  final List<AdvertisementModel> offers;
  final List<ProductModel> products;
  final bool isDark;

  @override
  State<_OffersCarouselSection> createState() => _OffersCarouselSectionState();
}

class _OffersCarouselSectionState extends State<_OffersCarouselSection> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant _OffersCarouselSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offers.length != widget.offers.length) {
      _currentPage = 0;
      _timer?.cancel();
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    if (widget.offers.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.offers.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingLG,
              ),
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
                        SizedBox(height: 4.h),
                        Text(
                          'flash_deals'.tr(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: widget.isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.offers.length > 1)
                    _buildCarouselIndicator(widget.offers.length),
                ],
              ),
            )
            .animate()
            .fadeIn(
              duration: const Duration(
                milliseconds: AppDimensions.animationNormal,
              ),
            )
            .slideX(begin: -0.1, end: 0),
        SizedBox(height: AppDimensions.spacingLG),
        SizedBox(
          height: 318.h,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.offers.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXS,
                ),
                child: _buildOfferCard(context, widget.offers[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    AdvertisementModel offer,
    int index,
  ) {
    final isArabic = context.locale.languageCode == 'ar';
    final accent = widget.isDark ? AppColors.neonCyan : AppColors.lightAccent;

    return GestureDetector(
          onTap: () => _openOffer(context, offer),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border: Border.all(
                color: accent.withValues(alpha: widget.isDark ? 0.35 : 0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: widget.isDark ? 0.28 : 0.11,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  offer.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: widget.isDark
                        ? AppColors.darkGlassSurface
                        : AppColors.lightGlassSurface,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.78),
                        Colors.black.withValues(alpha: 0.38),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AdBadge(
                        label: offer.discountPercent != null
                            ? '${offer.discountPercent}% ${'discount'.tr()}'
                            : offer.campaignType.toUpperCase(),
                        color: offer.discountPercent != null
                            ? AppColors.neonOrange
                            : accent,
                      ),
                      const Spacer(),
                      Text(
                        isArabic ? offer.titleAr : offer.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                            ),
                      ),
                      SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        isArabic ? offer.subtitleAr : offer.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.32,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacingMD),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isArabic ? offer.ctaLabelAr : offer.ctaLabel,
                            style: TextStyle(
                              color: accent,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 17.w,
                            color: accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 90 * index))
        .fadeIn(
          duration: const Duration(milliseconds: AppDimensions.animationNormal),
        )
        .slideX(begin: 0.08, end: 0);
  }

  void _openOffer(BuildContext context, AdvertisementModel offer) {
    if (offer.productId == null) return;

    ProductModel? product;
    for (final item in widget.products) {
      if (item.id == offer.productId) {
        product = item;
        break;
      }
    }
    if (product == null) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailScreen(product: product!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(
          milliseconds: AppDimensions.animationNormal,
        ),
      ),
    );
  }

  Widget _buildCarouselIndicator(int count) {
    return Row(
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: AppDimensions.animationFast),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 24.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: isActive
                ? (widget.isDark ? AppColors.neonCyan : AppColors.lightAccent)
                : (widget.isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted)
                      .withValues(alpha: 0.3),
            boxShadow: isActive && widget.isDark
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
}
