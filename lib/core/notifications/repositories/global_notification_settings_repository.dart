import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/core/notifications/models/global_notification_settings.dart';

class GlobalNotificationSettingsRepository {
  GlobalNotificationSettingsRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('users').doc(uid).collection('private').doc('settings');

  Stream<GlobalNotificationSettings> watch(String uid) => _doc(
    uid,
  ).snapshots().map((s) => GlobalNotificationSettings.fromMap(s.data()));

  Future<void> setSound(String uid, bool on) =>
      _doc(uid).set({'messageSound': on}, SetOptions(merge: true));

  /// [duration] null = always.
  Future<void> mute(String uid, {Duration? duration}) => _doc(uid).set({
    'mutedUntil': duration == null
        ? Timestamp.fromDate(DateTime(2100))
        : Timestamp.fromDate(DateTime.now().add(duration)),
  }, SetOptions(merge: true));

  Future<void> unmute(String uid) => _doc(
    uid,
  ).set({'mutedUntil': FieldValue.delete()}, SetOptions(merge: true));
}
