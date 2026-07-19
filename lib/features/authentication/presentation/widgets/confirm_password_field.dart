import 'package:flutter/material.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';

class ConfirmPasswordTextField extends StatelessWidget {
  const ConfirmPasswordTextField({
    super.key,
    required this.controller,
    required this.validator, // ✅ Receives the parent password controller to check matches
  });

  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: context.colorScheme.onSurface,
      ), // ✅ Clear black text ink for white background
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Confirm Password',
        labelStyle: TextStyle(
          color: context.colorScheme.onSurfaceVariant,
        ), // ✅ Soft dark grey text label
        prefixIcon: Icon(
          Icons.lock_reset_outlined,
          color: context.colorScheme.onSurfaceVariant,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.colorScheme.outlineVariant,
          ), // ✅ Subtle contrast border edge
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: context.colorScheme.primary,
            width: 2.0,
          ), // ✅ Strong solid black highlight on tap
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colorScheme.error, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colorScheme.error, width: 2.0),
        ),
        // Dynamic error text styling text line handle
        errorStyle: TextStyle(
          color: context.colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
      obscureText:
          true, // ✅ Secures typed password input string character layers
      autocorrect: false,
      textCapitalization: TextCapitalization.none,

      // ✅ CONFIRMATION MATCH CHECK VALIDATOR PIPELINE
      validator: validator,
    );
  }
}
