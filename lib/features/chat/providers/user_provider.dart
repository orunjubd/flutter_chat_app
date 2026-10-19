import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/features/chat/data/models/app_user.dart';
//import 'package:chat_app/features/chat/data/repositories/firestore_repository.dart';
import 'package:chat_app/features/authentication/providers/auth_provider.dart';
//import 'package:chat_app/features/chat/providers/user_directory_provider.dart';

final firebaseAuthUserProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);
//======================================================================
//UPDATE YOUR CODE TO THIS:
//======================================================================
final currentUserIdProvider = Provider<String?>((ref) {
  final fromStream = ref.watch(firebaseAuthUserProvider).value?.uid;
  return fromStream ?? FirebaseAuth.instance.currentUser?.uid;
});

// final currentUserProvider = FutureProvider<AppUser?>((ref) async {
//   final uid = ref.watch(currentUserIdProvider);
//   if (uid == null) return null;

//   return ref.read(firestoreRepositoryProvider).getUser(uid);
// });

// final userByIdProvider = FutureProvider.family<AppUser?, String>((
//   ref,
//   userId,
// ) async {
//   final repository = ref.read(userRepositoryProvider);
//   return repository.getUserById(userId);
// });
/// updated currentUserProvider & userByIdProvider to use StreamProvider instead of FutureProvider for real-time updates

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(firestoreRepositoryProvider).watchUser(uid);
});

final userByIdProvider = StreamProvider.family<AppUser?, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value(null);
  return ref.watch(firestoreRepositoryProvider).watchUser(userId);
});
