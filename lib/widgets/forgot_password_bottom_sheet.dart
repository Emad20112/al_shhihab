import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../features/auth/verify_account_screen.dart';
import 'glass_container.dart';

class ForgotPasswordBottomSheet extends StatefulWidget {
  const ForgotPasswordBottomSheet({super.key});

  @override
  State<ForgotPasswordBottomSheet> createState() =>
      _ForgotPasswordBottomSheetState();
}

class _PhoneCountry {
  const _PhoneCountry({
    required this.countryCode,
    required this.dialCode,
    required this.label,
  });

  final String countryCode;
  final String dialCode;
  final String label;
}

const _phoneCountries = <_PhoneCountry>[
  _PhoneCountry(countryCode: 'YE', dialCode: '+967', label: 'YE +967'),
  _PhoneCountry(countryCode: 'SA', dialCode: '+966', label: 'SA +966'),
  _PhoneCountry(countryCode: 'AE', dialCode: '+971', label: 'AE +971'),
  _PhoneCountry(countryCode: 'KW', dialCode: '+965', label: 'KW +965'),
  _PhoneCountry(countryCode: 'QA', dialCode: '+974', label: 'QA +974'),
  _PhoneCountry(countryCode: 'BH', dialCode: '+973', label: 'BH +973'),
  _PhoneCountry(countryCode: 'OM', dialCode: '+968', label: 'OM +968'),
  _PhoneCountry(countryCode: 'EG', dialCode: '+20', label: 'EG +20'),
  _PhoneCountry(countryCode: 'JO', dialCode: '+962', label: 'JO +962'),
  _PhoneCountry(countryCode: 'IQ', dialCode: '+964', label: 'IQ +964'),
];

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();

  _PhoneCountry _selectedPhoneCountry = _phoneCountries.first;
  bool _showValidationErrors = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: AppDimensions.spacingMD,
        right: AppDimensions.spacingMD,
        top: AppDimensions.spacingXL,
        bottom:
            MediaQuery.of(context).viewInsets.bottom + AppDimensions.spacingMD,
      ),
      child: GlassContainerFeatured(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.fromLTRB(
          AppDimensions.spacingLG,
          AppDimensions.spacingSM,
          AppDimensions.spacingLG,
          AppDimensions.spacingLG,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.22)
                        : Colors.black.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.spacingSM),
              Text(
                'forgot_password_title'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4.h),
              Text(
                'forgot_password_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              SizedBox(height: AppDimensions.spacingLG),
              _buildPhoneField(isDark),
              SizedBox(height: AppDimensions.spacingLG),
              FilledButton.icon(
                onPressed: _onConfirm,
                icon: Icon(
                  Directionality.of(context) == ui.TextDirection.rtl
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Text('continue_recovery'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.telephoneNumber],
        autovalidateMode: AutovalidateMode.onUserInteraction,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(
            _maxNationalDigits(_selectedPhoneCountry.countryCode),
          ),
          _NationalPhoneFormatter(_selectedPhoneCountry.countryCode),
        ],
        validator: _phoneValidator,
        decoration: InputDecoration(
          labelText: 'phone'.tr(),
          prefixIcon: DropdownButtonHideUnderline(
            child: DropdownButton<_PhoneCountry>(
              value: _selectedPhoneCountry,
              padding: EdgeInsets.only(left: 12.w),
              items: _phoneCountries
                  .map(
                    (country) => DropdownMenuItem(
                      value: country,
                      child: Text(
                        country.label,
                        textDirection: ui.TextDirection.ltr,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (country) {
                if (country == null) return;
                setState(() {
                  _selectedPhoneCountry = country;
                  _phoneController.clear();
                  _showValidationErrors = false;
                });
              },
            ),
          ),
          hintText: _selectedPhoneCountry.dialCode,
          border: const OutlineInputBorder(),
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  int _maxNationalDigits(String countryCode) {
    return switch (countryCode) {
      'KW' || 'QA' || 'BH' || 'OM' => 8,
      'EG' || 'IQ' => 10,
      _ => 9,
    };
  }

  String? _phoneValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'field_required'.tr();

    final digits = _nationalDigitsForCountry(
      _selectedPhoneCountry.countryCode,
      trimmed,
    );
    final requiredDigits = _maxNationalDigits(
      _selectedPhoneCountry.countryCode,
    );
    if (digits.length != requiredDigits) {
      if (!_showValidationErrors && digits.length < requiredDigits) {
        return null;
      }
      return _phoneLengthMessage(_selectedPhoneCountry, requiredDigits);
    }
    return null;
  }

  void _onConfirm() {
    FocusScope.of(context).unfocus();
    setState(() => _showValidationErrors = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final nationalDigits = _nationalDigitsForCountry(
      _selectedPhoneCountry.countryCode,
      _phoneController.text,
    );
    final phone = '${_selectedPhoneCountry.dialCode}$nationalDigits';

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifyAccountScreen(
          initialContact: phone,
          isPasswordRecoveryFlow: true,
        ),
      ),
    );
  }
}

class _NationalPhoneFormatter extends TextInputFormatter {
  const _NationalPhoneFormatter(this.countryCode);

  final String countryCode;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _sanitizeNationalDigits(countryCode, newValue.text);
    final formatted = _formatNationalPhone(countryCode, digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String _sanitizeNationalDigits(String countryCode, String value) {
  var digits = value.replaceAll(RegExp(r'\D'), '');
  final dialDigits = _dialDigits(countryCode);
  if (digits.startsWith(dialDigits)) {
    digits = digits.substring(dialDigits.length);
  }

  if (_dropsLeadingZero(countryCode)) {
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
  }

  final maxLength = _maxNationalDigits(countryCode);
  return digits.length > maxLength ? digits.substring(0, maxLength) : digits;
}

String _formatNationalPhone(String countryCode, String digits) {
  final groups = switch (countryCode) {
    'AE' => [2, 3, 4],
    'EG' || 'IQ' => [3, 3, 4],
    _ => [3, 3, 3],
  };

  var cursor = 0;
  final parts = <String>[];
  for (final size in groups) {
    if (cursor >= digits.length) break;
    final end = (cursor + size).clamp(0, digits.length);
    parts.add(digits.substring(cursor, end));
    cursor = end;
  }
  if (cursor < digits.length) parts.add(digits.substring(cursor));
  return parts.join(' ');
}

int _maxNationalDigits(String countryCode) {
  return switch (countryCode) {
    'KW' || 'QA' || 'BH' || 'OM' => 8,
    'EG' || 'IQ' => 10,
    _ => 9,
  };
}

String _dialDigits(String countryCode) {
  return _phoneCountries
      .firstWhere(
        (country) => country.countryCode == countryCode,
        orElse: () => _phoneCountries.first,
      )
      .dialCode
      .replaceAll(RegExp(r'\D'), '');
}

bool _dropsLeadingZero(String countryCode) {
  return const {'YE', 'SA', 'AE', 'KW', 'QA', 'BH', 'OM'}.contains(countryCode);
}

String _nationalDigitsForCountry(String countryCode, String value) {
  return _sanitizeNationalDigits(countryCode, value);
}

String _phoneLengthMessage(_PhoneCountry country, int requiredDigits) {
  final isArabic =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ar';
  if (isArabic) {
    return 'رقم ${_countryNameAr(country.countryCode)} يجب أن يكون $requiredDigits أرقام بعد مفتاح ${country.dialCode}.';
  }
  return '${_countryNameEn(country.countryCode)} phone number must be $requiredDigits digits after ${country.dialCode}.';
}

String _countryNameAr(String countryCode) {
  return switch (countryCode) {
    'YE' => 'اليمن',
    'SA' => 'السعودية',
    'AE' => 'الإمارات',
    'KW' => 'الكويت',
    'QA' => 'قطر',
    'BH' => 'البحرين',
    'OM' => 'عُمان',
    'EG' => 'مصر',
    'JO' => 'الأردن',
    'IQ' => 'العراق',
    _ => 'الدولة المختارة',
  };
}

String _countryNameEn(String countryCode) {
  return switch (countryCode) {
    'YE' => 'Yemen',
    'SA' => 'Saudi Arabia',
    'AE' => 'UAE',
    'KW' => 'Kuwait',
    'QA' => 'Qatar',
    'BH' => 'Bahrain',
    'OM' => 'Oman',
    'EG' => 'Egypt',
    'JO' => 'Jordan',
    'IQ' => 'Iraq',
    _ => 'Selected country',
  };
}
