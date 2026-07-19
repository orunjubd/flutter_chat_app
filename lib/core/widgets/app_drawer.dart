import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/authentication/providers/logout_provider.dart';
import 'package:chat_app/core/providers/theme_provider.dart';
import 'package:chat_app/features/settings/presentation/widgets/theme_selector_tile.dart';

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
                  decoration: const BoxDecoration(color: Color(0xFF1E4D40)),

                  accountName: Text(username),

                  accountEmail: Text(email),

                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      username.isEmpty ? '?' : username[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 26,
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
              subtitle: const Text('Coming soon'),
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile coming soon')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              subtitle: const Text('Coming soon'),
              onTap: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon')),
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
                  applicationVersion: 'v1.5.0',
                  applicationLegalese: 'Built with Flutter & Firebase',
                );
              },
            ),

            const Spacer(),

            const Divider(height: 1),

            ThemeSelectorTile(currentTheme: currentTheme),

            const Divider(height: 1),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),

              title: const Text('Logout', style: TextStyle(color: Colors.red)),

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

            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'ECE Chat • Version 1.5.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
