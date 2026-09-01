// lib/features/peoples/presentation/widgets/country_code_picker.dart
import 'package:flutter/material.dart';
import 'package:chat_app/features/peoples/data/models/country_code.dart';

class CountryCodePicker extends StatelessWidget {
  const CountryCodePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final CountryCode value;
  final ValueChanged<CountryCode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<CountryCode>(
        value: value,
        items: kCountryCodes.map((c) {
          return DropdownMenuItem(value: c, child: Text(c.dialCode));
        }).toList(),
        onChanged: (c) {
          if (c != null) onChanged(c);
        },
      ),
    );
  }
}
