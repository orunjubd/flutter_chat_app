import 'package:flutter/material.dart';

class ResendVerificationButton extends StatelessWidget {
  const ResendVerificationButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.email_outlined),
        label: const Text('Resend verification email'),
      ),
    );
  }
}
