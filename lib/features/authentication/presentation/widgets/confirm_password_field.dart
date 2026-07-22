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
      style: context.bodyText?.copyWith(
        color: context.errorColor,
        fontWeight: FontWeight.w500,
      ), // ✅ Clear black text ink for white background
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        labelStyle: context.captionText?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ), // ✅ Soft dark grey text label
        prefixIcon: Icon(Icons.lock_reset_outlined),
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
