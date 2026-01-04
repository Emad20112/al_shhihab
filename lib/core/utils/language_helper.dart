import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// LANGUAGE HELPER - Easy Language Switching
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Helper functions to properly switch languages using easy_localization.
/// This ensures the app rebuilds immediately when language changes.
/// ═══════════════════════════════════════════════════════════════════════════

/// Available app languages
enum AppLanguage {
  english(Locale('en', 'US'), 'English', false),
  arabic(Locale('ar', 'SA'), 'العربية', true);

  final Locale locale;
  final String displayName;
  final bool isRTL;

  const AppLanguage(this.locale, this.displayName, this.isRTL);
}

/// Helper class for language operations
class LanguageHelper {
  /// Toggle between English and Arabic
  static void toggleLanguage(BuildContext context) {
    final currentLocale = context.locale;
    if (currentLocale.languageCode == 'ar') {
      context.setLocale(AppLanguage.english.locale);
    } else {
      context.setLocale(AppLanguage.arabic.locale);
    }
  }

  /// Set specific language
  static void setLanguage(BuildContext context, AppLanguage language) {
    context.setLocale(language.locale);
  }

  /// Get current app language
  static AppLanguage getCurrentLanguage(BuildContext context) {
    final currentLocale = context.locale;
    if (currentLocale.languageCode == 'ar') {
      return AppLanguage.arabic;
    }
    return AppLanguage.english;
  }

  /// Check if current language is Arabic
  static bool isArabic(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  /// Check if current language is RTL
  static bool isRTL(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  /// Get supported locales
  static List<Locale> get supportedLocales => [
    AppLanguage.english.locale,
    AppLanguage.arabic.locale,
  ];
}
