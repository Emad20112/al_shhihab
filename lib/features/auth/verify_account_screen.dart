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
    this.isPasswordRecoveryFlow = false,
  });

  final String? initialContact;
  final bool autoSendCode;
  final bool isPasswordRecoveryFlow;

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
  String? _lastSentChannel;
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
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMD,
        AppDimensions.spacingSM,
        AppDimensions.spacingMD,
        AppDimensions.spacingSM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Directionality.of(context) == ui.TextDirection.rtl
                    ? Icons.arrow_forward_ios_rounded
                    : Icons.arrow_back_ios_new_rounded,
              ),
              iconSize: 22.w,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              tooltip: 'back'.tr(),
            ),
          ),
          SizedBox(height: AppDimensions.spacingXS),
          Text(
            'verify_account'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4.h),
          Text(
            'verify_account_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
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
      _lastSentChannel = _channel;
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
      if (widget.isPasswordRecoveryFlow) {
        final changed = await _showResetPasswordDialog();
        if (!mounted) return;
        if (!changed) return;
        _showMessage('password_changed_success'.tr());
      } else {
        _showMessage('login_success'.tr());
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      _showError(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<bool> _showResetPasswordDialog() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => _ResetPasswordDialog(
        onSubmit: (password, confirmPassword) async {
          await ref.read(authControllerProvider.notifier).resetPassword({
            'password': password,
            'password_confirmation': confirmPassword,
          });
        },
      ),
    );
    return result ?? false;
  }

  Map<String, dynamic> _payload({
    required String phone,
    required bool includeCode,
  }) {
    final channelForRequest = includeCode
        ? (_lastSentChannel ?? _channel)
        : _channel;
    final payload = <String, dynamic>{
      'channel': channelForRequest,
      'phone': phone,
    };

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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({required this.onSubmit});

  final Future<void> Function(String password, String confirmPassword) onSubmit;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _submitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await widget.onSubmit(_passwordController.text, _confirmController.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(error);
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _passwordValidator(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'field_required'.tr();
    if (password.length < 8) return 'password_min_8'.tr();
    return null;
  }

  String? _confirmValidator(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) return 'field_required'.tr();
    if (confirm != _passwordController.text) {
      return 'passwords_do_not_match'.tr();
    }
    return null;
  }

  String _friendlyError(Object error) {
    if (error is ApiException) {
      final raw = _errorText(error).toLowerCase();
      if (raw.contains('password') || raw.contains('كلمة')) {
        return 'password_requirements'.tr();
      }
      if (error.statusCode == null) return 'server_unavailable'.tr();
      return 'auth_error'.tr();
    }
    return 'auth_error'.tr();
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
                'reset_password_title'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4.h),
              Text(
                'reset_password_subtitle'.tr(),
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
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _passwordValidator,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'new_password'.tr(),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                ),
              ),
              SizedBox(height: AppDimensions.spacingMD),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                validator: _confirmValidator,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'confirm_new_password'.tr(),
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                SizedBox(height: AppDimensions.spacingSM),
                Text(
                  _error!,
                  style: TextStyle(color: AppColors.error, fontSize: 12.sp),
                ),
              ],
              SizedBox(height: AppDimensions.spacingLG),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text('change_password'.tr()),
              ),
            ],
          ),
        ),
      ),
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
