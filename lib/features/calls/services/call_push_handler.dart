// features/calls/services/call_push_handler.dart
//import 'package:chat_app/features/calls/providers/call_provider.dart';
import 'package:chat_app/features/calls/services/pending_call_service.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming_maintained/entities/call_event.dart';
//import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';
import 'package:chat_app/features/calls/services/incoming_call_service.dart';
import 'package:chat_app/features/calls/data/models/call_state.dart'
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
/// IMPORTANT:
/// This function runs in a background isolate.
/// Therefore it must be an entry point.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final type = message.data['type'];
  if (type != 'incoming_call') return; // ignore anything that isn't a call

  const service = IncomingCallService();
  await service.showIncomingCall(
    callId: message.data['callId'] ?? '',
    callerName: message.data['callerName'] ?? 'Unknown',
    callerAvatarUrl: message.data['callerAvatarUrl'],
    isVideoCall: message.data['callType'] == 'video',
  );
}

/// ===============================================================
/// FCM FOREGROUND MESSAGE LISTENER
/// ===============================================================
///
/// Called when an FCM message arrives while the app is currently
/// open and in the foreground.
///
/// We also show CallKit so incoming calls use the same native
/// incoming-call experience.
///
void registerForegroundCallListener() {
  FirebaseMessaging.onMessage.listen((message) async {
    if (message.data['type'] != 'incoming_call') return;

    const service = IncomingCallService();
    await service.showIncomingCall(
      callId: message.data['callId'] ?? '',
      callerName: message.data['callerName'] ?? 'Unknown',
      callerAvatarUrl: message.data['callerAvatarUrl'],
      isVideoCall: message.data['callType'] == 'video',
    );
  });
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
