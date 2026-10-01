// features/calls/core/controllers/call_controller.dart
//
// The composition root. What's left of the 1200-line CallNotifier once
// lifecycle, media, signaling, CallKit, audio and history moved out.
//
// Note the ORDER inside build(). That ordering is a correctness constraint,
// not style — see BUG #2 in the review.
//
// CallPhase retired: state.phase is now the real signaling CallState
// (call_model.CallState) directly — see call_phase.dart.

import 'dart:async';

import 'package:chat_app/features/calls/core/services/pending_call_service.dart';
import 'package:chat_app/features/calls/core/utils/app_lifecycle_utils.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/calls/core/models/call_phase.dart'; // CallUiState
import 'package:chat_app/features/calls/core/models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/models/call_history.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart'
    as call_model;
import 'package:chat_app/features/calls/core/services/call_audio_coordinator.dart';
import 'package:chat_app/features/calls/core/services/call_history_recorder.dart';
import 'package:chat_app/features/calls/core/services/call_signaling_listner.dart';
import 'package:chat_app/features/calls/core/services/callkit_bridge.dart';
import 'package:chat_app/features/calls/core/controllers/call_lifecycle_controller.dart';
import 'package:chat_app/features/calls/core/controllers/call_media_controller.dart';
import 'package:chat_app/features/calls/core/repositories/call_history_repository.dart';
import 'package:chat_app/features/calls/core/repositories/call_signaling_repository.dart';
import 'package:chat_app/features/calls/core/services/call_audio_service.dart';
import 'package:chat_app/features/calls/core/services/call_token_service.dart';
import 'package:chat_app/features/calls/core/services/livekit_call_service.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/core/config/call_config.dart';
import 'package:chat_app/features/chat/providers/user_provider.dart';

final callProvider = NotifierProvider<CallController, CallUiState>(
  CallController.new,
);
final liveKitCallServiceProvider = Provider<LiveKitCallService>(
  (ref) => LiveKitCallService(),
);
final callSignalingRepositoryProvider = Provider<CallSignalingRepository>((
  ref,
) {
  return CallSignalingRepository(
    conversationRepository: ref.read(conversationRepositoryProvider),
  );
});
final callTokenServiceProvider = Provider<CallTokenService>(
  (ref) => const CallTokenService(),
);

class CallController extends Notifier<CallUiState> {
  late final CallLifecycleController _lifecycle;
  late final CallMediaController _media;
  late final CallSignalingListener _signaling;
  late final CallKitBridge _callKit;
  late final CallAudioCoordinator _audioCoordinator;
  late final CallHistoryRecorder _history;

  StreamSubscription<User?>? _authSub;
  //StreamSubscription<RemoteMessage>? _foregroundPushSub;
  StreamSubscription<void>? _peerGoneSub;
  StreamSubscription<void>? _reconnectingSub;
  StreamSubscription<void>? _reconnectedSub;

