//import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, required this.isLogin, required this.onTap});

  final bool isLogin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap, // Handshake link to trigger parent's form submit logic
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(isLogin ? 'Sign In' : 'Create Account'),
    );
  }
}
