import 'dart:ui' as ui;

import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/network/api_exception.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_container.dart';
import 'providers/auth_providers.dart';
import 'verify_account_screen.dart';

enum _AuthMode { login, register }

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

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _showValidationErrors = false;

  // Phone number state for flutter_libphonenumber
  String _currentPhoneNumber = '';
  _PhoneCountry _selectedPhoneCountry = _phoneCountries.first;

  bool get _isLogin => _mode == _AuthMode.login;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SimpleGradientBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(context, isDark)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.spacingMD,
                  AppDimensions.spacingSM,
                  AppDimensions.spacingMD,
                  AppDimensions.spacingXL,
                ),
                sliver: SliverToBoxAdapter(child: _buildForm(context, isDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD,
        vertical: AppDimensions.spacingSM,
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLogin ? 'login'.tr() : 'create_account'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _isLogin ? 'login_subtitle'.tr() : 'register_subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isDark) {
    return GlassContainerFeatured(
      padding: EdgeInsets.all(AppDimensions.spacingLG),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeSwitch(isDark),
            SizedBox(height: AppDimensions.spacingLG),
            if (!_isLogin) ...[
              _AuthTextField(
                controller: _nameController,
                label: 'full_name'.tr(),
                icon: Icons.person_rounded,
                textInputAction: TextInputAction.next,
                validator: _requiredValidator,
              ),
              SizedBox(height: AppDimensions.spacingMD),
            ],
            _buildPhoneField(isDark),
            if (!_isLogin) ...[
              SizedBox(height: AppDimensions.spacingMD),
              _AuthTextField(
                controller: _emailController,
                label: 'email_optional'.tr(),
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: _optionalEmailValidator,
              ),
            ],
            SizedBox(height: AppDimensions.spacingMD),
            _AuthTextField(
              controller: _passwordController,
              label: 'password'.tr(),
              icon: Icons.lock_rounded,
              obscureText: _obscurePassword,
              textInputAction: _isLogin
                  ? TextInputAction.done
                  : TextInputAction.next,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
              validator: _passwordValidator,
              onChanged: !_isLogin ? (_) => setState(() {}) : null,
              onSubmitted: _isLogin ? (_) => _submit() : null,
            ),
            if (!_isLogin) ...[
              SizedBox(height: 8.h),
              _PasswordGuidance(password: _passwordController.text),
            ],
            if (!_isLogin) ...[
              SizedBox(height: AppDimensions.spacingMD),
              _AuthTextField(
                controller: _confirmPasswordController,
                label: 'confirm_password'.tr(),
                icon: Icons.verified_user_rounded,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
                validator: _confirmPasswordValidator,
                onSubmitted: (_) => _submit(),
              ),
            ],
            SizedBox(height: AppDimensions.spacingLG),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isLogin ? Icons.login_rounded : Icons.person_add_alt),
              label: Text(_isLogin ? 'login'.tr() : 'create_account'.tr()),
            ),
            SizedBox(height: AppDimensions.spacingMD),
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _openVerification,
              icon: const Icon(Icons.sms_rounded),
              label: Text('verify_account'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitch(bool isDark) {
    final activeColor = isDark ? AppColors.neonCyan : AppColors.lightAccent;

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkGlassSurface.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.white.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'login'.tr(),
            selected: _isLogin,
            activeColor: activeColor,
            onTap: () => _setMode(_AuthMode.login),
          ),
          _ModeButton(
            label: 'create_account'.tr(),
            selected: !_isLogin,
            activeColor: activeColor,
            onTap: () => _setMode(_AuthMode.register),
          ),
        ],
      ),
    );
  }

  void _setMode(_AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _showValidationErrors = false;
    });
  }

  Widget _buildPhoneField(bool isDark) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
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
        onChanged: (_) => _updateCurrentPhoneNumber(),
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
                  _currentPhoneNumber = '';
                  _showValidationErrors = false;
                });
              },
            ),
          ),
          hintText: _selectedPhoneCountry.dialCode,
          helperText: _phoneHelperMessage(
            _selectedPhoneCountry,
            _maxNationalDigits(_selectedPhoneCountry.countryCode),
          ),
          helperMaxLines: 2,
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _showValidationErrors = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final phone = await _normalizePhoneNumber();
      if (phone == null) {
        if (!mounted) return;
        _showError('invalid_phone'.tr());
        return;
      }

      if (_isLogin) {
        await ref
            .read(authControllerProvider.notifier)
            .login(_loginPayload(phone));
        if (!mounted) return;
        _showMessage('login_success'.tr());
        Navigator.of(context).pop();
      } else {
        await ref
            .read(authControllerProvider.notifier)
            .register(_registerPayload(phone));
        if (!mounted) return;
        _showMessage('register_success'.tr());
        _openVerification(replace: true, contact: phone);
      }
    } catch (error) {
      if (!mounted) return;
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Map<String, dynamic> _loginPayload(String phone) {
    return <String, dynamic>{
      'password': _passwordController.text,
      'phone': phone,
    };
  }

  Map<String, dynamic> _registerPayload(String phone) {
    final email = _emailController.text.trim();

    return <String, dynamic>{
      'name': _nameController.text.trim(),
      'phone': phone,
      if (email.isNotEmpty) 'email': email,
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
    };
  }

  void _openVerification({bool replace = false, String? contact}) {
    _updateCurrentPhoneNumber();
    final route = MaterialPageRoute(
      builder: (_) => VerifyAccountScreen(
        initialContact:
            contact ??
            (_currentPhoneNumber.isNotEmpty
                ? _currentPhoneNumber
                : _emailController.text.trim()),
      ),
    );

    if (replace) {
      Navigator.of(context).pushReplacement(route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'field_required'.tr();
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'field_required'.tr();
    }
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
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

  void _updateCurrentPhoneNumber() {
    final nationalDigits = _nationalDigitsForCountry(
      _selectedPhoneCountry.countryCode,
      _phoneController.text,
    );
    _currentPhoneNumber = nationalDigits.isEmpty
        ? ''
        : '${_selectedPhoneCountry.dialCode}$nationalDigits';
  }

  Future<String?> _normalizePhoneNumber() async {
    _updateCurrentPhoneNumber();
    if (_currentPhoneNumber.isEmpty) return null;

    try {
      final parsed = await parse(
        _currentPhoneNumber,
        region: _selectedPhoneCountry.countryCode,
      );
      final e164 = parsed['e164']?.toString();
      return e164?.isNotEmpty == true ? e164 : null;
    } catch (_) {
      return null;
    }
  }

  String? _optionalEmailValidator(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    return valid ? null : 'invalid_email'.tr();
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr();
    if (_isLogin) {
      if (value.length < 6) return 'password_too_short'.tr();
      return null;
    }
    if (!_hasStrongPasswordLength(value)) return 'password_min_8'.tr();
    if (!_hasPasswordLetter(value)) return 'password_need_letter'.tr();
    if (!_hasPasswordNumber(value)) return 'password_need_number'.tr();
    if (value.contains(RegExp(r'\s'))) return 'password_no_spaces'.tr();
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'field_required'.tr();
    if (value != _passwordController.text) return 'passwords_do_not_match'.tr();
    return _passwordValidator(value);
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      final raw = _errorText(error).toLowerCase();
      if (error.statusCode == 409 ||
          raw.contains('مستخدم') ||
          raw.contains('already') ||
          raw.contains('duplicate') ||
          raw.contains('unique')) {
        final hasPhone = raw.contains('هاتف') || raw.contains('phone');
        final hasEmail =
            raw.contains('بريد') || raw.contains('email') || raw.contains('@');
        if (hasPhone && hasEmail) return 'phone_and_email_already_used'.tr();
        if (hasPhone) return 'phone_already_used'.tr();
        if (hasEmail) return 'email_already_used'.tr();
        if (_emailController.text.trim().isEmpty) {
          return 'phone_already_used'.tr();
        }
        return 'account_already_exists'.tr();
      }
      if (error.isUnauthorized) {
        if (raw.contains('نشط') || raw.contains('active')) {
          return 'account_not_active'.tr();
        }
        return 'invalid_login_credentials'.tr();
      }
      if (error.isValidationError) {
        if (raw.contains('email')) return 'invalid_email'.tr();
        if (raw.contains('phone')) {
          return _phoneLengthMessage(
            _selectedPhoneCountry,
            _maxNationalDigits(_selectedPhoneCountry.countryCode),
          );
        }
        if (raw.contains('password')) return 'password_requirements'.tr();
        return 'check_entered_data'.tr();
      }
      if (error.statusCode == null) return 'server_unavailable'.tr();
      return 'auth_error'.tr();
    }
    if (error is FormatException) return error.message;
    return 'auth_error'.tr();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

String _phoneLengthMessage(_PhoneCountry country, int requiredDigits) {
  final isArabic =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ar';
  if (isArabic) {
    return 'رقم ${_countryNameAr(country.countryCode)} يجب أن يكون $requiredDigits أرقام بعد مفتاح ${country.dialCode}.';
  }
  return '${_countryNameEn(country.countryCode)} phone number must be $requiredDigits digits after ${country.dialCode}.';
}

String _phoneHelperMessage(_PhoneCountry country, int requiredDigits) {
  final isArabic =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'ar';
  if (isArabic) {
    return 'أدخل $requiredDigits أرقام بعد مفتاح ${country.dialCode}. مثال: 777 000 000';
  }
  return 'Enter $requiredDigits digits after ${country.dialCode}. Example: 777 000 000';
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

String _errorText(ApiException error) {
  return '${error.message} ${error.errors ?? ''}';
}

bool _hasStrongPasswordLength(String value) => value.length >= 8;
bool _hasPasswordLetter(String value) => RegExp(r'[A-Za-z]').hasMatch(value);
bool _hasPasswordNumber(String value) => RegExp(r'\d').hasMatch(value);

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

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? activeColor.withValues(alpha: 0.18) : null,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: selected
                  ? Border.all(color: activeColor.withValues(alpha: 0.45))
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? activeColor : null,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: !obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _PasswordGuidance extends StatelessWidget {
  const _PasswordGuidance({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'password_requirements'.tr(),
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6.h),
        _PasswordRule(
          met: _hasStrongPasswordLength(password),
          label: 'password_rule_length'.tr(),
        ),
        _PasswordRule(
          met: _hasPasswordLetter(password),
          label: 'password_rule_letter'.tr(),
        ),
        _PasswordRule(
          met: _hasPasswordNumber(password),
          label: 'password_rule_number'.tr(),
        ),
        _PasswordRule(
          met: password.isNotEmpty && !password.contains(RegExp(r'\s')),
          label: 'password_rule_no_spaces'.tr(),
        ),
      ],
    );
  }
}

class _PasswordRule extends StatelessWidget {
  const _PasswordRule({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = met
        ? AppColors.neonGreen
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextMuted);
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 15.w,
            color: color,
          ),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
