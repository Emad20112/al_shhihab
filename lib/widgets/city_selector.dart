import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/providers/location_provider.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// CITY SELECTOR BOTTOM SHEET
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A premium glassmorphism bottom sheet for selecting a Yemeni city.
/// Lightweight — no BackdropFilter inside list items, no heavy animations.
/// ═══════════════════════════════════════════════════════════════════════════

/// Show the city picker as a modal bottom sheet
void showCitySelector(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    builder: (_) => _CityPickerSheet(isDark: isDark),
  );
}

class _CityPickerSheet extends ConsumerWidget {
  final bool isDark;
  const _CityPickerSheet({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(selectedCityProvider);
    final isArabic = context.locale.languageCode == 'ar';

    return Container(
      constraints: BoxConstraints(maxHeight: 520.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141428) : const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.neonCyan.withValues(alpha: 0.3)
                : AppColors.lightAccent.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // ── Title ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.neonCyan, AppColors.neonBlue]
                          : [
                              AppColors.lightAccent,
                              AppColors.lightAccentSecondary,
                            ],
                    ),
                  ),
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 18.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'select_city'.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.w,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(horizontal: 24.w),
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
          ),

          // ── City list ────────────────────────────────────────────
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: yemeniCities.length,
              itemBuilder: (context, index) {
                final city = yemeniCities[index];
                final isSelected = city.id == selectedCity.id;

                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ref.read(cityProvider.notifier).selectCity(city);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMD,
                      ),
                      splashColor:
                          (isDark ? AppColors.neonCyan : AppColors.lightAccent)
                              .withValues(alpha: 0.1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD,
                          ),
                          color: isSelected
                              ? (isDark
                                    ? AppColors.neonCyan.withValues(alpha: 0.12)
                                    : AppColors.lightAccent.withValues(
                                        alpha: 0.08,
                                      ))
                              : Colors.transparent,
                          border: isSelected
                              ? Border.all(
                                  color: isDark
                                      ? AppColors.neonCyan.withValues(
                                          alpha: 0.4,
                                        )
                                      : AppColors.lightAccent.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            // City icon
                            Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isDark
                                          ? AppColors.neonCyan.withValues(
                                              alpha: 0.2,
                                            )
                                          : AppColors.lightAccent.withValues(
                                              alpha: 0.15,
                                            ))
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.black.withValues(
                                              alpha: 0.04,
                                            )),
                              ),
                              child: Center(
                                child: Text(
                                  city.nameAr.characters.first,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? (isDark
                                              ? AppColors.neonCyan
                                              : AppColors.lightAccent)
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 14.w),

                            // City names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? city.nameAr : city.nameEn,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark
                                                ? AppColors.neonCyan
                                                : AppColors.lightAccent)
                                          : (isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                  Text(
                                    isArabic ? city.nameEn : city.nameAr,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.lightTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Checkmark
                            if (isSelected)
                              Container(
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            AppColors.neonCyan,
                                            AppColors.neonBlue,
                                          ]
                                        : [
                                            AppColors.lightAccent,
                                            AppColors.lightAccentSecondary,
                                          ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 14.w,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
