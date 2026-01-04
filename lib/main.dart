import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/theme/glassmorphism_theme.dart';
import 'core/providers/app_providers.dart';
import 'widgets/animated_gradient_background.dart';
import 'widgets/glass_bottom_nav.dart';
import 'widgets/glass_container.dart';
import 'features/home/home_screen.dart';
import 'features/cart/cart_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MAIN ENTRY POINT - TechVault Electronics Store
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A futuristic Electronics Store App featuring:
/// • Premium Glassmorphism design
/// • Light Mode: "Frosted Ice" - Soft, pas
/// tel, blurry
/// • Dark Mode: "Smoked Glass" - Deep dark, neon accents, glossy edges
/// • Full Arabic (RTL) and English (LTR) support
/// ═══════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // Wrap with EasyLocalization for translations
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      // Wrap with ProviderScope for Riverpod
      child: const ProviderScope(child: TechVaultApp()),
    ),
  );
}

/// Main App Widget
class TechVaultApp extends ConsumerWidget {
  const TechVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme state
    final themeState = ref.watch(themeProvider);

    return ScreenUtilInit(
      // Design size based on iPhone 14 Pro
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'TechVault',
          debugShowCheckedModeBanner: false,

          // Localization
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // Theme
          theme: GlassmorphismTheme.lightTheme,
          darkTheme: GlassmorphismTheme.darkTheme,
          themeMode: themeState.themeMode,

          // Builder to limit textScaleFactor for responsive UI
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final scaleFactor = mediaQueryData.textScaleFactor.clamp(1.0, 1.2);
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaleFactor: scaleFactor),
              child: child!,
            );
          },

          // Home
          home: const MainLayout(),
        );
      },
    );
  }
}

/// ═══════════════════════════════════════════════════════════════════════════
/// MAIN LAYOUT - Test Scaffold with Glass Canvas
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Displays the AnimatedGradientBackground and GlassBottomNav
/// so you can immediately test the visual base.
/// ═══════════════════════════════════════════════════════════════════════════

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Transparent to show gradient background
      backgroundColor: Colors.transparent,
      // Extend body behind bottom nav
      extendBody: true,

      body: AnimatedGradientBackground(
        child: SafeArea(
          bottom: false,
          child: _buildCurrentPage(context, ref, currentIndex, isDark),
        ),
      ),

      // Floating glass bottom navigation
      bottomNavigationBar: const GlassBottomNav(),
    );
  }

  Widget _buildCurrentPage(
    BuildContext context,
    WidgetRef ref,
    int index,
    bool isDark,
  ) {
    // Placeholder pages for testing
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return _buildPlaceholderPage(
          'Categories',
          Icons.category_rounded,
          isDark,
        );
      case 2:
        return const CartScreen();
      case 3:
        return _buildSettingsPage(context, ref, isDark);
      default:
        return _buildHomePlaceholder(context, ref, isDark);
    }
  }

  Widget _buildHomePlaceholder(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'welcome'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'discover'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              // Theme toggle button
              GlassContainer(
                padding: EdgeInsets.all(12.w),
                borderRadius: 16.r,
                enableNeonGlow: true,
                onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
                child: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Featured product card (Glass container demo)
          GlassContainerFeatured(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '🔥 ${isDark ? 'smoked_glass'.tr() : 'frosted_ice'.tr()}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Glassmorphism Demo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8.h),
                Text(
                  isDark
                      ? 'Deep dark with neon accents and glossy edges'
                      : 'Soft, pastel, and beautifully blurry',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Premium Glass Effect Active',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Sample product cards row
          Text(
            'flash_deals'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 12.h),

          SizedBox(
            height: 180.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return GlassCard(
                  width: 140.w,
                  animationDelay: Duration(milliseconds: 100 * index),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image placeholder
                      Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.devices_rounded,
                            size: 40.w,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Product ${index + 1}',
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$${(index + 1) * 99}.99',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 100.h), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildPlaceholderPage(String title, IconData icon, bool isDark) {
    return Center(
      child: GlassContainer(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64.w,
              color: isDark ? Colors.cyanAccent : Colors.deepPurple,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Coming Soon',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage(BuildContext context, WidgetRef ref, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'settings'.tr(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 24.h),

          // Theme toggle
          GlassContainer(
            onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'theme'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        isDark ? 'smoked_glass'.tr() : 'frosted_ice'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Language toggle
          GlassContainer(
            onTap: () {
              final newLocale = context.locale.languageCode == 'en'
                  ? const Locale('ar', 'SA')
                  : const Locale('en', 'US');
              context.setLocale(newLocale);
              ref.read(languageProvider.notifier).setLocale(newLocale);
            },
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.language_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'language'.tr(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        context.locale.languageCode == 'en'
                            ? 'english'.tr()
                            : 'arabic'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          SizedBox(height: 100.h), // Space for bottom nav
        ],
      ),
    );
  }
}
