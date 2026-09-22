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

//import 'package:chat_app/features/calls/data/models/call_state.dart'; // CallState, CallEndReason
import 'package:chat_app/features/calls/data/models/call_session.dart';
import 'package:chat_app/features/calls/data/models/call_state.dart'
    as call_model;
import 'package:flutter/material.dart';
import 'call_audio_service.dart';

class CallAudioCoordinator {
  CallAudioCoordinator({
    required CallAudioService audio,
    required this.localUserId,
    required this.isNativeIncomingUiVisible,
  }) : _audio = audio;

  final CallAudioService _audio;

  /// A callback, NOT a captured value. The provider is built before auth
  /// resolves, so capturing `currentUser?.uid ?? ''` at construction pins it
  /// to empty forever and the caller ends up looking like an incoming call.
  final String? Function() localUserId;

  /// True while CallKit / ConnectionService is showing the native incoming
  /// screen — i.e. the OS owns the ringtone right now. Must reflect reality
  /// or both ringtones play at once; see IncomingCallService wiring below.
  final bool Function() isNativeIncomingUiVisible;

  call_model.CallState? _lastState;
  String? _lastCallId;
  bool _active = false;

  /// Drive audio from the session stream. Call from your provider's listener.
  Future<void> onSession(CallSession session, {required bool speakerOn}) async {
    // A new call id restarts the machine — otherwise call #2 in a session is
    // compared against call #1's last state and the ringtone never starts.
    if (session.id != _lastCallId) {
      _lastCallId = session.id;
      _lastState = null;
    }

    final current = session.state;
    if (current == _lastState) return;

    final previous = _lastState;
    _lastState = current;
    _active = true;

    final uid = localUserId();
    final isCaller = uid != null && session.callerId == uid;

    switch (current) {
      case call_model.CallState.idle:
        break;

      case call_model.CallState.dialing:
      case call_model.CallState.ringing:
        if (isCaller) {
          await _audio.startRingback(speakerOn: speakerOn);
        } else {
          await _audio.startRingtone(handledByOs: isNativeIncomingUiVisible());
        }

      case call_model.CallState.connecting:
        // Answered. Kill the ring immediately — before the room connects, not
        // after, or the ringtone overlaps the first second of real audio.
        await _audio.stopLoop();

      case call_model.CallState.connected:
        await _audio.stopLoop();
        // Skip the chime if we're just resuming from a network hiccup — the
        // user already heard "connected" once and doesn't need it again.
        if (previous != call_model.CallState.reconnecting) {
          await _audio.playTone(CallTone.connected);
        }

      case call_model.CallState.reconnecting:
        await _audio.playTone(CallTone.reconnecting);

      case call_model.CallState.ended:
      case call_model.CallState.rejected:
      case call_model.CallState.cancelled:
      case call_model.CallState.failed:
      case call_model.CallState.missed:
        await _audio.stopLoop();
        await _audio.playEndToneAndWait(
          _endTone(current, isCaller: isCaller, reason: session.endReason),
        );
        await _audio.stopAll();
        _active = false;
    }

    debugPrint(
      '🔈 [Audio] ${previous?.name ?? "-"} → ${current.name}'
      '${isCaller ? " (caller)" : " (callee)"}',
    );
  }

  CallTone _endTone(
    call_model.CallState state, {
    required bool isCaller,
    call_model.CallEndReason? reason,
  }) {
    if (reason != null) {
      switch (reason) {
        case call_model.CallEndReason.rejected:
          return isCaller ? CallTone.declined : CallTone.ended;
        case call_model.CallEndReason.busy:
          return CallTone.busy;
        case call_model.CallEndReason.hangup:
        case call_model.CallEndReason.cancelled:
        case call_model.CallEndReason.missed:
        case call_model.CallEndReason.failed:
        case call_model.CallEndReason.networkLost:
        case call_model.CallEndReason.answeredElsewhere:
          return CallTone.ended;
      }
    }

    // Fallback for sessions that don't carry an endReason yet.
    switch (state) {
      case call_model.CallState.rejected:
        return isCaller ? CallTone.declined : CallTone.ended;
      case call_model.CallState.failed:
        return CallTone.busy;
      case call_model.CallState.cancelled:
      case call_model.CallState.missed:
      case call_model.CallState.ended:
      default:
        return CallTone.ended;
    }
  }

  // ============================================================================
  /// Hard stop with no end tone. For logout, auth loss, or any path where
  /// the call simply ceased to be ours.
  Future<void> reset() async {
    _lastState = null;
    _lastCallId = null;
    if (_active) {
      _active = false;
      await _audio.stopAll();
    }
  }

  // ============================================================================
  /// Safety net for paths that never produced a terminal transition — a thrown
  /// exception, a disposed widget, a user backgrounding the app mid-ring.
  Future<void> dispose() async {
    if (_active) await _audio.stopAll();
    _active = false;
  }
}
