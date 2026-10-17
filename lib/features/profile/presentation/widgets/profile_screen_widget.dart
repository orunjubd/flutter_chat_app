import 'package:chat_app/features/chat/presentation/widgets/group_avatar.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/features/chat/data/models/app_user.dart';

class ProfileScreenWidget extends StatelessWidget {
  const ProfileScreenWidget({
    super.key,
    required this.user,
    this.savingPhoneNumber = false,
    this.onEditPhoneNumber,
    this.readOnly = false,
    this.email,
    this.phone,
  });
  final AppUser user;
  final bool savingPhoneNumber;
  final VoidCallback? onEditPhoneNumber;
  final bool readOnly;
  final String? email;
  final String? phone;

  String _contact(String? value, bool shared, String empty) {
    if (readOnly && !shared) return 'Private';
    return (value == null || value.isEmpty) ? empty : value;
  }

  // header email line: show only if email != null && email!.isNotEmpty && (!readOnly || user.shareEmailWithGroupMembers)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final emailText = _contact(
      email,
      user.shareEmailWithGroupMembers,
      'Not available',
    );
    final phoneText = _contact(
      phone,
      user.sharePhoneNumberWithGroupMembers,
      'Not added',
    );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Column(
            children: [
              GroupAvatar(
                name: user.username,
                imageUrl: user.imageUrl,
                radius: 52,
              ),
              const SizedBox(height: 16),
              Text(
                user.username.isEmpty ? 'User' : user.username,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (email != null &&
                  email!.isNotEmpty &&
                  (!readOnly || user.shareEmailWithGroupMembers)) ...[
                const SizedBox(height: 6),
                Text(
                  email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Profile information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Username'),
                subtitle: Text(
                  user.username.isEmpty ? 'Not set' : user.username,
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email address'),
                subtitle: Text(emailText),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: const Text('Phone number'),
                subtitle: Text(phoneText),
                trailing: readOnly
                    ? null
                    : (savingPhoneNumber
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit_outlined)),
                onTap: readOnly || savingPhoneNumber ? null : onEditPhoneNumber,
              ),
            ],
          ),
        ),
        if (!readOnly) ...[
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: colors.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Choose what you share with group members in Settings > Privacy. '
                    'The two settings are independent.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
