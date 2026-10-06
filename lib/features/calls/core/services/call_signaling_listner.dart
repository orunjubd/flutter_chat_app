// features/calls/core/services/call_signaling_listener.dart
//
// FIXES BUG #6.
//
// Replaces _incomingCallSubscription + _outgoingCallSubscription +
// _activeCallSubscription. The terminal-state block that was copy-pasted in
// _listenForOutgoingCall and _listenForActiveCall now exists ONCE.
//
// Two subscriptions, with clear and non-overlapping jobs:
//   inbox   — only alive when there is NO active call. Detects new incoming.
//   active  — alive for exactly one call id. Reports every transition.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart'
    as call_model;
import '../repositories/call_signaling_repository.dart';

typedef SessionCallback = void Function(CallSession session);
typedef TerminalCallback =
    void Function(CallSession session, call_model.CallState reason);

const terminalCallStates = <call_model.CallState>{
  call_model.CallState.ended,
  call_model.CallState.missed,
  call_model.CallState.rejected,
  call_model.CallState.cancelled,
  call_model.CallState.failed,
};

class CallSignalingListener {
  CallSignalingListener({
    required CallSignalingRepository repository,
    required this.onIncoming,
    required this.onIncomingCleared,
    required this.onTransition,
    required this.onConnected,
    required this.onTerminal,
  }) : _repository = repository;

  final CallSignalingRepository _repository;

  /// A new incoming call appeared while idle.
  final SessionCallback onIncoming;

  /// The incoming call vanished (cancelled remotely) before we acted.
  //  final VoidCallback onIncomingCleared;
  final void Function(String callId) onIncomingCleared; // was: VoidCallback

  /// Any state change on the active call. Drives audio.
  final SessionCallback onTransition;

  /// The active call reached `connected`. Fired at most once per call.
  final SessionCallback onConnected;

  /// The active call reached a terminal state. Fired at most once per call.
  final TerminalCallback onTerminal;

  StreamSubscription<CallSession?>? _inboxSub;
  StreamSubscription<CallSession?>? _activeSub;

  String? _activeCallId;
  String? _lastIncomingCallId;
  bool _connectedFired = false;
  bool _terminalFired = false;

  String? get activeCallId => _activeCallId;

  // --- inbox -----------------------------------------------------------------

  void watchInbox({required String userId}) {
    _inboxSub?.cancel();
    debugPrint('📡 [Signaling] watching inbox for $userId');

    _inboxSub = _repository
        .watchIncomingCall(calleeId: userId)
        .listen(
          (session) {
            if (session == null) {
              final id = _lastIncomingCallId;
              _lastIncomingCallId = null;
              if (id != null) onIncomingCleared(id);
              return;
            }
            // Don't surface a call we're already handling.
            if (session.id == _activeCallId) return;
            _lastIncomingCallId = session.id;
            onIncoming(session);
          },
          onError: (Object e, StackTrace st) {
            debugPrint('❌ [Signaling] inbox error: $e');
            debugPrintStack(stackTrace: st);
          },
        );
  }

  void stopInbox() {
    _inboxSub?.cancel();
    _inboxSub = null;
  }

  // --- active call -----------------------------------------------------------

  /// Watch one call from either side. Caller and callee use the SAME path —
  /// that's what removes the duplication.
  void watchActive({required String callId}) {
    if (_activeCallId == callId && _activeSub != null) return;

    _activeSub?.cancel();
    _activeCallId = callId;
    _connectedFired = false;
    _terminalFired = false;

    // While a call is active the inbox is noise, and worse, it can clobber
    // state. Your old code cancelled it in three different places.
    // stopInbox();

    debugPrint('📡 [Signaling] watching active call $callId');

    _activeSub = _repository
        .watchCall(callId: callId)
        .listen(
          (session) {
            if (session == null) return;

            // Ignore a queued event from a subscription replaced by another call.
            if (_activeCallId != callId || session.id != callId) {
              debugPrint(
                '⚠️ [Signaling] stale active event ignored: '
                'watched=$callId, received=${session.id}, active=$_activeCallId',
              );
              return;
            }

            debugPrint(
              '📡 [Signaling] active snapshot: '
              'callId=$callId, state=${session.state.name}',
            );

            onTransition(session);

            if (session.state == call_model.CallState.connected &&
                !_connectedFired) {
              _connectedFired = true;
              onConnected(session);
              return;
            }

            if (terminalCallStates.contains(session.state) && !_terminalFired) {
              _terminalFired = true;
              onTerminal(session, session.state);
            }
          },
          onError: (Object e, StackTrace st) {
            debugPrint('❌ [Signaling] active call error: $e');
            debugPrintStack(stackTrace: st);
          },
        );
  }

  void stopActive() {
    _activeSub?.cancel();
    _activeSub = null;
    _activeCallId = null;
    _connectedFired = false;
    _terminalFired = false;
  }

  Future<void> dispose() async {
    await _inboxSub?.cancel();
    await _activeSub?.cancel();
    _inboxSub = null;
    _activeSub = null;
    _activeCallId = null;
  }
}
