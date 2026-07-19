import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';

class UsernameField extends StatelessWidget {
  const UsernameField({
    super.key,
    required this.controller,
    //required this.usernameRegex,
    this.validator,
  });

  final TextEditingController controller;
  //final RegExp usernameRegex;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: context.colorScheme.onSurface,
      ), // Dark text for white background
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Username',
        labelStyle: TextStyle(color: context.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
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
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: validator,
    );
  }
}
