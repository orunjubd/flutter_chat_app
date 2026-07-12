import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/chat/data/models/app_user.dart';
import 'package:chat_app/features/chat/data/repositories/user_repository.dart';

///------------------------------------------------------------
/// Repository
///------------------------------------------------------------
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

///------------------------------------------------------------
/// Stream all users except myself
///------------------------------------------------------------
final usersDirectoryProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  final repository = ref.read(userRepositoryProvider);

  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    return Stream.value([]);
  }

  return repository.usersStream(currentUserId: currentUser.uid);
});
