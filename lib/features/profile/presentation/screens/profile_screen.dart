import 'package:chat_app/features/profile/presentation/widgets/profile_screen_widget.dart';
import 'package:chat_app/features/profile/repositories/private_contact_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/profile/providers/profile_photo_provider.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _savingPhoneNumber = false;

  Future<void> _editPhoneNumber(AppUser user, String initialPhone) async {
    final initialPhone =
        await ref.read(contactPhoneProvider(user.id).future) ?? '';
    if (!mounted) return;
    final controller = TextEditingController(text: initialPhone);

    final formKey = GlobalKey<FormState>();

    try {
      final phoneNumber = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Edit phone number'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+8801XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) {
                  final number = value?.trim() ?? '';

                  if (number.isEmpty) return null;

                  if (number.length < 7) {
                    return 'Enter a valid phone number.';
                  }

                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  Navigator.pop(dialogContext, controller.text.trim());
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (phoneNumber == null || !mounted) return;

      if (phoneNumber == initialPhone) return;

      setState(() => _savingPhoneNumber = true);

      try {
        await ref
            .read(profileRepositoryProvider)
            .updatePhoneNumber(userId: user.id, phoneNumber: phoneNumber);

        if (!mounted) return;

        _showMessage('Phone number updated.');
        ref.invalidate(contactPhoneProvider(user.id));
      } catch (error, stackTrace) {
        debugPrint('Phone update failed: $error');
        debugPrintStack(stackTrace: stackTrace);

        if (!mounted) return;

        _showMessage('Could not update phone number.');
      } finally {
        if (mounted) {
          setState(() => _savingPhoneNumber = false);
        }
      }
    } finally {
      controller.dispose();
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
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Could not load your profile.'),
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
          final ownEmail = FirebaseAuth.instance.currentUser?.email;
          // 🚀 FIX Phone Provider: Watches the new dynamic isolated future family repository stream cache
          final phoneAsync = ref.watch(contactPhoneProvider(user.id));
          final currentFreshPhone = phoneAsync.value;

          return ProfileScreenWidget(
            user: user,
            email: ownEmail,
            phone: currentFreshPhone,
            savingPhoneNumber: _savingPhoneNumber,
            onEditPhoneNumber: () {
              _editPhoneNumber(user, currentFreshPhone ?? '');
            },
          );
        },
      ),
    );
  }
}
