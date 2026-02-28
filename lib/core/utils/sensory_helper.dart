import 'package:flutter/services.dart';

/// هذا الكلاس هو المسؤول عن إعطاء "الروح" للتطبيق من خلال الصوت واللمس
class SensoryHelper {
  
  /// 1. نقرة الزجاج العادية (تستخدم مع الأزرار والتنقل)
  static Future<void> click() async {
    // اهتزاز خفيف جداً يشبه نقر الزجاج
    await HapticFeedback.lightImpact();
    // صوت "تكتكة" النظام الافتراضي (سريع وخفيف)
    await SystemSound.play(SystemSoundType.click);
  }

  /// 2. نقرة النجاح (عند الإضافة للسلة أو إتمام عملية)
  static Future<void> success() async {
    // اهتزاز متوسط
    await HapticFeedback.mediumImpact();
    // هنا يمكن إضافة صوت "تشينغ" مخصص مستقبلاً
    // await AudioPlayer().play(AssetSource('sounds/success.mp3'));
  }

  /// 3. نقرة التحديد (عند اختيار تصنيف أو فلتر)
  static Future<void> selection() async {
    // اهتزاز ناعم جداً
    await HapticFeedback.selectionClick();
  }

  /// 4. هزة خطأ (عند محاولة حذف عنصر أو فشل عملية)
  static Future<void> error() async {
    // اهتزاز ثقيل مرتين
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}