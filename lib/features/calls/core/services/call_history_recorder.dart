// features/calls/core/services/call_history_recorder.dart
//
// Extracted from _createCallHistory + _sendCallSystemMessage.
//
// Fixes 8(b): the de-dupe set is bounded.
// Fixes 8(c): only ONE side writes the chat system message.

import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_history.dart';
import '../repositories/call_history_repository.dart';

typedef SystemMessageSender =
    Future<void> Function(String conversationId, CallSystemMessage message);

class CallHistoryRecorder {
  CallHistoryRecorder({
    required CallHistoryRepository repository,
    required SystemMessageSender sendSystemMessage,
    this.maxTrackedIds = 50,
  }) : _repository = repository,
       _sendSystemMessage = sendSystemMessage;

  final CallHistoryRepository _repository;
  final SystemMessageSender _sendSystemMessage;
  final int maxTrackedIds;

  /// Bounded LRU-ish set. Your original grew for the lifetime of the app.
  final List<String> _recorded = <String>[];

  bool _alreadyRecorded(String callId) => _recorded.contains(callId);

  void _remember(String callId) {
    _recorded.add(callId);
    if (_recorded.length > maxTrackedIds) {
      _recorded.removeRange(0, _recorded.length - maxTrackedIds);
    }
  }

  Future<void> record({
    required CallSession session,
    required CallHistoryStatus status,
    required String localUserId,
    String? callerName,
  }) async {
    if (_alreadyRecorded(session.id)) {
      debugPrint('⚠️ [History] already recorded ${session.id}');
      return;
    }
    _remember(session.id);

    try {
      await _repository.createFromCallSession(
        callSession: session,
        status: status,
      );
      debugPrint('📚 [History] saved ${session.id} (${status.name})');
    } catch (e, st) {
      _recorded.remove(session.id); // allow a retry
      debugPrint('❌ [History] save failed: $e');
      debugPrintStack(stackTrace: st);
      return;
    }

    // Only the caller writes the chat bubble. Previously both sides did, and it
    // only appeared once because the doc id happened to be the call id — an
    // accident, not a design.
    if (session.callerId != localUserId) return;

    try {
      final message = CallSystemMessage(
        id: session.id,
        senderId: session.callerId,
        // senderName: callerName ?? 'Unknown',
        senderName:
            'System', // deliberate placeholder — call bubbles don't need a real name today
        // ... rest unchanged ...
        createdAt: session.endedAt ?? Timestamp.now(),
        readBy: const [],
        deletedForEveryone: false,
        deletedBy: const [],
        callType: session.type,
        status: status,
        durationSeconds: session.duration?.inSeconds,
      );

      await _sendSystemMessage(session.conversationId, message);
      debugPrint('📞 [History] system message sent → ${message.id}');
    } catch (e, st) {
      debugPrint('❌ [History] system message failed: $e');
      debugPrintStack(stackTrace: st);
    }
  }
}
