import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 30, left: 20, right: 20),
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: context.colorScheme.onSurface.withValues(
          alpha: .12,
        ), // Subtle translucent dark mask circle
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        size: 64,
        color:
            context.colorScheme.primary, // Sharp dark look for white background
      ),
      // Note: Once asset tracking is live, you can replace the icon with:
      // child: Image.asset('assets/images/chat.png'),
    );
  }
}
