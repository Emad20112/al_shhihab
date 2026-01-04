import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// APP PROVIDERS - Riverpod State Management (v3 API)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Manages global app state:
/// • Theme switching (Frosted Ice ↔ Smoked Glass)
/// • Language switching (English ↔ Arabic)
/// ═══════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════
// SHARED PREFERENCES KEYS
// ═══════════════════════════════════════════════════════════════════════════

const String _themePreferenceKey = 'app_theme_is_dark';

// ═══════════════════════════════════════════════════════════════════════════
// THEME PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Theme mode state - tracks whether dark mode is enabled
class ThemeState {
  final ThemeMode themeMode;
  final bool isDark;

  const ThemeState({required this.themeMode, required this.isDark});

  /// Default state - uses dark mode (Smoked Glass)
  factory ThemeState.initial() {
    return const ThemeState(themeMode: ThemeMode.dark, isDark: true);
  }

  ThemeState copyWith({ThemeMode? themeMode, bool? isDark}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDark: isDark ?? this.isDark,
    );
  }
}

/// Theme notifier - handles theme switching logic (Riverpod v3 API)
class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    // Load saved theme preference on initialization
    _loadThemePreference();
    return ThemeState.initial();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themePreferenceKey) ?? true;
      state = ThemeState(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        isDark: isDark,
      );
    } catch (e) {
      // If loading fails, keep default (dark mode)
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, isDark);
    } catch (e) {
      // Silently handle save errors
    }
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    if (state.isDark) {
      state = const ThemeState(themeMode: ThemeMode.light, isDark: false);
      _saveThemePreference(false);
    } else {
      state = const ThemeState(themeMode: ThemeMode.dark, isDark: true);
      _saveThemePreference(true);
    }
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    final isDark = mode == ThemeMode.dark;
    state = ThemeState(themeMode: mode, isDark: isDark);
    _saveThemePreference(isDark);
  }

  /// Set dark mode explicitly
  void setDarkMode(bool isDark) {
    state = ThemeState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isDark: isDark,
    );
    _saveThemePreference(isDark);
  }

  /// Check if current theme is dark
  bool get isDarkMode => state.isDark;

  /// Get current theme mode
  ThemeMode get currentThemeMode => state.themeMode;
}

/// Provider for theme state
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

/// Convenience provider for checking dark mode
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDark;
});

// ═══════════════════════════════════════════════════════════════════════════
// LANGUAGE PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Supported languages
enum AppLanguage {
  english('en', 'US', 'English', false),
  arabic('ar', 'SA', 'العربية', true);

  final String languageCode;
  final String countryCode;
  final String displayName;
  final bool isRTL;

  const AppLanguage(
    this.languageCode,
    this.countryCode,
    this.displayName,
    this.isRTL,
  );

  Locale get locale => Locale(languageCode, countryCode);
}

/// Language state
class LanguageState {
  final AppLanguage language;
  final Locale locale;
  final bool isRTL;

  const LanguageState({
    required this.language,
    required this.locale,
    required this.isRTL,
  });

  /// Default state - English
  factory LanguageState.initial() {
    return LanguageState(
      language: AppLanguage.english,
      locale: AppLanguage.english.locale,
      isRTL: AppLanguage.english.isRTL,
    );
  }

  LanguageState copyWith({AppLanguage? language, Locale? locale, bool? isRTL}) {
    return LanguageState(
      language: language ?? this.language,
      locale: locale ?? this.locale,
      isRTL: isRTL ?? this.isRTL,
    );
  }
}

/// Language notifier - handles language switching logic (Riverpod v3 API)
class LanguageNotifier extends Notifier<LanguageState> {
  @override
  LanguageState build() => LanguageState.initial();

  /// Toggle between English and Arabic
  void toggleLanguage() {
    if (state.language == AppLanguage.english) {
      setLanguage(AppLanguage.arabic);
    } else {
      setLanguage(AppLanguage.english);
    }
  }

  /// Set specific language
  void setLanguage(AppLanguage language) {
    state = LanguageState(
      language: language,
      locale: language.locale,
      isRTL: language.isRTL,
    );
  }

  /// Set language by locale
  void setLocale(Locale locale) {
    if (locale.languageCode == 'ar') {
      setLanguage(AppLanguage.arabic);
    } else {
      setLanguage(AppLanguage.english);
    }
  }

  /// Check if current language is RTL
  bool get isRTL => state.isRTL;

  /// Check if current language is Arabic
  bool get isArabic => state.language == AppLanguage.arabic;

  /// Get current locale
  Locale get currentLocale => state.locale;

  /// Get current language
  AppLanguage get currentLanguage => state.language;
}

/// Provider for language state
final languageProvider = NotifierProvider<LanguageNotifier, LanguageState>(() {
  return LanguageNotifier();
});

/// Convenience provider for checking RTL
final isRTLProvider = Provider<bool>((ref) {
  return ref.watch(languageProvider).isRTL;
});

/// Convenience provider for current locale
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider).locale;
});

// ═══════════════════════════════════════════════════════════════════════════
// NAVIGATION PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Navigation notifier - handles bottom nav index (Riverpod v3 API)
class NavigationNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }

  void goToHome() => state = 0;
  void goToCategories() => state = 1;
  void goToCart() => state = 2;
  void goToSettings() => state = 3;
}

/// Provider for navigation state
final navigationProvider = NotifierProvider<NavigationNotifier, int>(() {
  return NavigationNotifier();
});
