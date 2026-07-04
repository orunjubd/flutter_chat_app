import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../widgets/refresh_verification_button.dart';
import '../widgets/resend_verification_button.dart';
import 'package:chat_app/core/errors/dialogs/app_snackbar.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);

    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(title: const Text('Verify Email'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_read_outlined, size: 90),

                const SizedBox(height: 24),

                Text(
                  'Verify your email address',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                const Text(
                  'We have sent a verification email to your inbox.\n\n'
                  'Please verify your email before continuing to Chat App.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                RefreshVerificationButton(
                  onPressed: () async {
                    final verified = await authRepository.isEmailVerified();

                    if (!context.mounted) return;

                    if (verified) {
                      ref.invalidate(emailVerifiedProvider);

                      AppSnackBar.success(
                        context,
                        'Email verified successfully.',
                      );
                    } else {
                      AppSnackBar.error(
                        context,
                        'Your email is not verified yet.',
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),

                ResendVerificationButton(
                  onPressed: () async {
                    try {
                      await authRepository.sendEmailVerification();

                      if (!context.mounted) return;

                      AppSnackBar.success(
                        context,
                        'Verification email sent again.',
                      );
                    } catch (_) {
                      if (!context.mounted) return;

                      AppSnackBar.error(
                        context,
                        'Unable to send verification email.',
                      );
                    }
                  },
                ),

                const SizedBox(height: 30),

                TextButton.icon(
                  onPressed: () async {
                    await authRepository.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
