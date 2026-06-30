import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/authentication/presentation/screens/auth_screen.dart';
import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';

// ========================================================
// Auth_Gate is not a screen—it's a router/decision widget.
// =========================================================

// Temporary Home Screen
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'Welcome! You are logged in.',
//           style: TextStyle(fontSize: 22),
//         ),
//       ),
//     );
//   }
// }

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const ChatScreen();
        }

        return const AuthScreen();
      },

      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text(error.toString()))),
    );
  }
}
