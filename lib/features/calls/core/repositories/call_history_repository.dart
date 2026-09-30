import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/call_history.dart';
import '../models/call_session.dart';

final callHistoryRepositoryProvider = Provider<CallHistoryRepository>((ref) {
  return CallHistoryRepository(firestore: FirebaseFirestore.instance);
});

class CallHistoryRepository {
  CallHistoryRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _historyCollection =>
      _firestore.collection('callHistory');

  /// Creates a permanent history record from a finished call session.
  Future<void> createFromCallSession({
    required CallSession callSession,
    required CallHistoryStatus status,
  }) async {
    final duration = callSession.duration;

    final history = CallHistory(
      id: callSession.id,
      callId: callSession.id,
      callerId: callSession.callerId,
      calleeId: callSession.calleeId,
      type: callSession.type,
      status: status,
      startedAt: callSession.createdAt,
      connectedAt: callSession.connectedAt,
      endedAt: callSession.endedAt,
      duration: duration,
    );

    await _historyCollection.doc(history.id).set({
      'callId': history.callId,
      'callerId': history.callerId,
      'calleeId': history.calleeId,
      'type': history.type.name,
      'status': history.status.name,
      'startedAt': history.startedAt,
      'connectedAt': history.connectedAt,
      'endedAt': history.endedAt,
      'durationSeconds': history.duration?.inSeconds,
    });

    debugPrint(
      '📚 [CallHistoryRepository] '
      'History created → ${history.id}',
    );
  }
}
