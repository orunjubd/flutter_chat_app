import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/call_type.dart';
import '../models/group_call_session.dart';
import '../models/participant_status.dart';

class GroupCallSignalingRepository {
  GroupCallSignalingRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('groupCalls');

  Future<GroupCallSession> create({
    String? conversationId,
    required String callerId,
    String? callerName,
    required List<String> inviteeIds,
    required Map<String, String> names,
    required CallType type,
  }) async {
    final doc = _col.doc();
    final data = <String, dynamic>{
      'conversationId': conversationId,
      'roomName': doc.id,
      'callerId': callerId,
      'callerName': callerName,
      'type': type.name,
      'state': 'active',
      'participantIds': [callerId, ...inviteeIds],
      // Only invitees are listed here: the inbox query uses array-contains on
      // this one field, so no composite index is needed.
      'invitedIds': inviteeIds,
      'statuses': {
        callerId: ParticipantStatus.joined.name,
        for (final id in inviteeIds) id: ParticipantStatus.invited.name,
      },
      'names': names,
      'createdAt': Timestamp.now(),
    };
    await doc.set(data);
    debugPrint(
      '📡 [GroupCall] created ${doc.id} (${inviteeIds.length + 1} people)',
    );
    return GroupCallSession.fromMap(doc.id, data);
  }

  Stream<GroupCallSession?> watchCall(String callId) =>
      _col.doc(callId).snapshots().map((s) {
        final d = s.data();
        return d == null ? null : GroupCallSession.fromMap(s.id, d);
      });

  /// First active call that still lists [uid] as invited, else null.
  Stream<GroupCallSession?> watchIncoming(String uid) =>
      _col.where('invitedIds', arrayContains: uid).snapshots().map((snap) {
        for (final doc in snap.docs) {
          if (doc.data()['state'] == 'active') {
            return GroupCallSession.fromMap(doc.id, doc.data());
          }
        }
        return null;
      });

  Future<void> join(String callId, String uid) =>
      _setStatus(callId, uid, ParticipantStatus.joined);
  Future<void> decline(String callId, String uid) =>
      _setStatus(callId, uid, ParticipantStatus.declined);
  Future<void> leave(String callId, String uid) =>
      _setStatus(callId, uid, ParticipantStatus.left);

  /// One transaction so "last person out ends the call" can't race.
  Future<void> _setStatus(String callId, String uid, ParticipantStatus status) {
    return _db.runTransaction((tx) async {
      final ref = _col.doc(callId);
      final data = (await tx.get(ref)).data();
      if (data == null || data['state'] == 'ended') return;

      final statuses = Map<String, dynamic>.from(data['statuses'] as Map)
        ..[uid] = status.name;
      final joined = statuses.values.where((s) => s == 'joined').length;
      final invited = statuses.values.where((s) => s == 'invited').length;
      // Ends when nobody is in it, or one person is left with nobody to wait for.
      final ended = joined == 0 || (joined == 1 && invited == 0);

      tx.update(ref, {
        'statuses.$uid': status.name,
        'invitedIds': FieldValue.arrayRemove([uid]),
        if (ended && data['state'] != 'ended') ...{
          'state': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
        },
      });
    });
  }

  Future<void> markUnansweredMissed(String callId) {
    return _db.runTransaction((tx) async {
      final ref = _col.doc(callId);
      final data = (await tx.get(ref)).data();
      if (data == null || data['state'] == 'ended') return;

      final statuses = Map<String, dynamic>.from(data['statuses'] as Map);
      final pending = [
        for (final e in statuses.entries)
          if (e.value == 'invited') e.key,
      ];
      if (pending.isEmpty) return;

      final joined = statuses.values.where((s) => s == 'joined').length;
      tx.update(ref, {
        for (final id in pending) 'statuses.$id': ParticipantStatus.missed.name,
        'invitedIds': <String>[],
        if (joined <= 1) ...{
          'state': 'ended',
          'endedAt': FieldValue.serverTimestamp(),
        },
      });
    });
  }
}
