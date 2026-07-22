import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/authentication/providers/logout_provider.dart';
import 'package:chat_app/core/providers/theme_provider.dart';
import 'package:chat_app/features/settings/presentation/widgets/theme_selector_tile.dart';
import 'package:chat_app/core/dialogs/app_snackbar.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentTheme = ref.watch(themeProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            currentUser.when(
              loading: () => const UserAccountsDrawerHeader(
                accountName: Text('Loading...'),
                accountEmail: Text(''),
                currentAccountPicture: CircleAvatar(
                  child: CircularProgressIndicator(),
                ),
              ),

              error: (_, __) => const UserAccountsDrawerHeader(
                accountName: Text('Unknown User'),
                accountEmail: Text(''),
                currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
              ),

              data: (user) {
                final username = user?.username ?? 'Unknown User';

                final email = user?.email ?? '';

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: context.primaryColor),

                  accountName: Text(username, style: context.titleText),

                  accountEmail: Text(email, style: context.captionText),

                  currentAccountPicture: CircleAvatar(
                    backgroundColor: context.colorScheme.onPrimary,
                    child: Text(
                      username.isEmpty ? '?' : username[0].toUpperCase(),
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Profile'),
              subtitle: const Text('Available soon'),
              onTap: () {
                Navigator.pop(context);
                AppSnackBar.info(context, 'Profile coming soon');
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              subtitle: const Text('Available soon'),
              onTap: () {
                Navigator.pop(context);
                AppSnackBar.info(
                  context,
                  'Settings available soon',
                  duration: const Duration(seconds: 2),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('ECE Chat v1.5.0'),
              onTap: () {
                Navigator.pop(context);

                showAboutDialog(
                  context: context,
                  applicationName: 'ECE Chat',
                  applicationVersion: 'v1.6.0',
                  applicationLegalese: 'Built with Flutter & Firebase',
                );
              },
            ),

            const Spacer(),

            const Divider(),

            ThemeSelectorTile(currentTheme: currentTheme),

            const Divider(),

            ListTile(
              leading: Icon(Icons.logout, color: context.errorColor),

              title: Text(
                'Logout',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.errorColor,
                ),
              ),

              onTap: () async {
                Navigator.pop(context);

                await ref.read(logoutServiceProvider).logout();

                // if (!context.mounted) return;

                // Navigator.of(context).pushAndRemoveUntil(
                //   MaterialPageRoute(builder: (_) => const AuthGate()),
                //   (_) => false,
                // );
              },
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'ECE Chat • Version 1.6.0',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
