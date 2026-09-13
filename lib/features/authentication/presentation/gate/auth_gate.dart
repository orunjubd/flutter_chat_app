import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/authentication/presentation/screens/auth_screen.dart';
import 'package:chat_app/features/authentication/presentation/screens/verify_email_screen.dart';
import 'package:chat_app/features/chat/presentation/screens/conversation_list_screen.dart';
//import 'package:chat_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:chat_app/core/utils/firebase_error_mapper.dart';
import 'package:chat_app/core/notifications/fcm_token_service.dart';
// ========================================================
// Auth_Gate is not a screen—it's a router/decision widget.
// =========================================================

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text(FirebaseErrorMapper.message(error))),
      ),

      data: (user) {
        if (user == null) {
          return const AuthScreen();
        }

        final emailVerified = ref.watch(emailVerifiedProvider);

        return emailVerified.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),

          error: (error, stackTrace) => Scaffold(
            body: Center(child: Text(FirebaseErrorMapper.message(error))),
          ),

          data: (verified) {
            if (verified) {
              // Fire-and-forget — registering the FCM token shouldn't
              // block entry into the app, and any failure here is
              // non-fatal (worst case, this device just won't receive
              // background call pushes until it succeeds on a later
              // launch).

              FcmTokenService().registerToken(user.uid).catchError((e) {
                debugPrint('⚠️ Failed to register FCM token: $e');
              });

              return const ConversationListScreen();
            }

            return const VerifyEmailScreen();
          },
        );
      },
    );
  }
}
