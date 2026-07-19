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
      style: TextStyle(
        color: context.colorScheme.onSurface,
      ), // Ensures text readability
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Email Address',
        labelStyle: context
            .textTheme
            .bodyMedium, // color: context.colorScheme.onSurfaceVariant,
        prefixIcon: Icon(
          Icons.email_outlined,
          color: context.colorScheme.onSurfaceVariant,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colorScheme.error),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ Strict validation boundary
      validator: validator,
    );
  }
}
