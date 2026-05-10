import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// GLASSMORPHISM THEME - Premium Theme System
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Two distinct visual themes:
/// • Light Mode: "Frosted Ice" ❄️ - Soft, pastel, blurry
/// • Dark Mode: "Dark Luxury" ✨ - Deep black, gold accents, elegant
/// ═══════════════════════════════════════════════════════════════════════════

class GlassmorphismTheme {
  GlassmorphismTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME: "Frosted Ice" ❄️
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.lightAccent,
        secondary: AppColors.lightAccentSecondary,
        surface: AppColors.lightGlassSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: Colors.transparent,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        centerTitle: true,
        titleTextStyle: _getTitleTextStyle(false),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary, size: 24.w),
      ),

      // Text Theme
      textTheme: _getTextTheme(false),

      // Icon Theme
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary, size: 24.w),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.lightAccent,
        unselectedItemColor: AppColors.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: AppColors.lightGradientStart,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.lightAccent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.lightTextMuted,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.25),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME: "Dark Luxury" ✨
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.neonCyan,
        secondary: AppColors.neonMagenta,
        surface: AppColors.darkGlassSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: Colors.transparent,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        centerTitle: true,
        titleTextStyle: _getTitleTextStyle(true),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary, size: 24.w),
      ),

      // Text Theme
      textTheme: _getTextTheme(true),

      // Icon Theme
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary, size: 24.w),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.darkTextMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGlassSurface.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.neonCyan.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.neonCyan, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        hintStyle: GoogleFonts.cairo(
          color: AppColors.darkTextMuted,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkGlassSurface.withValues(alpha: 0.85),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static TextStyle _getTitleTextStyle(bool isDark) {
    return GoogleFonts.cairo(
      fontSize: 20.sp,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextTheme _getTextTheme(bool isDark) {
    final Color primary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.cairo(
        fontSize: 57.sp,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: 0,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 45.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),

      // Title styles
      titleLarge: GoogleFonts.cairo(
        fontSize: 22.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),

      // Body styles
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),

      // Label styles
      labelLarge: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: secondary,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ARABIC TEXT THEME (Using Cairo font)
  // ═══════════════════════════════════════════════════════════════════════════

  static TextTheme getArabicTextTheme(bool isDark) {
    final Color primary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.cairo(
        fontSize: 57.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 45.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.cairo(
        fontSize: 32.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),

      // Title styles
      titleLarge: GoogleFonts.cairo(
        fontSize: 22.sp,
        fontWeight: FontWeight.w800,
        color: primary,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),

      // Body styles
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),

      // Label styles
      labelLarge: GoogleFonts.cairo(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: secondary,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
    );
  }
}
