import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/network/api_exception.dart';
import '../../widgets/animated_gradient_background.dart';
import '../../widgets/glass_container.dart';
import 'providers/auth_providers.dart';

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

class VerifyAccountScreen extends ConsumerStatefulWidget {
  const VerifyAccountScreen({
    super.key,
    this.initialContact,
    this.autoSendCode = false,
  });

  final String? initialContact;
  final bool autoSendCode;

  @override
  ConsumerState<VerifyAccountScreen> createState() =>
      _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends ConsumerState<VerifyAccountScreen> {
  final _codeFormKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  _PhoneCountry _selectedPhoneCountry = _phoneCountries.first;
  String _channel = 'sms';
  String _currentPhoneNumber = '';
  bool _isSending = false;
  bool _isChecking = false;
  bool _showCodeValidationErrors = false;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _applyInitialContact(widget.initialContact);
    if (widget.autoSendCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sendCode();
      });
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
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
              SliverToBoxAdapter(child: _buildHeader(context, isDark)),
              SliverPadding(
                padding: EdgeInsets.all(AppDimensions.spacingMD),
                sliver: SliverToBoxAdapter(child: _buildCard(context, isDark)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMD,
        vertical: AppDimensions.spacingSM,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              Directionality.of(context) == ui.TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
            ),
            iconSize: 22.w,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            tooltip: 'back'.tr(),
          ),
          SizedBox(width: AppDimensions.spacingSM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'verify_account'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'verify_account_subtitle'.tr(),
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

  Widget _buildCard(BuildContext context, bool isDark) {
    return GlassContainerFeatured(
      padding: EdgeInsets.all(AppDimensions.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepTitle(
            context,
            'verification_step_contact'.tr(),
            Icons.phone,
          ),
          SizedBox(height: AppDimensions.spacingSM),
          Text(
            _currentPhoneNumber.isEmpty
                ? (widget.initialContact ?? '')
                : _currentPhoneNumber,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textDirection: ui.TextDirection.ltr,
          ),
          SizedBox(height: AppDimensions.spacingMD),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'sms',
                icon: const Icon(Icons.sms_rounded),
                label: Text('sms'.tr()),
              ),
              ButtonSegment(
                value: 'whatsapp',
                icon: const Icon(Icons.chat_rounded),
                label: Text('whatsapp'.tr()),
              ),
            ],
            selected: {_channel},
            onSelectionChanged: _isSending
                ? null
                : (values) => setState(() => _channel = values.first),
          ),
          SizedBox(height: AppDimensions.spacingMD),
          FilledButton.icon(
            onPressed: _canSendCode ? _sendCode : null,
            icon: _isSending
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_sendButtonLabel()),
          ),
          SizedBox(height: AppDimensions.spacingLG),
          _buildStepTitle(context, 'verification_step_code'.tr(), Icons.pin),
          SizedBox(height: AppDimensions.spacingSM),
          Form(
            key: _codeFormKey,
            child: TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: _codeValidator,
              decoration: InputDecoration(
                labelText: 'verification_code'.tr(),
                prefixIcon: const Icon(Icons.pin_rounded),
                counterText: '',
              ),
              maxLength: 6,
              onFieldSubmitted: (_) => _checkCode(),
            ),
          ),
          SizedBox(height: AppDimensions.spacingMD),
          OutlinedButton.icon(
            onPressed: _isChecking ? null : _checkCode,
            icon: _isChecking
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.verified_rounded),
            label: Text('confirm_verification'.tr()),
          ),
        ],
      ),
    );
  }

  bool get _canSendCode => !_isSending && _resendSeconds == 0;

  Widget _buildStepTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.w),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  String _sendButtonLabel() {
    if (_resendSeconds > 0) {
      return '${'resend_code_in'.tr()} $_resendSeconds';
    }
    return 'send_code'.tr();
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    if (_currentPhoneNumber.isEmpty) {
      _showError('invalid_phone'.tr());
      return;
    }

    final phone = await _normalizePhoneNumber();
    if (phone == null) {
      if (!mounted) return;
      _showError('invalid_phone'.tr());
      return;
    }

    setState(() => _isSending = true);
    try {
      final result = await ref
          .read(authControllerProvider.notifier)
          .sendVerification(_payload(phone: phone, includeCode: false));
      if (!mounted) return;
      _startResendTimer();
      _showMessage(
        _verificationSentMessage(result),
        duration: _hasDevCode(result) ? const Duration(minutes: 1) : null,
      );
    } catch (error) {
      if (!mounted) return;
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _checkCode() async {
    FocusScope.of(context).unfocus();
    setState(() => _showCodeValidationErrors = true);
    final codeValid = _codeFormKey.currentState?.validate() ?? false;
    if (!codeValid) return;

    final phone = await _normalizePhoneNumber();
    if (phone == null) {
      if (!mounted) return;
      _showError('invalid_phone'.tr());
      return;
    }

    setState(() => _isChecking = true);
    try {
      final session = await ref
          .read(authControllerProvider.notifier)
          .checkVerification(_payload(phone: phone, includeCode: true));
      if (!mounted) return;
      if (session == null || session.token.isEmpty) {
        _showError('account_not_found'.tr());
        return;
      }
      _showMessage('login_success'.tr());
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Map<String, dynamic> _payload({
    required String phone,
    required bool includeCode,
  }) {
    final payload = <String, dynamic>{'channel': _channel, 'phone': phone};

    if (includeCode) {
      payload['code'] = _codeController.text.trim();
      payload['otp'] = _codeController.text.trim();
    }

    return payload;
  }

  String? _codeValidator(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return 'field_required'.tr();
    if (code.length != 6) {
      if (!_showCodeValidationErrors && code.length < 6) return null;
      return 'invalid_verification_code'.tr();
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

  void _applyInitialContact(String? contact) {
    final value = contact?.trim();
    if (value == null || value.isEmpty) return;

    _PhoneCountry? country;
    for (final item in _phoneCountries) {
      if (value.startsWith(item.dialCode)) {
        country = item;
        break;
      }
    }
    if (country != null) {
      _selectedPhoneCountry = country;
      final digits = _nationalDigitsForCountry(
        country.countryCode,
        value.substring(country.dialCode.length),
      );
      _phoneController.text = _formatNationalPhone(country.countryCode, digits);
      _currentPhoneNumber = value;
      return;
    }

    _phoneController.text = _formatNationalPhone(
      _selectedPhoneCountry.countryCode,
      _nationalDigitsForCountry(_selectedPhoneCountry.countryCode, value),
    );
    _updateCurrentPhoneNumber();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  String _verificationSentMessage(Map<String, dynamic> result) {
    final devCode = result['dev_code']?.toString();
    if (devCode != null && devCode.isNotEmpty) {
      return '${'verification_sent_demo'.tr()} $devCode';
    }
    return 'verification_sent'.tr();
  }

  bool _hasDevCode(Map<String, dynamic> result) {
    final devCode = result['dev_code']?.toString();
    return devCode != null && devCode.isNotEmpty;
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      final raw = _errorText(error).toLowerCase();
      if (error.isUnauthorized &&
          (raw.contains('رمز') ||
              raw.contains('code') ||
              raw.contains('otp') ||
              raw.contains('verification'))) {
        return 'verification_code_wrong_or_expired'.tr();
      }
      if (error.isValidationError) {
        if (raw.contains('phone')) {
          return _phoneLengthMessage(
            _selectedPhoneCountry,
            _maxNationalDigits(_selectedPhoneCountry.countryCode),
          );
        }
        if (raw.contains('code') || raw.contains('otp')) {
          return 'invalid_verification_code'.tr();
        }
        return 'check_entered_data'.tr();
      }
      if (error.statusCode == null) return 'server_unavailable'.tr();
      return 'auth_error'.tr();
    }
    if (error is FormatException) return error.message;
    return 'auth_error'.tr();
  }

  void _showMessage(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
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

String _errorText(ApiException error) {
  return '${error.message} ${error.errors ?? ''}';
}
