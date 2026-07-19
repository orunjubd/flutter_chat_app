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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Password',
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.lock_outline_rounded, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colorScheme.error),
        ),
      ),
      obscureText: true, // Shields text input values
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ Banking-tier security criteria validation check loop
      validator: validator,
    );
  }
}
