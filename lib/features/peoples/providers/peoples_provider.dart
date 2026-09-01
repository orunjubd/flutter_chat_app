// lib/features/peoples/providers/peoples_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/chat/providers/user_directory_provider.dart';

/// Thin wrapper around the existing user directory, scoped for the
/// Peoples screen — reuses userDirectoryProvider rather than
/// re-fetching users independently. Excludes the current signed-in
/// user from the list (a real user shouldn't see themself here).
///
/// ASSUMPTION: userDirectoryProvider is a Stream/FutureProvider
/// returning AsyncValue<List<AppUser>>. Adjust if it's shaped
/// differently.
final peoplesProvider = Provider<AsyncValue<List<AppUser>>>((ref) {
  final directory = ref.watch(usersDirectoryProvider);
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  return directory.whenData(
    (users) => users.where((u) => u.id != currentUserId).toList(),
  );
});
