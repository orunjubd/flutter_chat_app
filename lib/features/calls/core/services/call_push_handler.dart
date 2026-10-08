// features/calls/services/call_push_handler.dart
//import 'package:chat_app/features/calls/providers/call_provider.dart';
import 'package:chat_app/features/calls/core/services/callkit_bridge.dart';
import 'package:chat_app/features/calls/core/services/pending_call_service.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming_maintained/entities/call_event.dart';
//import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';
//import 'package:chat_app/features/calls/core/services/incoming_call_service.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart'
    as call_model;

/// ===============================================================
/// FCM BACKGROUND MESSAGE HANDLER
/// ===============================================================
///
/// Called when an FCM message arrives while the app is:
/// - in background
/// - terminated
///
/// For an incoming call, we show the native CallKit UI.
///

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final type = message.data['type'];
  final callId = (message.data['callId'] as String?)?.trim();
  if (callId == null || callId.isEmpty) return;

  if (type == 'group_call_cancelled') {
    debugPrint('🔕 [CallPush] group call cancelled → $callId');
    await CallKitBridge.endNative(callId);
    return;
  }
  if (type != 'incoming_call' && type != 'incoming_group_call') return;

  final isGroup = type == 'incoming_group_call';
  final callerName = (message.data['callerName'] as String?)?.trim();
  final avatarUrl = (message.data['callerAvatarUrl'] as String?)?.trim();
  debugPrint(
    '🔔 [CallPush] Incoming ${isGroup ? "GROUP " : ""}FCM: callId=$callId, '
    'callType=${message.data['callType']}',
  );
  try {
    await CallKitBridge.showRaw(
      callId: callId,
      callerName: callerName == null || callerName.isEmpty
          ? 'Unknown'
          : callerName,
      callerAvatarUrl: avatarUrl == null || avatarUrl.isEmpty
          ? null
          : avatarUrl,
      isVideoCall: message.data['callType'] == 'video',
      isGroup: isGroup,
    );
    await PendingCallService.instance.markNativeShown(callId);
    if (!isGroup) await _markCalleeRingingFromBackground(callId);
  } catch (error, stackTrace) {
    debugPrint('❌ [CallPush] showRaw failed: callId=$callId, error=$error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

/// Background-isolate twin of CallSignalingRepository.markCalleeRinging.
/// Raw Firestore on purpose: no Riverpod container exists in this isolate.
Future<void> _markCalleeRingingFromBackground(String callId) async {
  try {
    await _initializeFirebaseForBackground();
    // Auth restores asynchronously in a fresh isolate; rules need request.auth.
    await FirebaseAuth.instance.authStateChanges().first.timeout(
      const Duration(seconds: 3),
      onTimeout: () => null,
    );

    final ref = FirebaseFirestore.instance.collection('calls').doc(callId);
    final data = (await ref.get()).data();
    if (data == null ||
        data['state'] != call_model.CallState.ringing.name ||
        data['calleeRingingAt'] != null) {
      return; // gone, answered, or already acknowledged by the other path
    }
    await ref.update({'calleeRingingAt': FieldValue.serverTimestamp()});
    debugPrint('📡 [CallPush] calleeRingingAt written → $callId');
  } catch (e) {
    debugPrint(
      '⚠️ [CallPush] could not write calleeRingingAt: $e',
    ); // best-effort
  }
}

/// ===============================================================
/// BACKGROUND CALL ACCEPT
/// ===============================================================
///
/// We do NOT try to connect LiveKit here.
///
/// Why?
///
/// A CallKit background callback is not the correct place to start
/// the complete Flutter LiveKit call engine.
///
/// Instead:
///
/// CallKit Accept
///      ↓
/// Firestore = connecting
///      ↓
/// App opens/resumes
///      ↓
/// CallProvider sees the active call
///      ↓
/// LiveKit connection happens in normal app lifecycle
///
Future<void> _handleBackgroundCallAccept(String callId) async {
  try {
    await PendingCallService.instance.setAcceptedCall(callId);

    await _initializeFirebaseForBackground();

    await FirebaseFirestore.instance.collection('calls').doc(callId).update({
      'state': call_model.CallState.connecting.name,
    });

    debugPrint('📡 [CallKit Background] Call $callId → connecting');
  } catch (e) {
    debugPrint('❌ [CallKit Background] Accept handling failed: $e');
  }
}

/// ===============================================================
/// BACKGROUND CALL DECLINE
/// ===============================================================
///
/// Receiver actively rejected the incoming call.
///
/// Firestore becomes the source of truth:
///
/// ringing → rejected
///
Future<void> _handleBackgroundCallDecline(String callId) async {
  try {
    final firestore = FirebaseFirestore.instance;

    final callDoc = await firestore.collection('calls').doc(callId).get();

    if (!callDoc.exists || callDoc.data() == null) {
      await _setGroupStatusFromBackground(
        callId,
        'declined',
      ); // 'missed' in timeout handler
      return;
    }

    final data = callDoc.data()!;
    final currentState = data['state'] as String?;

    if (currentState != call_model.CallState.ringing.name) {
      return;
    }

    await firestore.collection('calls').doc(callId).update({
      'state': call_model.CallState.rejected.name,
      'endedAt': FieldValue.serverTimestamp(),
    });
  } catch (error) {
    // Keep background callback safe.
  }
}

/// ===============================================================
/// BACKGROUND CALL TIMEOUT
/// ===============================================================
///
/// CallKit timeout means:
///
/// Caller was ringing
///      ↓
/// Receiver did not answer
///      ↓
/// missed
///
Future<void> _handleBackgroundCallTimeout(String callId) async {
  try {
    final firestore = FirebaseFirestore.instance;

    final callDoc = await firestore.collection('calls').doc(callId).get();

    if (!callDoc.exists || callDoc.data() == null) {
      await _setGroupStatusFromBackground(callId, 'missed');
      return;
    }

    final data = callDoc.data()!;
    final currentState = data['state'] as String?;

    if (currentState != call_model.CallState.ringing.name) {
      return;
    }

    await firestore.collection('calls').doc(callId).update({
      'state': call_model.CallState.missed.name,
      'endedAt': FieldValue.serverTimestamp(),
    });
  } catch (error) {
    // Keep background callback safe.
  }
}

/// Group twin of the 1:1 background decline/timeout. Plain writes: no Riverpod here.
Future<void> _setGroupStatusFromBackground(String callId, String status) async {
  try {
    await _initializeFirebaseForBackground();
    final user =
        FirebaseAuth.instance.currentUser ??
        await FirebaseAuth.instance.authStateChanges().first.timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        );
    if (user == null) return;

    final ref = FirebaseFirestore.instance.collection('groupCalls').doc(callId);
    final d = (await ref.get()).data();
    if (d == null || d['state'] == 'ended') return;
    if ((d['statuses'] as Map?)?[user.uid] != 'invited') return;

    await ref.update({
      'statuses.${user.uid}': status,
      'invitedIds': FieldValue.arrayRemove([user.uid]),
    });
    debugPrint('📡 [CallKit Background] group $status → $callId');
  } catch (e) {
    debugPrint('⚠️ [CallKit Background] group status write failed: $e');
  }
}

/// ===============================================================
/// FIREBASE INITIALIZATION FOR BACKGROUND ISOLATE
/// ===============================================================
///
/// Firebase is initialized normally in main.dart.
///
/// But CallKit background callbacks may execute in another isolate.
///
/// Therefore we make sure Firebase is initialized before accessing
/// Firestore from this background callback.
///
Future<void> _initializeFirebaseForBackground() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

/// ===============================================================
/// CALLKIT BACKGROUND EVENT HANDLER
/// ===============================================================
///
/// This handler is called by CallKit when the user interacts with
/// the native incoming-call UI while the Flutter app is not
/// necessarily running in the foreground.
///
/// Important events for our ECE call engine:
///
/// Accept  → app should continue the call flow
/// Decline → Firestore = rejected
/// Timeout → Firestore = missed
///
@pragma('vm:entry-point')
Future<void> callKitBackgroundHandler(CallEvent event) async {
  await _initializeFirebaseForBackground();
  switch (event) {
    case CallEventActionCallAccept(:final id):
      debugPrint('📞 [CallKit Background] Accept → $id');

      await _handleBackgroundCallAccept(id);

    case CallEventActionCallDecline(:final id):
      debugPrint('❌ [CallKit Background] Decline → $id');

      await _handleBackgroundCallDecline(id);

    case CallEventActionCallTimeout(:final id):
      debugPrint('⌛ [CallKit Background] Timeout → $id');

      await _handleBackgroundCallTimeout(id);

    default:
      break;
  }
}
