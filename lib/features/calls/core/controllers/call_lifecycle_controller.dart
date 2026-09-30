// features/calls/core/controllers/call_lifecycle_controller.dart
//
// start / accept / reject / end. No listeners, no audio, no history — those are
// injected as callbacks so this class is testable without Firebase.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:chat_app/features/calls/core/models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart'
    as call_model;
import 'package:chat_app/features/calls/core/repositories/call_signaling_repository.dart';
import 'package:chat_app/features/calls/core/services/call_service.dart';
import 'package:chat_app/features/calls/core/services/call_token_service.dart';
import 'call_media_controller.dart';

class CallStartResult {
  const CallStartResult({required this.session, this.error});
  final CallSession? session;
  final String? error;
  bool get ok => session != null && error == null;
}

class CallLifecycleController {
  CallLifecycleController({
    required CallSignalingRepository signaling,
    required CallTokenService tokenService,
    required CallService callService,
    required CallMediaController media,
    required this.ringTimeout,
  }) : _signaling = signaling,
       _tokenService = tokenService,
       _callService = callService,
       _media = media;

  final CallSignalingRepository _signaling;
  final CallTokenService _tokenService;
  final CallService _callService;
  final CallMediaController _media;
  final Duration ringTimeout;

  Timer? _missedCallTimer;
  bool _startInProgress = false;
  bool _acceptInProgress = false;
  bool _wasConnected = false;

  bool get wasConnected => _wasConnected;

  // --- outgoing --------------------------------------------------------------

  Future<CallStartResult> startCall({
    required String callerId,
    required String calleeId,
    required CallType type,
    String? callerName,
    required VoidCallback onTimeout,
    // Fired the moment the call session exists in Firestore — well before
    // the token fetch / LiveKit connect that follows. Lets the caller (i.e.
    // CallNotifier) record the call id immediately, so pressing "End" during
    // the connect window still has a real callId to write a cancellation
    // against, instead of silently doing nothing.
    void Function(CallSession session)? onSessionCreated,
  }) async {
    if (_startInProgress) {
      debugPrint('⚠️ [Lifecycle] start ignored — already starting.');
      return const CallStartResult(session: null, error: null);
    }
    _startInProgress = true;
    _wasConnected = false;
    _cancelMissedTimer();
    _media.reset();

    try {
      final session = await _signaling.createOutgoingCall(
        callerId: callerId,
        calleeId: calleeId,
        type: type,
        callerName: callerName,
      );
      onSessionCreated?.call(session);

      await _signaling.updateCallState(
        callId: session.id,
        state: call_model.CallState.ringing,
      );

      final token = await _tokenService.fetchDevelopmentToken(
        roomName: session.roomName,
        participantIdentity: callerId,
      );

      await _callService.connect(roomToken: token.participantToken);

      // Deliberate: the caller joins the room immediately so media is ready the
      // instant the callee answers, but the mic stays OFF so nothing leaks
      // before acceptance. Do not "fix" this.
      await _media.setMicrophoneEnabled(false);

      _armMissedTimer(onTimeout);

      debugPrint('📞 [Lifecycle] outgoing call ringing → ${session.id}');
      return CallStartResult(session: session);
    } catch (e, st) {
      debugPrint('❌ [Lifecycle] start failed: $e');
      debugPrintStack(stackTrace: st);
      return CallStartResult(session: null, error: e.toString());
    } finally {
      _startInProgress = false;
    }
  }

  /// The call-connected side effects (cancel ring timer, mark as having
  /// connected, ensure mic is live). Safe to call for either role — for the
  /// callee this is largely redundant with what acceptCall() already did
  /// (no timer was ever armed on that side, _wasConnected is already true),
  /// but redundant-and-harmless, not wrong.
  Future<void> onCallConnected() async {
    _cancelMissedTimer();
    _wasConnected = true;
    await _media.setMicrophoneEnabled(true);
    debugPrint('🎉 [Lifecycle] call connected, mic live.');
  }

  // --- incoming --------------------------------------------------------------

  Future<String?> acceptCall({
    required String callId,
    required String roomName,
    required String userId,
  }) async {
    if (_acceptInProgress) {
      debugPrint('⚠️ [Lifecycle] accept ignored — already accepting.');
      return null;
    }
    _acceptInProgress = true;
    _wasConnected = false; // fixes 8(h)
    _cancelMissedTimer();
    _media.reset();

    try {
      await _signaling.updateCallState(
        callId: callId,
        state: call_model.CallState.connecting,
      );

      final token = await _tokenService.fetchDevelopmentToken(
        roomName: roomName,
        participantIdentity: userId,
      );

      await _callService.connect(roomToken: token.participantToken);
      _wasConnected = true;

      await _media.setMicrophoneEnabled(true);

      await _signaling.updateCallState(
        callId: callId,
        state: call_model.CallState.connected,
      );

      debugPrint('🎉 [Lifecycle] call connected → $callId');
      return null;
    } catch (e, st) {
      debugPrint('❌ [Lifecycle] accept failed: $e');
      debugPrintStack(stackTrace: st);

      // A connection failure is `failed`, not `ended`.
      try {
        await _signaling.updateCallState(
          callId: callId,
          state: call_model.CallState.failed,
        );
      } catch (inner) {
        debugPrint('❌ [Lifecycle] could not write failed state: $inner');
      }
      return e.toString();
    } finally {
      _acceptInProgress = false;
    }
  }

  Future<String?> rejectCall({required String callId}) async {
    _cancelMissedTimer();
    try {
      await _signaling.updateCallState(
        callId: callId,
        state: call_model.CallState.rejected,
      );
      debugPrint('❌ [Lifecycle] rejected → $callId');
      return null;
    } catch (e, st) {
      debugPrint('❌ [Lifecycle] reject failed: $e');
      debugPrintStack(stackTrace: st);
      return e.toString();
    }
  }

  // --- ending ----------------------------------------------------------------

  /// Fixes 8(d): the LiveKit disconnect happens FIRST, so a Firestore failure
  /// can never leave the room connected or the ringback playing.
  Future<void> endCall({String? callId}) async {
    _cancelMissedTimer();

    final finalState = _wasConnected
        ? call_model.CallState.ended
        : call_model.CallState.cancelled;

    try {
      await _callService.disconnect();
    } catch (e) {
      debugPrint('❌ [Lifecycle] disconnect failed: $e');
    }

    if (callId != null) {
      try {
        await _signaling.updateCallState(callId: callId, state: finalState);
        debugPrint('📡 [Lifecycle] final state → ${finalState.name}');
      } catch (e, st) {
        debugPrint('❌ [Lifecycle] final state write failed: $e');
        debugPrintStack(stackTrace: st);
      }
    }
  }

  Future<void> markMissed({required String callId}) async {
    try {
      await _signaling.markMissedCall(callId: callId);
    } catch (e) {
      debugPrint('❌ [Lifecycle] markMissed failed: $e');
    }
  }

  // --- timer -----------------------------------------------------------------

  void _armMissedTimer(VoidCallback onTimeout) {
    _cancelMissedTimer();
    _missedCallTimer = Timer(ringTimeout, onTimeout);
  }

  void _cancelMissedTimer() {
    _missedCallTimer?.cancel();
    _missedCallTimer = null;
  }

  void dispose() => _cancelMissedTimer();
}
