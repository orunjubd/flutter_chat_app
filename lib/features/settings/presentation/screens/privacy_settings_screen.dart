import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Adjust these imports to the existing locations in your project.
import 'package:chat_app/features/profile/repositories/profile_repository.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _savingEmail = false;
  bool _savingPhone = false;

  Future<void> _updateEmailSharing({
    required AppUser user,
    required bool enabled,
  }) async {
    if (_savingEmail || _savingPhone) return;

    setState(() => _savingEmail = true);

    try {
      await ref
          .read(profileRepositoryProvider)
          .updateEmailSharing(userId: user.id, enabled: enabled);

      if (!mounted) return;

      _showMessage(
        enabled ? 'Email sharing enabled.' : 'Email sharing disabled.',
      );
    } catch (error, stackTrace) {
      debugPrint('Email privacy update failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('Could not update email privacy. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _savingEmail = false);
      }
    }
  }

  Future<void> _updatePhoneSharing({
    required AppUser user,
    required bool enabled,
  }) async {
    if (_savingPhone || _savingEmail) return;

    setState(() => _savingPhone = true);

    try {
      await ref
          .read(profileRepositoryProvider)
          .updatePhoneSharing(userId: user.id, enabled: enabled);

      if (!mounted) return;

      _showMessage(
        enabled
            ? 'Phone-number sharing enabled.'
            : 'Phone-number sharing disabled.',
      );
    } catch (error, stackTrace) {
      debugPrint('Phone privacy update failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      _showMessage('Could not update phone privacy. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _savingPhone = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Reuse the existing user stream.
    final userAsync = ref.watch(currentUserProvider);

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 44),
                  const SizedBox(height: 12),
                  const Text('Could not load privacy settings.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      ref.invalidate(currentUserProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No signed-in user found.'));
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Icon(Icons.shield_outlined, size: 52, color: colors.primary),
              const SizedBox(height: 12),
              Text(
                'Your privacy, your choice',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose which contact information you allow '
                'ECE Chat to share with group members.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),

              // Email privacy.
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.alternate_email),
                  title: const Text('Share my Email with group members'),
                  subtitle: const Text(
                    'Allow your email address to be displayed '
                    'to other group members.',
                  ),
                  value: user.shareEmailWithGroupMembers,
                  onChanged: _savingEmail || _savingPhone
                      ? null
                      : (enabled) {
                          _updateEmailSharing(user: user, enabled: enabled);
                        },
                ),
              ),

              const SizedBox(height: 12),

              // Phone privacy.
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.phone_outlined),
                  title: const Text('Share my Phone number with group members'),
                  subtitle: const Text(
                    'Allow your phone number to be displayed '
                    'to other group members.',
                  ),
                  value: user.sharePhoneNumberWithGroupMembers,
                  onChanged: _savingPhone || _savingEmail
                      ? null
                      : (enabled) {
                          _updatePhoneSharing(user: user, enabled: enabled);
                        },
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Both settings are independent and '
                        'are disabled by default for users '
                        'who have not configured them.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
