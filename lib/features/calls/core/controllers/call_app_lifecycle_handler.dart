import 'dart:async';

// import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:chat_app/features/calls/core/models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart'
    as call_model;
import 'package:chat_app/features/calls/core/services/callkit_bridge.dart';

/// Reacts to the app returning to the foreground: completes a native accept
/// that happened while we were away, or hands a still-ringing native call
/// over to our own UI (user tapped the notification body).
class CallAppLifecycleHandler {
  CallAppLifecycleHandler({
    required String? Function() localUid,
    required Future<bool> Function() consumeNativeAccept,
    required CallSession? Function() incomingCall,
    required call_model.CallState Function() phase,
    required bool Function() isAccepting,
    required Future<CallSession?> Function(String callId) fetchCall,
    required Future<void> Function(String callId) dismissNative,
    required Future<void> Function() takeOverRingtone,
    required void Function(CallSession session) reEmitIncoming,
  }) : _localUid = localUid,
       _consumeNativeAccept = consumeNativeAccept,
       _incomingCall = incomingCall,
       _phase = phase,
       _isAccepting = isAccepting,
       _fetchCall = fetchCall,
       _dismissNative = dismissNative,
       _takeOverRingtone = takeOverRingtone,
       _reEmitIncoming = reEmitIncoming;

  final String? Function() _localUid;
  final Future<bool> Function() _consumeNativeAccept;
  final CallSession? Function() _incomingCall;
  final call_model.CallState Function() _phase;
  final bool Function() _isAccepting;
  final Future<CallSession?> Function(String callId) _fetchCall;
  final Future<void> Function(String callId) _dismissNative;
  final Future<void> Function() _takeOverRingtone;
  final void Function(CallSession session) _reEmitIncoming;

  AppLifecycleListener? _listener;

  void start() {
    _listener ??= AppLifecycleListener(onResume: () => unawaited(_onResumed()));
  }

  Future<void> _onResumed() async {
    if (_localUid() != null && await _consumeNativeAccept()) return;

    // Give a native Accept event time to arrive first; it changes the phase.
    await Future.delayed(const Duration(milliseconds: 600));
    if (_isAccepting()) return;

    final incoming = _incomingCall();
    if (incoming == null || _phase() != call_model.CallState.ringing) return;

    // Source of truth: is it still ringing in Firestore?
    final fresh = await _fetchCall(incoming.id);
    if (fresh == null || fresh.state != call_model.CallState.ringing) return;
    if (!await CallKitBridge.isActiveNatively(incoming.id)) return;

    debugPrint('📲 [Call] resumed while native UI ringing → own UI');
    await _dismissNative(incoming.id);
    await _takeOverRingtone();
    _reEmitIncoming(incoming);
  }

  void dispose() {
    _listener?.dispose();
    _listener = null;
  }
}
