import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
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
      style: context.bodyText?.copyWith(color: context.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline_rounded),
      ),
      obscureText: true, // Shields text input values
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ Banking-tier security criteria validation check loop
      validator: validator,
    );
  }
}
