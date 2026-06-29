import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.passwordRegex,
  });

  final TextEditingController controller;
  final RegExp passwordRegex;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
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
          borderSide: BorderSide(color: Colors.redAccent),
        ),
      ),
      obscureText: true, // Shields text input values
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ Banking-tier security criteria validation check loop
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty ||
            !passwordRegex.hasMatch(value.trim())) {
          return 'Password must contain uppercase, lowercase and a number.';
        }
        return null;
      },
    );
  }
}
