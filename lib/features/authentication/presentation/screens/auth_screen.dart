import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/auth_form.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/core/widgets/loading_overlay.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white12,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: const Center(child: SingleChildScrollView(child: AuthForm())),
      ),
    );
  }
}
