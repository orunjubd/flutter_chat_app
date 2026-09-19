// features/calls/core/services/call_audio_coordinator.dart
//
// Why this exists: the reason the ringtone got forgotten is that ringing was
// treated as a UI concern. It isn't — it's a function of call state.
//
//   state transition  ->  sound
//
// Bind this once per call and you cannot forget it, and more importantly you
// cannot LEAVE IT PLAYING, because every terminal transition runs stopAll().

import 'dart:async';

import 'package:chat_app/features/calls/data/models/call_state.dart'; // CallState, CallEndReason
import 'package:chat_app/features/calls/data/models/call_session.dart';
import 'call_audio_service.dart';

class CallAudioCoordinator {
  CallAudioCoordinator({
    required CallAudioService audio,
    required this.localUserId,
    required this.isNativeIncomingUiVisible,
  }) : _audio = audio;

  final CallAudioService _audio;

  /// Read live rather than captured once — the signed-in user can change
  /// while this coordinator (owned by a long-lived provider) is alive.
  final String localUserId;

  /// True when CallKit / ConnectionService is showing the native incoming
  /// screen — i.e. the OS owns the ringtone right now.
  final bool Function() isNativeIncomingUiVisible;

  CallState? _lastState;
  bool _bound = false;

  /// Drive audio from the session stream. Call from your controller's listener.
  Future<void> onSession(CallSession session, {required bool speakerOn}) async {
    final state = session.state;
    if (state == _lastState) return;

    final previous = _lastState;
    _lastState = state;
    _bound = true;

    final isCaller = session.callerId == localUserId;

    switch (state) {
      case CallState.idle:
        // Nothing to do — pre-dial / pre-ring state.
        break;

      case CallState.dialing:
      case CallState.ringing:
        if (isCaller) {
          await _audio.startRingback(speakerOn: speakerOn);
        } else {
          await _audio.startRingtone(handledByOs: isNativeIncomingUiVisible());
        }
        break;

      case CallState.connecting:
        // Answered. Kill the ring immediately — before the room connects, not
        // after, or the ringtone overlaps the first second of real audio.
        await _audio.stopLoop();
        break;

      case CallState.connected:
        await _audio.stopLoop();
        // Skip the chime if we're just resuming from a network hiccup — the
        // user already heard "connected" once and doesn't need it again.
        if (previous != CallState.reconnecting) {
          await _audio.playTone(CallTone.connected);
        }
        break;

      case CallState.reconnecting:
        await _audio.playTone(CallTone.reconnecting);
        break;

      case CallState.ended:
      case CallState.rejected:
      case CallState.cancelled:
      case CallState.failed:
      case CallState.missed:
        await _audio.stopLoop();
        await _audio.playEndToneAndWait(
          _endTone(state, isCaller: isCaller, reason: session.endReason),
        );
        await _audio.stopAll();
        break;
    }
  }

  CallTone _endTone(
    CallState state, {
    required bool isCaller,
    CallEndReason? reason,
  }) {
    // Prefer the real reason when the session carries one — it's strictly
    // more accurate than guessing from CallState alone (e.g. `failed` used
    // to always mean "busy"; now busy vs. networkLost are distinguishable).
    if (reason != null) {
      switch (state) {
        case CallState.rejected:
          // Only the caller should hear the decline tone; the callee pressed
          // the button and doesn't need to be told.
          return isCaller ? CallTone.declined : CallTone.ended;

        case CallState.failed:
          // Assumption: `failed` covers what used to be CallEndReason.busy
          // (couldn't connect / signalling failure). Adjust if your backend
          // distinguishes "busy" from other failures some other way.
          return CallTone.busy;

        case CallState.cancelled:
          // Caller hung up before the callee answered. No dedicated "missed"
          // tone exists yet — using the plain ended tone for both sides.
          return CallTone.ended;

        case CallState.missed:
          // Callee never answered. Same note as above — plug in a dedicated
          // tone here if/when you add one.
          return CallTone.ended;

        case CallState.ended:
        default:
          return CallTone.ended;
      }
    }
    // Fallback for sessions that don't carry an endReason yet.
    switch (state) {
      case CallState.rejected:
        // Only the caller should hear the decline tone; the callee pressed
        // the button and doesn't need to be told.
        return isCaller ? CallTone.declined : CallTone.ended;

      case CallState.failed:
        // Assumption: `failed` covers what used to be CallEndReason.busy
        // (couldn't connect / signalling failure). Adjust if your backend
        // distinguishes "busy" from other failures some other way.
        return CallTone.busy;

      case CallState.cancelled:
        // Caller hung up before the callee answered. No dedicated "missed"
        // tone exists yet — using the plain ended tone for both sides.
        return CallTone.ended;

      case CallState.missed:
        // Callee never answered. Same note as above — plug in a dedicated
        // tone here if/when you add one.
        return CallTone.ended;

      case CallState.ended:
      default:
        return CallTone.ended;
    }
  }

  // ============================================================================
  /// Call when a call session vanishes without ever producing a terminal
  /// Firestore write the coordinator would otherwise see — e.g. an incoming
  /// call query stops matching the moment it's rejected, rather than
  /// emitting one last `rejected` snapshot first. Silently stops audio and
  /// forgets the last state, so the next call starts clean even if its
  /// first state happens to equal this one's last state.
  Future<void> reset() async {
    _lastState = null;
    _bound = false;
    await _audio.stopAll();
  }

  // ============================================================================
  /// Safety net for paths that never produced a terminal transition — a thrown
  /// exception, a disposed widget, a user backgrounding the app mid-ring.
  Future<void> dispose() async {
    if (_bound) await _audio.stopAll();
  }
}
