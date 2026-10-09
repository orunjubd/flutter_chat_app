import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/profile/providers/profile_photo_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/authentication/providers/logout_provider.dart';
import 'package:chat_app/core/providers/theme_provider.dart';
import 'package:chat_app/features/settings/presentation/widgets/theme_selector_tile.dart';
import 'package:chat_app/core/dialogs/app_snackbar.dart';
//import 'package:chat_app/features/profile/providers/profile_photo_provider.dart';

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

              error: (_, _) => const UserAccountsDrawerHeader(
                accountName: Text('Unknown User'),
                accountEmail: Text(''),
                currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
              ),

              data: (user) {
                final username = user?.username ?? 'Unknown User';
                final email = user?.email ?? '';

                final imageUrl = user?.imageUrl.trim() ?? '';
                final hasImage = imageUrl.isNotEmpty;

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainer,
                  ),

                  accountName: Text(username, style: context.titleText),

                  accountEmail: Text(email, style: context.captionText),

                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      _showProfilePhotoOptions(
                        context,
                        ref: ref,
                        userId: user!.id,
                        username: username,
                        imageUrl: imageUrl,
                      );
                    },

                    child: CircleAvatar(
                      backgroundColor: context.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),

                      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,

                      child: hasImage
                          ? null
                          : Text(
                              username.isEmpty
                                  ? '?'
                                  : username[0].toUpperCase(),
                              style: context.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                // Close the drawer.
                Navigator.pop(context);

                // Remove every page above the ConversationListScreen.
                Navigator.of(context).popUntil((route) => route.isFirst);

                // Allow disposed widgets to cancel their
                // Firestore listeners.
                await Future.delayed(const Duration(milliseconds: 50));

                // Logout.
                await ref.read(logoutServiceProvider).logout();
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

  // ---------------------------------------------------------------------------
  // PROFILE PHOTO OPTIONS
  // ---------------------------------------------------------------------------

  void _showProfilePhotoOptions(
    BuildContext context, {
    required WidgetRef ref,
    required String userId,
    required String username,
    required String imageUrl,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Change profile photo'),
                onTap: () {
                  // Close bottom sheet.
                  Navigator.pop(sheetContext);

                  // Close Drawer.
                  Navigator.pop(context);

                  // Wait for the Drawer route to finish closing.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!context.mounted) return;

                    ref
                        .read(profilePhotoProvider.notifier)
                        .changeFromGallery(userId: userId);
                  });
                },
              ),

              if (imageUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('View profile photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showProfilePhoto(
                      context,
                      username: username,
                      imageUrl: imageUrl,
                    );
                  },
                ),

              if (imageUrl.isNotEmpty)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: context.errorColor,
                  ),
                  title: Text(
                    'Remove profile photo',
                    style: TextStyle(color: context.errorColor),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);

                    final removed = await ref
                        .read(profilePhotoProvider.notifier)
                        .removePhoto(userId: userId);

                    if (!context.mounted) return;

                    if (removed) {
                      AppSnackBar.success(context, 'Profile photo removed');
                    } else {
                      AppSnackBar.error(
                        context,
                        'Failed to remove profile photo',
                      );
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE PHOTO PREVIEW
  // ---------------------------------------------------------------------------

  void _showProfilePhoto(
    BuildContext context, {
    required String username,
    required String imageUrl,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return Container(
                    height: 280,
                    width: 280,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.broken_image_outlined, size: 64),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
