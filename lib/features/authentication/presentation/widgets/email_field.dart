import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    required this.validator,
  });

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: context.bodyText?.copyWith(
        color: context.colorScheme.onSurface,
      ), // Ensures text readability
      decoration: InputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ Strict validation boundary
      validator: validator,
    );
  }
}
