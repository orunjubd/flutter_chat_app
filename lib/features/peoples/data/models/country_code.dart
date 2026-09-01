// lib/features/peoples/models/country_code.dart
class CountryCode {
  const CountryCode({required this.name, required this.dialCode});
  final String name;
  final String dialCode;
}

// TODO: replace with the country list already used by PhoneAuthScreen
// (or wherever login's country-code picker lives) — don't maintain
// two separate country lists in the same app.
const kCountryCodes = [
  CountryCode(name: 'Bangladesh', dialCode: '+880'),
  CountryCode(name: 'United States', dialCode: '+1'),
  CountryCode(name: 'United Kingdom', dialCode: '+44'),
  CountryCode(name: 'India', dialCode: '+91'),
];
