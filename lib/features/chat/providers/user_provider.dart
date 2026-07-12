import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/data/models/app_user.dart';
//import 'package:chat_app/features/chat/data/repositories/firestore_repository.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/chat/providers/user_directory_provider.dart';

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser == null) {
    return null;
  }

  final repository = ref.read(firestoreRepositoryProvider);

  return repository.getUser(firebaseUser.uid);
});

final currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

final userByIdProvider = FutureProvider.family<AppUser?, String>((
  ref,
  userId,
) async {
  final repository = ref.read(userRepositoryProvider);

  return repository.getUserById(userId);
});
