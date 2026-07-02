import 'package:flutter/material.dart';

class RefreshVerificationButton extends StatelessWidget {
  const RefreshVerificationButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.refresh),
        label: const Text('I have verified my email'),
      ),
    );
  }
}
