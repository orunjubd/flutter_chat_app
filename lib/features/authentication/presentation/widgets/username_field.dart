import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget {
  const UsernameField({
    super.key,
    required this.controller,
    required this.usernameRegex,
  });

  final TextEditingController controller;
  final RegExp usernameRegex;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: Colors.black,
      ), // Dark text for white background
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Username',
        labelStyle: TextStyle(color: Color.fromARGB(221, 194, 193, 193)),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: Color.fromARGB(221, 194, 193, 193),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(88, 194, 193, 193)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent),
        ),
      ),
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a username.';
        }
        if (!usernameRegex.hasMatch(value.trim())) {
          return '4-15 chars, letters/numbers/dots only.';
        }
        return null;
      },
    );
  }
}
