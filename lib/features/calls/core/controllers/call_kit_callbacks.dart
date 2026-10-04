import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:flutter/foundation.dart';
import 'package:chat_app/features/calls/core/models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/repositories/call_signaling_repository.dart';
import 'package:chat_app/features/calls/core/services/callkit_bridge.dart';
import 'package:chat_app/features/calls/core/services/pending_call_service.dart';

/// Entry points for actions taken on the native incoming-call UI
/// (accept / decline / timeout), including accepts that happened while the
/// app was killed. Owns no call state: the controller still decides what
/// the UI shows.
class CallKitCallbacks {
  CallKitCallbacks({
    required CallSignalingRepository repository,
    required String? Function() localUid,
    required Future<void> Function(String callId) dismissNative,
    required Future<void> Function({
      required String callId,
      required String roomName,
      CallType type,
      CallSession? session,
    })
    acceptCall,
    required Future<void> Function({required String callId}) rejectCall,
    required Future<void> Function({required String callId}) markMissed,
  }) : _repository = repository,
       _localUid = localUid,
       _dismissNative = dismissNative,
       _acceptCall = acceptCall,
       _rejectCall = rejectCall,
       _markMissed = markMissed;

  final CallSignalingRepository _repository;
  final String? Function() _localUid;
  final Future<void> Function(String callId) _dismissNative;
  final Future<void> Function({
    required String callId,
    required String roomName,
    CallType type,
    CallSession? session,
  })
  _acceptCall;
  final Future<void> Function({required String callId}) _rejectCall;
  final Future<void> Function({required String callId}) _markMissed;

  // --- wired into CallKitBridge ---------------------------------------------

  Future<void> onAccept(String callId) async {
    await acceptById(callId);
  }

  Future<void> onDecline(String callId) => _rejectCall(callId: callId);

  Future<void> onTimeout(String callId) => _markMissed(callId: callId);

  // --- shared accept path ----------------------------------------------------

  /// Validates the call, then accepts it. Returns false if it was invalid
  /// (missing, not ours, or already finished); the native UI is dismissed.
  Future<bool> acceptById(String callId) async {
    final session = await _repository.fetchCallOnce(callId: callId);
    if (session == null ||
        session.calleeId != _localUid() ||
        session.state.isTerminal) {
      debugPrint(
        '⚠️ [Call] native accept rejected — invalid/foreign/finished → $callId',
      );
      await _dismissNative(callId);
      return false;
    }
    await _acceptCall(
      callId: session.id,
      roomName: session.roomName,
      type: session.type,
      session: session,
    );
    return true;
  }

  /// Killed-state accepts: the accept event fired before our listener existed,
  /// so recover it from the persisted id or from the plugin's accepted flag.
  Future<bool> consumeNativeAccept() async {
    final pending = await PendingCallService.instance.consumeAcceptedCall();
    if (pending != null && await acceptById(pending)) return true;

    final nativeId = await CallKitBridge.acceptedNativeCallId();
    if (nativeId != null) return acceptById(nativeId);
    return false;
  }
}
