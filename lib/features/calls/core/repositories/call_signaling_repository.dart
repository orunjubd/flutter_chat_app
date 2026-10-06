import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/features/calls/core/models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/models/call_direction.dart';
import 'package:chat_app/features/chat/data/repositories/conversation_repository.dart';

class CallSignalingRepository {
  CallSignalingRepository({
    FirebaseFirestore? firestore,
    required ConversationRepository conversationRepository, // NEW dependency
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _conversationRepository = conversationRepository;

  final FirebaseFirestore _firestore;
  final ConversationRepository _conversationRepository; // NEW

  CollectionReference<Map<String, dynamic>> get _callsCollection =>
      _firestore.collection('calls');

  Future<CallSession> createOutgoingCall({
    required String callerId,
    required String calleeId,
    required CallType type,
    String? callerName,
  }) async {
    // Resolve (or create) the 1:1 conversation up front, the same
    // helper used everywhere else a conversation needs to exist
    // between two users — no separate/duplicate lookup logic.
    final conversation = await _conversationRepository.createOrOpenConversation(
      currentUserId: callerId,
      otherUserId: calleeId,
    );

    final callDocument = _callsCollection.doc();
    final now = Timestamp.now();

    final callSession = CallSession(
      id: callDocument.id,
      conversationId: conversation.id, // NEW
      roomName: callDocument.id,
      callerId: callerId,
      calleeId: calleeId,
      callerName: callerName,
      type: type,
      direction: CallDirection.outgoing,
      state: CallState.dialing,
      createdAt: now,
    );

    await callDocument.set({
      'conversationId': callSession.conversationId, // NEW — persisted
      'callerId': callSession.callerId,
      'roomName': callSession.roomName,
      'calleeId': callSession.calleeId,
      'callerName': callSession.callerName,
      'type': callSession.type.name,
      'direction': callSession.direction.name,
      'state': callSession.state.name,
      'createdAt': callSession.createdAt,
      'connectedAt': null,
      'endedAt': null,
    });

    return callSession;
  }

  // FIXED: was manually reconstructing CallSession — silently dropped
  // endReason on every read, and hardcoded direction wrong for the callee.
  // Uses CallSession.fromMap now, same as fetchCallOnce already did — one
  // parsing path instead of three drifting independently.
  Stream<CallSession?> watchCall({required String callId}) {
    return _callsCollection.doc(callId).snapshots().map((document) {
      if (!document.exists) return null;
      final data = document.data();
      if (data == null) return null;
      return CallSession.fromMap(document.id, data);
    });
  }

  Stream<CallSession?> watchIncomingCall({required String calleeId}) {
    return _callsCollection
        .where('calleeId', isEqualTo: calleeId)
        .where('state', isEqualTo: CallState.ringing.name)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final document = snapshot.docs.first;
          final data = document.data();
          return CallSession.fromMap(document.id, data);
        });
  }

  Future<void> updateCallState({
    required String callId,
    required CallState state,
  }) async {
    final updateData = <String, dynamic>{'state': state.name};

    if (state == CallState.connected) {
      updateData['connectedAt'] = FieldValue.serverTimestamp();
    }

    if (state == CallState.ended) {
      updateData['endedAt'] = FieldValue.serverTimestamp();
    }

    await _callsCollection.doc(callId).update(updateData);

    debugPrint('📡 [CallSignalingRepository] Call $callId → ${state.name}');
  }

  Future<void> markMissedCall({required String callId}) async {
    await _firestore.collection('calls').doc(callId).update({
      'state': CallState.missed.name,
      'endedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('📡 [CallSignalingRepository] Call $callId → missed');
  }

  Future<void> markBusy({required String callId}) async {
    await _callsCollection.doc(callId).update({
      'state': CallState.rejected.name,
      'endReason': 'busy',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<CallSession?> fetchCallOnce({required String callId}) async {
    try {
      final doc = await _firestore.collection('calls').doc(callId).get();

      if (!doc.exists || doc.data() == null) {
        debugPrint(
          '⚠️ [CallSignalingRepository] '
          'Call $callId not found.',
        );
        return null;
      }

      final data = doc.data()!;

      return CallSession.fromMap(doc.id, data);
    } catch (error, stackTrace) {
      debugPrint(
        '❌ [CallSignalingRepository] '
        'Failed to fetch call $callId: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      return null;
    }
  }

  /// Tells the caller this device received the call (Calling… → Ringing…).
  Future<void> markCalleeRinging({required String callId}) async {
    await _callsCollection.doc(callId).update({
      'calleeRingingAt': FieldValue.serverTimestamp(),
    });
  }
}
