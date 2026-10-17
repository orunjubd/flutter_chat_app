import 'package:chat_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/profile/controllers/profile_photo_controller.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:chat_app/features/authentication/providers/logout_provider.dart';
import 'package:chat_app/core/providers/theme_provider.dart';
import 'package:chat_app/features/settings/presentation/widgets/theme_selector_tile.dart';
import 'package:chat_app/shared/widgets/app_avatar.dart';
import 'package:chat_app/features/profile/presentation/screens/profile_screen.dart';

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

                //final imageUrl = user?.imageUrl.trim() ?? '';
                //final hasImage = imageUrl.isNotEmpty;

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainer,
                  ),

                  accountName: Text(username, style: context.titleText),

                  accountEmail: Text(email, style: context.captionText),

                  currentAccountPicture: GestureDetector(
                    onTap: user == null
                        ? null
                        : () {
                            final userId = user.id;
                            //final userImg = user.imageUrl;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!context.mounted) return;

                              _showProfilePhotoOptions(
                                context,
                                ref: ref,
                                userId: userId,
                                username: username,
                                imageUrl: user.imageUrl,
                              );
                            });
                          },
                    child: AppAvatar(
                      username: username,
                      imageUrl: user?.imageUrl,
                      radius: 28,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Profile'),
              subtitle: const Text('View and manage your profile'),
              onTap: () {
                Navigator.pop(context);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'profile_screen'),
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              subtitle: const Text('Privacy and app preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    settings: const RouteSettings(name: 'settings_screen'),
                    builder: (_) => const SettingsScreen(),
                  ),
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

  Future<void> _showProfilePhotoOptions(
    BuildContext context, {
    required WidgetRef ref,
    // required BuildContext context,
    required String userId,
    required String username,
    required String imageUrl,
  }) async {
    // Capture dependencies before opening the bottom sheet.
    final photoController = ref.read(profilePhotoProvider.notifier);

    final drawerNavigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        // Capture the navigator that owns the bottom sheet.
        final sheetNavigator = Navigator.of(sheetContext);

        // Prevent duplicate actions while a photo operation is running.
        bool actionStarted = false;

        Future<void> launchPicker({required bool fromCamera}) async {
          if (actionStarted) return;
          actionStarted = true;

          // Close the bottom sheet first.
          sheetNavigator.pop();

          // Start the selected operation.
          if (fromCamera) {
            await photoController.changeFromCamera(userId: userId);
          } else {
            await photoController.changeFromGallery(userId: userId);
          }

          // Do not show an error when the user cancels the picker.
          final photoState = ref.read(profilePhotoProvider);

          if (photoState.status != ProfilePhotoStatus.failure) {
            return;
          }

          // Wait until the sheet's dismissal frame completes.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;

            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(photoController.getUserFriendlyError()),
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take photo'),
                onTap: () => launchPicker(fromCamera: true),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => launchPicker(fromCamera: false),
              ),
              if (imageUrl.trim().isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('View profile photo'),
                  onTap: () {
                    if (actionStarted) return;
                    actionStarted = true;

                    sheetNavigator.pop();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;

                      _showProfilePhoto(
                        context,
                        username: username,
                        imageUrl: imageUrl,
                      );
                    });
                  },
                ),
              if (imageUrl.trim().isNotEmpty)
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
                    if (actionStarted) return;
                    actionStarted = true;

                    // 1. Close the bottom sheet.
                    sheetNavigator.pop();

                    // 2. Remove the photo from Cloudinary-independent
                    //    profile data in Firestore via the controller.
                    final removed = await photoController.removePhoto(
                      userId: userId,
                    );

                    // 3. Wait for the sheet dismissal to finish.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;

                      // 4. Close the drawer if it is still open.
                      if (drawerNavigator.mounted && drawerNavigator.canPop()) {
                        drawerNavigator.pop();
                      }

                      // 5. Show the notification after the drawer closes.
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;

                        if (removed) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Profile photo removed'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                photoController.getUserFriendlyError(),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      });
                    });
                  },
                ),
              const SizedBox(height: 12),
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
