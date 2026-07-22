import 'package:flutter/material.dart';

class AuthSwitchButton extends StatelessWidget {
  const AuthSwitchButton({
    super.key,
    required this.isLogin,
    required this.onTap,
  });

  final bool isLogin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap, // Handshake link to reverse parent's _isLogin state
      style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: Text(
        isLogin
            ? "Don't have an account? Sign Up"
            : 'Already have an account? Login',
      ),
    );
  }
}
