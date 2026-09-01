class NewContactDraft {
  const NewContactDraft({
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.phoneNumber,
    this.email,
    this.address,
  });

  final String firstName;
  final String lastName;
  final String countryCode; // e.g. "+880"
  final String phoneNumber; // national number, no country code
  final String? email;
  final String? address;

  /// The number as it should actually be stored/used — country code
  /// joined with the national number.
  String get fullPhoneNumber => '$countryCode ${phoneNumber.trim()}';
}
