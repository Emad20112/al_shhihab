import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_colors.dart';
import '../features/auth/verify_account_screen.dart';

class ForgotPasswordBottomSheet extends StatefulWidget {
	const ForgotPasswordBottomSheet({Key? key}) : super(key: key);

	@override
	State<ForgotPasswordBottomSheet> createState() => _ForgotPasswordBottomSheetState();
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
				bottom: MediaQuery.of(context).viewInsets.bottom + 16,
				top: 24,
			),
			child: Material(
				borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
				color: isDark ? AppColors.darkGlassSurface : Colors.white,
				child: Padding(
					padding: EdgeInsets.all(AppDimensions.spacingLG),
					child: Form(
						key: _formKey,
						child: Column(
							mainAxisSize: MainAxisSize.min,
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								Text(
									'استعادة كلمة المرور',
									style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
									textAlign: TextAlign.center,
								),
								SizedBox(height: AppDimensions.spacingMD),
								_buildPhoneField(isDark),
								SizedBox(height: AppDimensions.spacingLG),
								FilledButton(
									onPressed: _onConfirm,
									child: Text('تأكيد'),
								),
							],
						),
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
					LengthLimitingTextInputFormatter(_maxNationalDigits(_selectedPhoneCountry.countryCode)),
				],
				validator: _phoneValidator,
				decoration: InputDecoration(
					labelText: 'رقم الجوال',
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
						color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
					),
				),
			),
		);
	}

	int _maxNationalDigits(String countryCode) {
		switch (countryCode) {
			case 'SA':
				return 9;
			case 'YE':
				return 9;
			case 'AE':
				return 9;
			case 'KW':
				return 8;
			case 'QA':
				return 8;
			case 'BH':
				return 8;
			case 'OM':
				return 8;
			case 'EG':
				return 10;
			case 'JO':
				return 9;
			case 'IQ':
				return 10;
			default:
				return 9;
		}
	}

	String? _phoneValidator(String? value) {
		final trimmed = value?.trim() ?? '';
		if (trimmed.isEmpty) {
			return 'يرجى إدخال رقم الجوال';
		}
		final digits = trimmed.replaceAll(RegExp(r'\D'), '');
		final requiredDigits = _maxNationalDigits(_selectedPhoneCountry.countryCode);
		if (digits.length != requiredDigits) {
			if (!_showValidationErrors && digits.length < requiredDigits) {
				return null;
			}
			return 'رقم الجوال غير صحيح';
		}
		return null;
	}

	void _onConfirm() {
		setState(() => _showValidationErrors = true);
		if (!(_formKey.currentState?.validate() ?? false)) return;
		final phone = _selectedPhoneCountry.dialCode + _phoneController.text.trim();
		Navigator.of(context).pop();
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (_) => VerifyAccountScreen(initialContact: phone),
			),
		);
	}
}
