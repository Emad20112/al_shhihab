import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/theme/glassmorphism_theme.dart';
import 'core/providers/app_providers.dart';

import 'features/splash/splash_screen.dart';
import 'widgets/animated_gradient_background.dart';
import 'widgets/glass_bottom_nav.dart';
import 'features/home/home_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/categories/categories_screen.dart';
import 'features/settings/settings_screen.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MAIN ENTRY POINT - StyleHub Fashion Store
/// ═══════════════════════════════════════════════════════════════════════════
///
/// A fashion shopping app featuring:
/// • Premium Glassmorphism design
/// • Light Mode: "Frosted Ice" - Soft, pastel, blurry
/// • Dark Mode: "Smoked Glass" - Deep dark, neon accents, glossy edges
/// • Full Arabic (RTL) and English (LTR) support
/// ═══════════════════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة flutter_libphonenumber
  await init();

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
      child: const ProviderScope(child: StyleHubApp()),
    ),
  );
}

/// Main App Widget
class StyleHubApp extends ConsumerWidget {
  const StyleHubApp({super.key});

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
          title: 'StyleHub',
          debugShowCheckedModeBanner: false,

          // Localization
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // Theme
          theme: GlassmorphismTheme.lightTheme,
          darkTheme: GlassmorphismTheme.darkTheme,
          themeMode: themeState.themeMode,

          // Builder to limit text scale for responsive UI
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: mediaQueryData.textScaler.clamp(
                  minScaleFactor: 1.0,
                  maxScaleFactor: 1.2,
                ),
              ),
              child: child!,
            );
          },

          home: const SplashScreen(),
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

    return Scaffold(
      // Transparent to show gradient background
      backgroundColor: Colors.transparent,
      // Keep page content above the fixed bottom navigation on every device.
      extendBody: false,

      body: SimpleGradientBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: currentIndex,
            children: const [
              HomeScreen(),
              CategoriesScreen(),
              CartScreen(),
              SettingsScreen(),
            ],
          ),
        ),
      ),

      // Fixed bottom navigation (isolated repaint)
      bottomNavigationBar: const RepaintBoundary(child: GlassBottomNav()),
    );
  }
}
