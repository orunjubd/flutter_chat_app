import 'package:chat_app/features/profile/repositories/private_contact_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/auth_repository.dart';

import 'package:chat_app/features/chat/data/repositories/firestore_repository.dart';

// 🚀 B. Globally accessible provider instance mapping
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final firestoreRepositoryProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository();
});

// 🚀 C. State controller to manage UI loading indicators (Async states)
class AuthLoadingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  } // Initial state is NOT loading

  void setLoading(bool value) => state = value;
}

final authLoadingProvider = NotifierProvider<AuthLoadingNotifier, bool>(
  AuthLoadingNotifier.new,
);

// 🚀 D. Globally accessible provider instance mapping
final authStateProvider = StreamProvider<User?>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return repository.authStateChanges();
});

final emailVerifiedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.read(authRepositoryProvider);

  return repository.isEmailVerified();
});

final contactMigrationProvider = FutureProvider.family<void, String>((
  ref,
  uid,
) async {
  try {
    await ref.read(privateContactRepositoryProvider).migrateOwn(uid);
    debugPrint('✅ [Privacy] migration checked for $uid');
  } catch (e, st) {
    debugPrint('⚠️ [Privacy] migration failed: $e');
    debugPrintStack(stackTrace: st);
  }
});

final ensureProfileProvider = FutureProvider.family<void, String>((
  ref,
  uid,
) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.uid != uid) return;
  final db = FirebaseFirestore.instance;
  final ref0 = db.collection('users').doc(uid);
  try {
    final created = await db.runTransaction<bool>((tx) async {
      if ((await tx.get(ref0)).exists) return false;
      final email = user.email ?? '';
      tx.set(ref0, {
        'username': email.contains('@') ? email.split('@').first : 'User',
        'imageUrl': '',
        'createdAt': Timestamp.now(),
        'isOnline': false,
        'shareEmailWithGroupMembers': false,
        'sharePhoneNumberWithGroupMembers': false,
      });
      return true;
    });
    if (created) {
      debugPrint('🩹 [Auth] profile recreated for $uid');
      if ((user.email ?? '').isNotEmpty) {
        await PrivateContactRepository().setEmail(uid, user.email!);
      }
    }
  } catch (e) {
    debugPrint('⚠️ [Auth] ensure profile failed: $e');
  }
});
