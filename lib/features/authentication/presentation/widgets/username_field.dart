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
      style: context.bodyText?.copyWith(
        color: context.colorScheme.onSurface,
      ), // Dark text for white background
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      validator: validator,
    );
  }
}
