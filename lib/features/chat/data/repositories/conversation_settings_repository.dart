import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conversation_settings.dart';

class ConversationSettingsRepository {
  ConversationSettingsRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('conversationSettings');

  Stream<Map<String, ConversationSettings>> watchAll(String uid) =>
      _col(uid).snapshots().map(
        (s) => {
          for (final d in s.docs)
            d.id: ConversationSettings.fromMap(d.id, d.data()),
        },
      );

  /// Default settings are not stored: the document is removed instead.
  Future<void> save(String uid, ConversationSettings s) => s.isDefault
      ? _col(uid).doc(s.conversationId).delete()
      : _col(uid).doc(s.conversationId).set(s.toMap());
}
