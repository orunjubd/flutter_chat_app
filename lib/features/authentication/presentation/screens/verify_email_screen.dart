import 'package:chat_app/core/widgets/app_scaffold.dart';
import 'package:chat_app/features/authentication/presentation/gate/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../widgets/refresh_verification_button.dart';
import '../widgets/resend_verification_button.dart';
import 'package:chat_app/core/dialogs/app_snackbar.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/authentication/providers/logout_provider.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);

    return AppScaffold(
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
                  style: context.textTheme.headlineSmall,
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
                    //await authRepository.signOut();
                    await ref.read(logoutServiceProvider).logout();

                    // 🚀 2. THE ASYNC FRAME LIFECYCLE GUARD SHIELD
                    if (!context.mounted) return;

                    // 🚀 3. SECURE PURGE: Clear navigation stack to drop the user back onto AuthGate securely
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthGate()),
                      (_) => false,
                    );
                  },
                  icon: Icon(Icons.logout, color: context.colorScheme.error),
                  label: Text(
                    'Logout',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
