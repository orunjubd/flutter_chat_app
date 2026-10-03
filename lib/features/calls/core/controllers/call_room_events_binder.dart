import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart'
    as call_model;
import 'package:chat_app/features/calls/core/repositories/call_signaling_repository.dart';
import 'package:chat_app/features/calls/core/services/call_service.dart';

/// Bridges room-level events (peer gone, reconnecting, reconnected) to the
/// signaling layer. Stateless about the call itself: the controller still
/// owns UI state; this only listens and reports.
class CallRoomEventsBinder {
  CallRoomEventsBinder({
    required CallService callService,
    required CallSignalingRepository repository,
    required String? Function() activeCallId,
    required Future<void> Function() onPeerGone,
  }) : _callService = callService,
       _repository = repository,
       _activeCallId = activeCallId,
       _onPeerGone = onPeerGone;

  final CallService _callService;
  final CallSignalingRepository _repository;
  final String? Function() _activeCallId; // callback: id changes per call
  final Future<void> Function() _onPeerGone;

  StreamSubscription<void>? _peerGoneSub;
  StreamSubscription<void>? _reconnectingSub;
  StreamSubscription<void>? _reconnectedSub;

  /// Safe to call repeatedly: previous subscriptions are replaced.
  void bind() {
    unbind();

    _peerGoneSub = _callService.onPeerGone.listen((_) {
      debugPrint(
        '👻 [Call] onPeerGone fired — activeCallId=${_activeCallId()}',
      );
      if (_activeCallId() != null) unawaited(_onPeerGone());
    });

    _reconnectingSub = _callService.onRoomReconnecting.listen((_) {
      final callId = _activeCallId();
      debugPrint('🔄 [Call] onRoomReconnecting fired — activeCallId=$callId');
      if (callId == null) return;
      unawaited(
        _repository.updateCallState(
          callId: callId,
          state: call_model.CallState.reconnecting,
        ),
      );
    });

    _reconnectedSub = _callService.onRoomReconnected.listen((_) {
      final callId = _activeCallId();
      debugPrint('✅ [Call] onRoomReconnected fired — activeCallId=$callId');
      if (callId == null) return;
      unawaited(
        _repository.updateCallState(
          callId: callId,
          state: call_model.CallState.connected,
        ),
      );
    });
  }

  void unbind() {
    _peerGoneSub?.cancel();
    _reconnectingSub?.cancel();
    _reconnectedSub?.cancel();
    _peerGoneSub = _reconnectingSub = _reconnectedSub = null;
  }

  void dispose() => unbind();
}
