import 'package:chat_app/features/peoples/data/models/country_code.dart';
import 'package:chat_app/features/peoples/presentation/widgets/country_code_picker.dart';
import 'package:flutter/material.dart';

/// Dumb form — screen owns the controllers and the save/cancel logic;
/// this only lays out the fields.
class NewContactForm extends StatelessWidget {
  const NewContactForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.countryCode,
    required this.onCountryCodeChanged,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final CountryCode countryCode;
  final ValueChanged<CountryCode> onCountryCodeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: firstNameController,
          decoration: const InputDecoration(labelText: 'First Name *'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: lastNameController,
          decoration: const InputDecoration(labelText: 'Last Name'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CountryCodePicker(
              value: countryCode,
              onChanged: onCountryCodeChanged,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number *'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email (Optional)'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(labelText: 'Address (Optional)'),
          maxLines: 2,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
