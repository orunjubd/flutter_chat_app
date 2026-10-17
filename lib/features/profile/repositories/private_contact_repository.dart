import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final privateContactRepositoryProvider = Provider(
  (ref) => PrivateContactRepository(),
);

/// null = not readable (not shared) or not set.
final contactEmailProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, uid) => ref.watch(privateContactRepositoryProvider).readEmail(uid),
);
final contactPhoneProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, uid) => ref.watch(privateContactRepositoryProvider).readPhone(uid),
);

class PrivateContactRepository {
  PrivateContactRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid, String name) =>
      _db.collection('users').doc(uid).collection('private').doc(name);

  Future<void> setEmail(String uid, String v) =>
      _doc(uid, 'email').set({'value': v.trim()});
  Future<void> setPhone(String uid, String v) =>
      _doc(uid, 'phone').set({'value': v.trim()});

  Future<String?> _read(String uid, String name) async {
    try {
      return (await _doc(uid, name).get()).data()?['value'] as String?;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return null; // owner has not shared it
      rethrow;
    }
  }

  Future<String?> readEmail(String uid) => _read(uid, 'email');
  Future<String?> readPhone(String uid) => _read(uid, 'phone');

  /// Idempotent: copies public email/phone into private docs, then removes the public fields.
  Future<void> migrateOwn(String uid) async {
    final userRef = _db.collection('users').doc(uid);
    final d = (await userRef.get()).data();
    if (d == null) return;
    final email = d['email'] as String?;
    final phone = d['phoneNumber'] as String?;
    if (email == null && phone == null) return;
    final batch = _db.batch();
    if (email != null) batch.set(_doc(uid, 'email'), {'value': email});
    if (phone != null) batch.set(_doc(uid, 'phone'), {'value': phone});
    batch.update(userRef, {
      if (email != null) 'email': FieldValue.delete(),
      if (phone != null) 'phoneNumber': FieldValue.delete(),
    });
    await batch.commit();
  }
}
