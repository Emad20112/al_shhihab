import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/providers/app_providers.dart';
import '../../widgets/glass_setting_tile.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// SETTINGS SCREEN - Control Center Style Settings
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A premium settings screen featuring:
/// • User profile header with glassmorphism styling
/// • Theme toggle (Frosted Ice ↔ Smoked Glass)
/// • Language toggle (English ↔ Arabic)
/// • Additional settings tiles (Notifications, Help, Logout)
/// • Control center-like design with distinct glass sections
/// ═══════════════════════════════════════════════════════════════════════════

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildHeader(context, isDark)),

        // User Profile Section
        SliverToBoxAdapter(child: _buildProfileSection(context, isDark)),

        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingXL)),

        // Appearance Section
        SliverToBoxAdapter(
          child: GlassSettingSection(
            title: 'appearance'.tr(),
            animationDelay: const Duration(milliseconds: 100),
            children: [
              // Theme Toggle
              GlassSettingTile(
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                iconColor: isDark
                    ? AppColors.neonMagenta
                    : AppColors.lightAccent,
                title: 'theme'.tr(),
                subtitle: isDark ? 'smoked_glass'.tr() : 'frosted_ice'.tr(),
                animationDelay: const Duration(milliseconds: 150),
                trailing: GlassToggleSwitch(
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),

              // Language Toggle
              GlassSettingTile(
                icon: Icons.language_rounded,
                iconColor: isDark ? AppColors.neonCyan : AppColors.lightAccent,
                title: 'language'.tr(),
                subtitle: isArabic ? 'arabic'.tr() : 'english'.tr(),
                animationDelay: const Duration(milliseconds: 200),
                trailing: GlassToggleSwitch(
                  value: isArabic,
                  onChanged: (value) {
                    _toggleLanguage(context, ref);
                  },
                ),
                onTap: () {
                  _toggleLanguage(context, ref);
                },
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingLG)),

        // General Section
        SliverToBoxAdapter(
          child: GlassSettingSection(
            title: 'general'.tr(),
            animationDelay: const Duration(milliseconds: 250),
            children: [
              // Notifications
              GlassSettingTile(
                icon: Icons.notifications_rounded,
                iconColor: isDark ? AppColors.neonOrange : Colors.orange,
                title: 'notifications'.tr(),
                subtitle: 'manage_notifications'.tr(),
                animationDelay: const Duration(milliseconds: 300),
                onTap: () {
                  _showComingSoon(context, isDark);
                },
              ),

              // Privacy
              GlassSettingTile(
                icon: Icons.security_rounded,
                iconColor: isDark ? AppColors.neonGreen : Colors.green,
                title: 'privacy'.tr(),
                subtitle: 'privacy_settings'.tr(),
                animationDelay: const Duration(milliseconds: 350),
                onTap: () {
                  _showComingSoon(context, isDark);
                },
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingLG)),

        // Support Section
        SliverToBoxAdapter(
          child: GlassSettingSection(
            title: 'support'.tr(),
            animationDelay: const Duration(milliseconds: 400),
            children: [
              // Help Center
              GlassSettingTile(
                icon: Icons.help_outline_rounded,
                iconColor: isDark
                    ? AppColors.neonBlue
                    : AppColors.lightAccentSecondary,
                title: 'help_center'.tr(),
                subtitle: 'get_help'.tr(),
                animationDelay: const Duration(milliseconds: 450),
                onTap: () {
                  _showComingSoon(context, isDark);
                },
              ),

              // About
              GlassSettingTile(
                icon: Icons.info_outline_rounded,
                iconColor: isDark ? AppColors.neonPurple : Colors.purple,
                title: 'about'.tr(),
                subtitle: 'version_info'.tr(),
                animationDelay: const Duration(milliseconds: 500),
                onTap: () {
                  _showAboutDialog(context, isDark);
                },
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: AppDimensions.spacingLG)),

        // Logout
        SliverToBoxAdapter(
          child: GlassSettingTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.error,
            title: 'logout'.tr(),
            animationDelay: const Duration(milliseconds: 550),
            onTap: () {
              _showLogoutDialog(context, isDark);
            },
          ),
        ),

        // Bottom padding for nav bar
        SliverToBoxAdapter(child: SizedBox(height: 120.h)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLG,
            vertical: AppDimensions.spacingMD,
          ),
          child: Text(
            'settings'.tr(),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        )
        .animate()
        .fadeIn(duration: Duration(milliseconds: AppDimensions.animationNormal))
        .slideY(begin: -0.1, end: 0);
  }

  Widget _buildProfileSection(BuildContext context, bool isDark) {
    return Container(
          margin: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMD),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.15),
                      blurRadius: 25,
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      spreadRadius: -5,
                      offset: const Offset(0, 15),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isDark ? 15 : 20,
                sigmaY: isDark ? 15 : 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkGlassSurface.withOpacity(0.4)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  border: Border.all(
                    color: isDark
                        ? AppColors.neonCyan.withOpacity(0.3)
                        : Colors.white.withOpacity(0.4),
                    width: isDark ? AppDimensions.glassBorderWidth : 1,
                  ),
                ),
                padding: EdgeInsets.all(AppDimensions.spacingLG),
                child: Row(
                  children: [
                    // Avatar
                    _buildAvatar(isDark),

                    SizedBox(width: AppDimensions.spacingMD),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TechVault User',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'user@techvault.com',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                          ),
                          SizedBox(height: AppDimensions.spacingXS),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSM,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isDark ? AppColors.neonGreen : Colors.green)
                                      .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                              border: Border.all(
                                color:
                                    (isDark
                                            ? AppColors.neonGreen
                                            : Colors.green)
                                        .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? AppColors.neonGreen
                                        : Colors.green,
                                    boxShadow: isDark
                                        ? [
                                            BoxShadow(
                                              color: AppColors.neonGreen
                                                  .withOpacity(0.5),
                                              blurRadius: 6,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  'premium'.tr(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.neonGreen
                                        : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit Profile
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            (isDark
                                    ? AppColors.neonCyan
                                    : AppColors.lightAccent)
                                .withOpacity(0.15),
                        border: Border.all(
                          color:
                              (isDark
                                      ? AppColors.neonCyan
                                      : AppColors.lightAccent)
                                  .withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18.w,
                        color: isDark
                            ? AppColors.neonCyan
                            : AppColors.lightAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: AppDimensions.animationNormal),
          delay: const Duration(milliseconds: 50),
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: Duration(milliseconds: AppDimensions.animationNormal),
        );
  }

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: AppDimensions.avatarSizeLG,
      height: AppDimensions.avatarSizeLG,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.neonCyan, AppColors.neonMagenta]
              : [AppColors.lightAccent, AppColors.lightAccentSecondary],
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: AppColors.neonCyan.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: AppColors.lightAccent.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Center(
        child: Container(
          width: AppDimensions.avatarSizeInner,
          height: AppDimensions.avatarSizeInner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.darkGlassSurface : Colors.white,
          ),
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: AppDimensions.avatarIconSize,
              color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleLanguage(BuildContext context, WidgetRef ref) {
    final newLocale = context.locale.languageCode == 'en'
        ? const Locale('ar', 'SA')
        : const Locale('en', 'US');
    context.setLocale(newLocale);
    ref.read(languageProvider.notifier).setLocale(newLocale);
  }

  void _showComingSoon(BuildContext context, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('coming_soon'.tr()),
        backgroundColor: isDark ? AppColors.neonCyan : AppColors.lightAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkGlassSurface.withOpacity(0.95)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        title: Text('about'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TechVault Electronics'),
            SizedBox(height: 8.h),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: isDark ? AppColors.neonCyan : AppColors.lightAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkGlassSurface.withOpacity(0.95)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
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
              Navigator.pop(context);
              _showComingSoon(context, isDark);
            },
            child: Text(
              'logout'.tr(),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
