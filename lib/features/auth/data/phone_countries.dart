/// Shared phone-country model used by [AuthScreen] and [ForgotPasswordSheet].
class PhoneCountry {
  const PhoneCountry({
    required this.countryCode,
    required this.dialCode,
    required this.label,
  });

  final String countryCode;
  final String dialCode;
  final String label;
}

const phoneCountries = <PhoneCountry>[
  PhoneCountry(countryCode: 'YE', dialCode: '+967', label: 'YE +967'),
  PhoneCountry(countryCode: 'SA', dialCode: '+966', label: 'SA +966'),
  PhoneCountry(countryCode: 'AE', dialCode: '+971', label: 'AE +971'),
  PhoneCountry(countryCode: 'KW', dialCode: '+965', label: 'KW +965'),
  PhoneCountry(countryCode: 'QA', dialCode: '+974', label: 'QA +974'),
  PhoneCountry(countryCode: 'BH', dialCode: '+973', label: 'BH +973'),
  PhoneCountry(countryCode: 'OM', dialCode: '+968', label: 'OM +968'),
  PhoneCountry(countryCode: 'EG', dialCode: '+20',  label: 'EG +20'),
  PhoneCountry(countryCode: 'JO', dialCode: '+962', label: 'JO +962'),
  PhoneCountry(countryCode: 'IQ', dialCode: '+964', label: 'IQ +964'),
];