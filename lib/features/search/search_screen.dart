import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/search_provider.dart';
import '../../widgets/glass_product_card.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SEARCH SCREEN - Premium Product Search
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Fast, responsive search with glassmorphism styling.
///
/// Features:
/// • Auto-focused glass text field
/// • Real-time search results
/// • Popular tags when empty
/// • "No results" empty state
/// ═══════════════════════════════════════════════════════════════════════════

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    // Auto focus on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final query = ref.watch(searchQueryProvider);
    final results = ref.watch(searchResultsProvider);
    final isNoResults = ref.watch(isNoResultsProvider);
    final popularTags = isArabic
        ? ref.watch(popularTagsArProvider)
        : ref.watch(popularTagsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search field
            _buildHeader(context, isDark),

            // Content
            Expanded(
              child: query.isEmpty
                  ? _buildPopularTags(context, isDark, popularTags)
                  : isNoResults
                  ? _buildNoResults(context, isDark)
                  : _buildSearchResults(context, isDark, results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD,
        vertical: AppDimensions.spacingSM,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              ref.read(searchQueryProvider.notifier).state = '';
              Navigator.pop(context);
            },
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.darkGlassSurface.withOpacity(0.5)
                    : Colors.white.withOpacity(0.4),
                border: Border.all(
                  color: isDark
                      ? AppColors.neonCyan.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 20.w,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ).animate().fadeIn(
            duration: Duration(milliseconds: AppDimensions.animationNormal),
          ),

          SizedBox(width: AppDimensions.spacingSM),

          // Search field
          Expanded(child: _buildSearchField(isDark)),
        ],
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDark ? 15 : 20,
              sigmaY: isDark ? 15 : 20,
            ),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkGlassSurface.withOpacity(0.4)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(
                  color: isDark
                      ? AppColors.neonCyan.withOpacity(0.3)
                      : Colors.white.withOpacity(0.4),
                  width: isDark ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                style: TextStyle(
                  fontSize: 15.sp,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'search_products'.tr(),
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 22.w,
                    color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                          child: Icon(
                            Icons.close_rounded,
                            size: 20.w,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMD,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: Duration(milliseconds: AppDimensions.animationNormal))
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildPopularTags(
    BuildContext context,
    bool isDark,
    List<String> tags,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.spacingMD),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppDimensions.spacingMD),

          // Section title
          Text(
            'popular_tags'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ).animate().fadeIn(
            duration: Duration(milliseconds: AppDimensions.animationNormal),
            delay: const Duration(milliseconds: 100),
          ),

          SizedBox(height: AppDimensions.spacingMD),

          // Tags grid
          Wrap(
            spacing: AppDimensions.spacingSM,
            runSpacing: AppDimensions.spacingSM,
            children: tags.asMap().entries.map((entry) {
              final index = entry.key;
              final tag = entry.value;
              return _buildTagChip(context, isDark, tag, index);
            }).toList(),
          ),

          SizedBox(height: AppDimensions.spacingXL),

          // Recent searches section (optional UI)
          Text(
            'recent_searches'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ).animate().fadeIn(
            duration: Duration(milliseconds: AppDimensions.animationNormal),
            delay: const Duration(milliseconds: 200),
          ),

          SizedBox(height: AppDimensions.spacingMD),

          // Empty recent searches
          Container(
            padding: EdgeInsets.all(AppDimensions.spacingLG),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48.w,
                    color: isDark
                        ? AppColors.darkTextMuted.withOpacity(0.5)
                        : AppColors.lightTextMuted.withOpacity(0.5),
                  ),
                  SizedBox(height: AppDimensions.spacingSM),
                  Text(
                    'no_recent_searches'.tr(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(
            duration: Duration(milliseconds: AppDimensions.animationNormal),
            delay: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(
    BuildContext context,
    bool isDark,
    String tag,
    int index,
  ) {
    return GestureDetector(
          onTap: () {
            _searchController.text = tag;
            ref.read(searchQueryProvider.notifier).state = tag;
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingSM,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkGlassSurface.withOpacity(0.4)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: isDark
                        ? AppColors.neonCyan.withOpacity(0.3)
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.tag_rounded,
                      size: 14.w,
                      color: isDark
                          ? AppColors.neonCyan
                          : AppColors.lightAccent,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 50 * index))
        .fadeIn(duration: Duration(milliseconds: AppDimensions.animationNormal))
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1));
  }

  Widget _buildNoResults(BuildContext context, bool isDark) {
    return Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.spacingXL),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.spacingXL),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkGlassSurface.withOpacity(0.4)
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    border: Border.all(
                      color: isDark
                          ? AppColors.neonCyan.withOpacity(0.2)
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppColors.neonMagenta.withOpacity(0.15)
                              : AppColors.error.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.search_off_rounded,
                          size: 40.w,
                          color: isDark
                              ? AppColors.neonMagenta
                              : AppColors.error,
                        ),
                      ),

                      SizedBox(height: AppDimensions.spacingLG),

                      Text(
                        'no_results'.tr(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: AppDimensions.spacingSM),

                      Text(
                        'no_results_desc'.tr(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppDimensions.spacingMD),

                      Text(
                        'try_different'.tr(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.neonCyan
                              : AppColors.lightAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: Duration(milliseconds: AppDimensions.animationNormal))
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildSearchResults(BuildContext context, bool isDark, List results) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Results count
        SliverToBoxAdapter(
          child:
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMD,
                  vertical: AppDimensions.spacingSM,
                ),
                child: Text(
                  '${results.length} ${'results_found'.tr()}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ).animate().fadeIn(
                duration: Duration(milliseconds: AppDimensions.animationNormal),
              ),
        ),

        // Results grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMD),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppDimensions.spacingMD,
              crossAxisSpacing: AppDimensions.spacingSM,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = results[index];
              return GlassProductCard(
                product: product,
                animationDelay: Duration(
                  milliseconds: AppDimensions.staggerDelay * index,
                ),
                onTap: () {
                  // TODO: Navigate to product detail
                },
              );
            }, childCount: results.length),
          ),
        ),

        // Bottom padding
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }
}
