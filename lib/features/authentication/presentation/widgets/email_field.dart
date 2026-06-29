import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    required this.emailRegex,
  });

  final TextEditingController controller;
  final RegExp emailRegex;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white), // Ensures text readability
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Email Address',
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
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
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ Strict validation boundary
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty ||
            !emailRegex.hasMatch(value.trim())) {
          return 'Please enter a valid email address.';
        }
        return null;
      },
    );
  }
}
