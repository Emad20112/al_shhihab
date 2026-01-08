import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import 'core/theme/glassmorphism_theme.dart';
import 'core/providers/app_providers.dart';
import 'widgets/animated_gradient_background.dart';
import 'widgets/glass_bottom_nav.dart';
import 'features/home/home_screen.dart';
import 'features/cart/cart_screen.dart';
import 'features/categories/categories_screen.dart';
import 'features/settings/settings_screen.dart';

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
    // Screen pages based on navigation index
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CategoriesScreen();
      case 2:
        return const CartScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }
}
