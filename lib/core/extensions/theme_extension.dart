import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  
  Color get primaryTextColor => isDark
      ? Colors.white
      : const Color(0xFF1F2937);
  
  Color get secondaryTextColor => isDark
      ? Colors.white70
      : const Color(0xFF6B7280);
  
  Color get backgroundColor => isDark
      ? const Color(0xFF080A0D)
      : const Color(0xFFF7F4EA);
}