  String? _acceptingCallId;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  CallUiState build() {
    // ── 1. Audio FIRST. Anything below may fire a callback that touches it.
    _audioCoordinator = CallAudioCoordinator(
      audio: ref.read(callAudioServiceProvider),
      localUserId: () => _uid, // callback, not a captured value
      isNativeIncomingUiVisible: () => _callKit.isShowingNativeUi,
    );

    // ── 2. CallKit bridge. ONE subscription, started once.
    _callKit = CallKitBridge(
      onAccept: _onCallKitAccept,
      onDecline: _onCallKitDecline,
      onTimeout: _onCallKitTimeout,
      //onNativeUiVisibilityChanged: _onNativeUiVisibilityChanged, // add new
    )..start();

    // ── 2b. Foreground data push — goes through the same _callKit instance,
    // so isShowingNativeUi stays accurate. (Background isolate push handling
    // is separate: call_push_handler.dart uses CallKitBridge.showRaw, which
    // cannot see this instance at all — see the isolate note on that method.)
    // _foregroundPushSub = FirebaseMessaging.onMessage.listen((message) {
    //   if (message.data['type'] != 'incoming_call') return;
    //   debugPrint('📥 [Call] trigger: foreground FCM push → native UI');
    //   unawaited(_callKit.show(
    //       callId: message.data['callId'] ?? '',
    //       callerName: message.data['callerName'] ?? 'Unknown',
    //       callerAvatarUrl: message.data['callerAvatarUrl'],
    //       isVideoCall: message.data['callType'] == 'video',
    //     ),
    //   );
    // });

    // ── 3. Media + lifecycle.
    _media = CallMediaController(
      callService: ref.read(liveKitCallServiceProvider),
    );
    _lifecycle = CallLifecycleController(
      signaling: ref.read(callSignalingRepositoryProvider),
      tokenService: ref.read(callTokenServiceProvider),
      callService: ref.read(liveKitCallServiceProvider),
      media: _media,
      ringTimeout: const Duration(seconds: 30),
    );
    _history = CallHistoryRecorder(
      repository: ref.read(callHistoryRepositoryProvider),
      sendSystemMessage: (conversationId, message) => ref
          .read(conversationMessageRepositoryProvider(conversationId))
          .sendMessage(message),
    );

    // ── 4. Signaling. One listener object, one terminal handler.
    _signaling = CallSignalingListener(
      repository: ref.read(callSignalingRepositoryProvider),
      onIncoming: _onIncomingCall,
      onIncomingCleared: _onIncomingCleared,
      onTransition: _onTransition,
      onConnected: _onRemoteConnected,
      onTerminal: _onTerminal,
    );

    // 🛡️ d) APP LIFECYCLE WATCHDOG INTEGRATION
    final lifecycle = AppLifecycleListener(
      onResume: () => unawaited(_onAppResumed()),
    );
    ref.onDispose(lifecycle.dispose);

    // ── 5. Auth last.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _signaling.watchInbox(userId: user.uid);
      } else {
        _signaling.stopInbox();
        _signaling.stopActive();
        _peerGoneSub?.cancel();
        _reconnectingSub?.cancel();
        _reconnectedSub?.cancel();
        unawaited(_consumePendingAccept());
        unawaited(_audioCoordinator.reset());
        unawaited(_callKit.dismissAll());
        unawaited(ref.read(liveKitCallServiceProvider).disconnect());
        state = CallUiState.idle;
      }
    });

    ref.onDispose(() {
      _authSub?.cancel();
      //_foregroundPushSub?.cancel();
      _peerGoneSub?.cancel();
      _reconnectingSub?.cancel();
      _reconnectedSub?.cancel();
      _lifecycle.dispose();
      unawaited(_signaling.dispose());
      unawaited(_callKit.dispose());
      unawaited(_audioCoordinator.dispose());
    });

    return CallUiState.idle;
  }

  // =======================================================================
  // 🔕 NATIVE UI VISIBILITY SYNC HANDLER (RESOLVES COMPILER ERROR)
  // =======================================================================
  // ✅ REQUIREMENT MET: Defined the missing callback inside the new CallController scope!
  // void _onNativeUiVisibilityChanged(bool isVisible) {
  //   debugPrint(
  //     '🔔 [CallKit] Native system UI visibility state flipped '
  //     '➔ isVisible: $isVisible',
  //   );

  //   state = state.copyWith(nativeUiVisible: isVisible);

  //   final session = state.incomingCall;

  //   if (session != null) {
  //     unawaited(
  //       _audioCoordinator.onSession(session, speakerOn: state.speakerOn),
  //     );
  //   }
  // }

  void _subscribeToRoomEvents() {
    final callService = ref.read(liveKitCallServiceProvider);

    _peerGoneSub?.cancel();
    _peerGoneSub = callService.onPeerGone.listen((_) {
      debugPrint(
        '👻 [Call] onPeerGone fired — activeCallId=${_signaling.activeCallId}',
      );
      if (_signaling.activeCallId != null) unawaited(endCurrentCall());
    });

    _reconnectingSub?.cancel();
    _reconnectingSub = callService.onRoomReconnecting.listen((_) {
      final callId = _signaling.activeCallId;
      debugPrint('🔄 [Call] onRoomReconnecting fired — activeCallId=$callId');
      if (callId == null) return;
      unawaited(
        ref
            .read(callSignalingRepositoryProvider)
            .updateCallState(
              callId: callId,
              state: call_model.CallState.reconnecting,
            ),
      );
    });

    _reconnectedSub?.cancel();
    _reconnectedSub = callService.onRoomReconnected.listen((_) {
      final callId = _signaling.activeCallId;
      debugPrint('✅ [Call] onRoomReconnected fired — activeCallId=$callId');
      if (callId == null) return;
      unawaited(
        ref
            .read(callSignalingRepositoryProvider)
            .updateCallState(
              callId: callId,
              state: call_model.CallState.connected,
            ),
      );
    });
  }

  // --- public API ------------------------------------------------------------

  Future<void> startVoiceCall({required String calleeId}) async {
    final uid = _uid;
    if (uid == null) return _fail('No authenticated user.');
    if (state.phase.isBusy) {
      debugPrint('⚠️ [Call] start ignored — ${state.phase.name}');
      return;
    }
    state = state.copyWith(
      phase: call_model.CallState.connecting,
      clearError: true,
    );
    String? callerName;
    try {
      final myProfile = await ref.read(currentUserProvider.future);
      callerName = myProfile?.username;
    } catch (e) {
      debugPrint('⚠️ [Call] Failed to resolve own display name: $e');
    }
    final result = await _lifecycle.startCall(
      callerId: uid,
      calleeId: calleeId,
      type: CallType.voice,
      callerName: callerName,
      onTimeout: () => unawaited(_onRingTimeout()),
      onSessionCreated: (session) => _signaling.watchActive(callId: session.id),
    );
    if (!result.ok) return _fail(result.error ?? 'Could not start the call.');
    _subscribeToRoomEvents();
    state = state.copyWith(
      phase: call_model.CallState.ringing,
      activeCall: result.session,
      micEnabled:
          false, // _lifecycle.startCall() already turned the mic off — keep state in sync
    );
  }

  Future<void> acceptCall({
    required String callId,
    required String roomName,
  }) async {
    final uid = _uid;
    if (uid == null) return _fail('No authenticated user.');
    if (_acceptingCallId == callId) return;
    _acceptingCallId = callId;
    await _callKit.dismiss(callId);
    _signaling.watchActive(callId: callId);
    state = state.copyWith(
      phase: call_model.CallState.connecting,
      clearIncomingCall: true,
    );
    final error = await _lifecycle.acceptCall(
      callId: callId,
      roomName: roomName,
      userId: uid,
    );
    if (error != null) {
      // Don't rely solely on _onTerminal's self-healing re-arm — if the
      // failure write to Firestore also fails, nothing else re-arms this.
      _acceptingCallId = null;
      final u = _uid;
      if (u != null) _signaling.watchInbox(userId: u);
      return _fail(error);
    }
    _subscribeToRoomEvents();
    state = state.copyWith(
      phase: call_model.CallState.connected,
      micEnabled: true,
    );
  }

  // Pending accept (killed-state Accept):
  Future<void> _consumePendingAccept() async {
    final callId = await PendingCallService.instance.consumeAcceptedCall();
    if (callId == null) return;
    final session = await ref
        .read(callSignalingRepositoryProvider)
        .fetchCallOnce(callId: callId);
    if (session == null ||
        session.calleeId != _uid ||
        session.state.isTerminal) {
      await _callKit.dismiss(callId);
      return;
    }
    await acceptCall(callId: session.id, roomName: session.roomName);
  }

  // Resume handler (notification-body tap):
  Future<void> _onAppResumed() async {
    if (_uid != null) unawaited(_consumePendingAccept());

    // Give a native Accept event time to arrive first; it changes the phase.
    await Future.delayed(const Duration(milliseconds: 600));

    final incoming = state.incomingCall;
    if (incoming == null || state.phase != call_model.CallState.ringing) return;
    if (!await CallKitBridge.isActiveNatively(incoming.id)) return;

    debugPrint('📲 [Call] resumed while native UI ringing → own UI');
    await _callKit.dismiss(incoming.id);
    await _audioCoordinator.takeOverRingtone();
    // Re-emit so GlobalIncomingCallListener re-evaluates and pushes the card.
    state = state.copyWith(incomingCall: incoming);
  }

  Future<void> rejectCall({required String callId}) async {
    await _callKit.dismiss(callId);
    final error = await _lifecycle.rejectCall(callId: callId);
    state = state.copyWith(
      phase: error != null
          ? call_model.CallState.failed
          : call_model.CallState.ended,
      errorMessage: error,
      clearIncomingCall: true,
    );
  }

  Future<void> endCurrentCall() async {
    final callId = _signaling.activeCallId;
    // Audio first: if the Firestore write throws, the ringback still stops.
    await _audioCoordinator.reset();
    await _lifecycle.endCall(callId: callId);
    if (callId != null) await _callKit.dismiss(callId);
    state = state.copyWith(
      phase: call_model.CallState.ended,
      clearActiveCall: true,
    );
  }

  Future<void> toggleMic() async {
    final s = await _media.toggleMic();
    state = state.copyWith(micEnabled: s.micEnabled);
  }

  Future<void> toggleSpeaker() async {
    final s = await _media.toggleSpeaker();
    state = state.copyWith(speakerOn: s.speakerOn);
  }

  // Explicit setters — distinct from toggleMic/toggleSpeaker above. Needed
  // by LiveKitTestScreen's separate Enable/Disable buttons, which test
  // idempotency (e.g. "enable when already enabled") rather than a toggle.
  Future<void> setMicrophoneEnabled(bool enabled) async {
    final s = await _media.setMicrophoneEnabled(enabled);
    state = state.copyWith(micEnabled: s.micEnabled);
  }

  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    final s = await _media.setSpeakerphoneEnabled(enabled);
    state = state.copyWith(speakerOn: s.speakerOn);
  }

  Future<void> setCameraEnabled(bool enabled) async {
    final s = await _media.setCameraEnabled(enabled);
    state = state.copyWith(cameraEnabled: s.cameraEnabled);
  }

  /// Plain LiveKit teardown for the ad-hoc test room — NOT the same as
  /// endCurrentCall(), which writes a real CallSession's terminal state.
  /// There is no CallSession here, so there's nothing to write.
  Future<void> disconnect() async {
    await ref.read(liveKitCallServiceProvider).disconnect();
    state = state.copyWith(phase: call_model.CallState.ended);
  }

  /// Dev-only foundation test — connects to a fixed test room with no real
  /// CallSession behind it. Kept separate from the real call flow entirely.
  Future<void> connectTestRoom() async {
    if (!kDebugMode) {
      state = state.copyWith(
        phase: call_model.CallState.failed,
        errorMessage: 'Test room is unavailable outside debug builds.',
      );
      return;
    }
    final uid = _uid;
    if (uid == null) {
      state = state.copyWith(
        phase: call_model.CallState.failed,
        errorMessage: 'No authenticated Firebase user.',
      );
      return;
    }
    state = state.copyWith(
      phase: call_model.CallState.connecting,
      clearError: true,
    );
    try {
      final tokenResponse = await ref
          .read(callTokenServiceProvider)
          .fetchDevelopmentToken(
            roomName: CallConfig.testRoomName,
            participantIdentity: uid,
          );
      await ref
          .read(liveKitCallServiceProvider)
          .connect(roomToken: tokenResponse.participantToken);
      state = state.copyWith(phase: call_model.CallState.connected);
      debugPrint('✅ [Call] LiveKit test room connected.');
    } catch (e, stackTrace) {
      debugPrint('❌ [Call] LiveKit test room connection failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = state.copyWith(
        phase: call_model.CallState.failed,
        errorMessage: e.toString(),
      );
    }
  }
  // --- signaling callbacks ---------------------------------------------------

  void _onIncomingCall(CallSession session) {
    if (session.type != CallType.voice) return;

    // Same call already being handled (the snapshot re-fired after our own write).
    if (state.incomingCall?.id == session.id) return;

    final age = DateTime.now().difference(session.createdAt.toDate());
    if (age > const Duration(seconds: 60)) {
      debugPrint(
        '🕰️ [Call] ignoring stale ringing call → ${session.id} (${age.inSeconds}s old)',
      );
      unawaited(_lifecycle.markMissed(callId: session.id));
      return;
    }
    // Tell the caller this device received the call (one write per call).
    if (session.calleeRingingAt == null) {
      unawaited(
        ref
            .read(callSignalingRepositoryProvider)
            .markCalleeRinging(callId: session.id),
      );
    }
    state = state.copyWith(
      incomingCall: session,
      phase: call_model.CallState.ringing,
    );

    if (isAppInForeground) {
      debugPrint('📥 [Call] Firestore inbox → own UI (foreground)');
      // No _callKit.show(): isShowingNativeUi stays false, so the audio
      // coordinator plays OUR ringtone.
    } else {
      debugPrint('📥 [Call] Firestore inbox → native UI (background)');
      unawaited(
        _callKit.show(
          callId: session.id,
          callerName: session.callerName ?? 'Unknown',
          isVideoCall: false,
        ),
      );
    }
    unawaited(_audioCoordinator.onSession(session, speakerOn: state.speakerOn));
  }

  void _onIncomingCleared(String callId) {
    unawaited(_callKit.dismiss(callId)); // fixes BUG #4
    unawaited(_audioCoordinator.reset());
    state = CallUiState.idle;
  }

  void _onTransition(CallSession session) {
    debugPrint(
      '📡 [Call] transition: '
      'callId=${session.id}, '
      'Firestore=${session.state.name}, '
      'UI=${state.phase.name}, '
      'callerId=${session.callerId}, '
      'localUid=$_uid',
    );
    unawaited(_audioCoordinator.onSession(session, speakerOn: state.speakerOn));
    state = state.copyWith(activeCall: session, phase: session.state);
  }

  Future<void> _onRemoteConnected(CallSession session) async {
    await _lifecycle.onCallConnected();
    state = state.copyWith(
      phase: call_model.CallState.connected,
      activeCall: session,
      micEnabled: true,
      clearIncomingCall: true,
    );
  }

  Future<void> _onTerminal(
    CallSession session,
    call_model.CallState reason,
  ) async {
    _acceptingCallId = null;
    unawaited(
      _history.record(
        session: session,
        status: CallHistory.fromCallState(reason),
        localUserId: _uid ?? '',
      ),
    );
    await _callKit.dismiss(session.id);
    _peerGoneSub?.cancel();
    _reconnectingSub?.cancel();
    _reconnectedSub?.cancel();
    await _lifecycle.endCall(); // disconnect only; state already terminal
    _signaling.stopActive();
    state = CallUiState(
      phase:
          reason, // reason is already the specific terminal value (ended/rejected/cancelled/failed/missed)
    );
    final uid = _uid;
    if (uid != null) _signaling.watchInbox(userId: uid);
  }

  Future<void> _onRingTimeout() async {
    final callId = _signaling.activeCallId;
    if (callId == null || state.phase != call_model.CallState.ringing) return;
    debugPrint('⌛ [Call] ring timeout → missed');
    await _lifecycle.markMissed(callId: callId);
    // The signaling listener will pick up `missed` and run _onTerminal.
  }

  // --- CallKit callbacks -----------------------------------------------------

  Future<void> _onCallKitAccept(String callId) async {
    final repo = ref.read(callSignalingRepositoryProvider);
    final session = await repo.fetchCallOnce(callId: callId);
    if (session == null || session.calleeId != _uid) {
      debugPrint(
        '⚠️ [Call] CallKit accept rejected — invalid or foreign call → $callId',
      );
      await _callKit.dismiss(callId);
      return;
    }
    await acceptCall(callId: session.id, roomName: session.roomName);
  }

  Future<void> _onCallKitDecline(String callId) => rejectCall(callId: callId);

  Future<void> _onCallKitTimeout(String callId) async {
    await _lifecycle.markMissed(callId: callId);
  }

  // --- helpers ---------------------------------------------------------------

  void _fail(String message) {
    debugPrint('❌ [Call] $message');
    state = state.copyWith(
      phase: call_model.CallState.failed,
      errorMessage: message,
    );
  }
}
