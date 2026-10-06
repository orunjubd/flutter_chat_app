import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:chat_app/features/calls/core/models/group_call_history_entry.dart';
import 'package:chat_app/features/calls/core/models/group_call_session.dart';

class GroupCallHistoryRepository {
  GroupCallHistoryRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('groupCallHistory');

  Future<void> record({
    required String uid,
    required GroupCallSession session,
    required GroupCallOutcome outcome,
    int? durationSeconds,
  }) async {
    await _col(uid).doc(session.id).set({
      'type': session.type.name,
      'outcome': outcome.name,
      'startedAt': session.createdAt,
      'durationSeconds': durationSeconds,
      'callerName': session.callerName,
      'conversationId': session.conversationId,
      'participantNames': [
        for (final id in session.participantIds) session.nameOf(id),
      ],
    });
    debugPrint('📚 [GroupHistory] ${outcome.name} → ${session.id}');
  }

  Stream<List<GroupCallHistoryEntry>> watch(String uid) => _col(uid)
      .orderBy('startedAt', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (s) => [
          for (final d in s.docs) GroupCallHistoryEntry.fromMap(d.id, d.data()),
        ],
      );
}
