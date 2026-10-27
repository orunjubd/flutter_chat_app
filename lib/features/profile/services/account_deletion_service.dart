import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:chat_app/features/chat/providers/group_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// + imports: callProvider, groupCallProvider, groupRepositoryProvider

class AccountDeletionException implements Exception {
  AccountDeletionException(this.message);
  final String message;
}

final accountDeletionServiceProvider = Provider(
  (ref) => AccountDeletionService(ref),
);

class AccountDeletionService {
  AccountDeletionService(this._ref);
  final Ref _ref;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Order matters: everything that needs sign-in happens first, the Auth user is deleted last.
  Future<void> delete({required String password}) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw AccountDeletionException(
        'Only email and password accounts can be deleted here.',
      );
    }
    final uid = user.uid;

    if (_ref.read(callProvider).phase.isBusy ||
        _ref.read(groupCallProvider).phase.isBusy) {
      throw AccountDeletionException('End your call first.');
    }

    // 1. Re-authenticate. Firebase refuses user.delete() without a recent login.
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [Delete] reauth: ${e.code}');
      throw AccountDeletionException(
        (e.code == 'wrong-password' || e.code == 'invalid-credential')
            ? 'Wrong password.'
            : 'Could not verify your password. Try again.',
      );
    }

    final profile = await _db.collection('users').doc(uid).get();
    final name = (profile.data()?['username'] as String?) ?? 'Someone';

    // 2. Leave every group (auto-promotes an admin; the last member soft-deletes the group).
    //    Any failure stops here, before anything destructive.
    final convs = await _db
        .collection('conversations')
        .where('participantIds', arrayContains: uid)
        .get();
    final groups = _ref.read(groupRepositoryProvider);
    for (final d in convs.docs) {
      if (d.data()['type'] == 'group') {
        await groups.leave(groupId: d.id, uid: uid, name: name);
      }
    }

    // 3. Own data. The rules allow get on private/email and private/phone, not a list,
    //    so these two are deleted by path.
    final userRef = _db.collection('users').doc(uid);
    await userRef.collection('private').doc('email').delete();
    await userRef.collection('private').doc('phone').delete();
    await userRef.collection('private').doc('settings').delete();
    await _deleteAll(userRef.collection('groupCallHistory'));
    await _deleteAll(userRef.collection('conversationSettings'));
    await _db.collection('presence').doc(uid).delete();
    await _db.collection('typing').doc(uid).delete();

    // 4. Tombstone: old messages and calls keep a valid sender, with no personal data.
    await userRef.update({
      'username': 'Deleted account',
      'imageUrl': '',
      'isOnline': false,
      'shareEmailWithGroupMembers': false,
      'sharePhoneNumberWithGroupMembers': false,
      'fcmToken': FieldValue.delete(), // no more pushes
      'deletedAt': FieldValue.serverTimestamp(),
    });

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('⚠️ [Delete] token delete failed: $e');
    }

    // 5. Auth user last. Signing out is automatic, AuthGate shows the login screen.
    await user.delete();
    debugPrint('✅ [Delete] account removed: $uid');
  }

  Future<void> _deleteAll(CollectionReference<Map<String, dynamic>> col) async {
    while (true) {
      final snap = await col.limit(400).get();
      if (snap.docs.isEmpty) return;
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
  }
}
