class ContactDraft {
  const ContactDraft({
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });

  final String name;
  final String phone;
  final String? email;
  final String? address;
}
