import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming_maintained/entities/call_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';

import 'package:chat_app/features/calls/data/models/call_history.dart';
import 'package:chat_app/features/calls/data/models/call_session.dart';
import 'package:chat_app/features/calls/data/repositories/call_history_repository.dart';
import 'package:chat_app/features/chat/data/models/message.dart';
import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
import 'package:chat_app/features/chat/providers/conversation_provider.dart';
import 'package:chat_app/core/config/call_config.dart';
import 'package:chat_app/features/calls/services/call_token_service.dart';
import 'package:chat_app/features/calls/services/livekit_call_service.dart';
import 'package:chat_app/features/calls/data/repositories/call_signaling_repository.dart';
import 'package:chat_app/features/calls/data/models/call_type.dart';
import 'package:chat_app/features/calls/data/models/call_state.dart'
    as call_model;
import 'package:chat_app/features/calls/services/incoming_call_service.dart';
import 'package:chat_app/features/calls/services/pending_call_service.dart';

enum CallConnectionStatus {
  idle,
  ringing,
  connecting,
  connected,
  failed,
  ended,
}

class CallState {
  const CallState({
    this.status = CallConnectionStatus.idle,
    this.errorMessage,
    this.incomingCall,
  });

  final CallConnectionStatus status;
  final String? errorMessage;
  final CallSession? incomingCall;

  CallState copyWith({
    CallConnectionStatus? status,
    String? errorMessage,
    CallSession? incomingCall,
    bool clearIncomingCall = false,
  }) {
    return CallState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      incomingCall: clearIncomingCall
          ? null
          : incomingCall ?? this.incomingCall,
    );
  }
}

final callTokenServiceProvider = Provider<CallTokenService>(
  (ref) => const CallTokenService(),
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

final callProvider = NotifierProvider<CallNotifier, CallState>(
  CallNotifier.new,
);

class CallNotifier extends Notifier<CallState> {
  //static const Duration _incomingCallTimeout = Duration(seconds: 30);
  Timer? _missedCallTimer;
  final Set<String> _historyCreatedCallIds = <String>{};

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<CallEvent?>? _callKitEventSubscription;

  late final CallTokenService _tokenService;
  late final LiveKitCallService _callService;
  late final CallSignalingRepository _signalingRepository;
  late final CallHistoryRepository _historyRepository;

  bool _startVoiceCallInProgress = false;
  bool _acceptVoiceCallInProgress = false;
  bool _callWasConnected = false;

  CallHistoryStatus _historyStatusFor(call_model.CallState state) {
    return CallHistory.fromCallState(state);
  }

  @override
  CallState build() {
    _tokenService = ref.read(callTokenServiceProvider);
    _callService = ref.read(liveKitCallServiceProvider);
    _signalingRepository = ref.read(callSignalingRepositoryProvider);
    _historyRepository = ref.read(callHistoryRepositoryProvider);
    _listenForCallKitEvents();

    // Don't rely on a synchronous currentUser check at build time —
    // Firebase Auth's persisted session may not have finished restoring
    // yet on a fresh app start, so currentUser can briefly be null even
    // for an already-logged-in user. Reacting to authStateChanges means
    // the incoming-call listener reliably (re)starts once auth actually
    // resolves, rather than failing once and never retrying.
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      if (user != null) {
        listenForIncomingCalls();
      } else {
        _incomingCallSubscription?.cancel();
        _incomingCallSubscription = null;
        _incomingCall = null;
        state = const CallState(status: CallConnectionStatus.idle);
      }
    });

    const incomingCallService = IncomingCallService();
    _callKitEventSubscription = incomingCallService.events.listen((
      event,
    ) async {
      if (event == null) return;

      switch (event) {
        case CallEventActionCallAccept(:final id):
          debugPrint('📞 [CallProvider] CallKit accept for $id');
          final callSession = await _signalingRepository.fetchCallOnce(
            callId: id,
          );
          if (callSession == null) {
            debugPrint(
              '❌ [CallProvider] Could not recover CallSession for $id',
            );
            return;
          }
          await acceptVoiceCall(
            callId: callSession.id,
            roomName: callSession.roomName,
          );

        case CallEventActionCallDecline(:final id):
          debugPrint('❌ [CallProvider] CallKit decline for $id');
          await rejectVoiceCall(callId: id);

        case CallEventActionCallTimeout(:final id):
          debugPrint('⌛ [CallProvider] CallKit timeout for $id');
          break;

        case CallEventActionCallEnded(:final id):
          debugPrint('☎️ [CallProvider] CallKit ended for $id');
          break;

        case CallEventActionCallConnected(:final id):
          debugPrint('🔌 [CallProvider] CallKit reports connected for $id');
          break;

        case CallEventActionDidUpdateDevicePushTokenVoip():
        case CallEventActionCallIncoming():
        case CallEventActionCallStart():
        case CallEventActionCallCallback():
        case CallEventActionCallToggleHold():
        case CallEventActionCallToggleMute():
        case CallEventActionCallToggleDmtf():
        case CallEventActionCallToggleGroup():
        case CallEventActionCallToggleAudioSession():
        case CallEventActionCallCustom():
          break;
      }
    });

    ref.onDispose(() {
      _missedCallTimer?.cancel();
      _authStateSubscription?.cancel();
      _incomingCallSubscription?.cancel();
      _outgoingCallSubscription?.cancel();
      _activeCallSubscription?.cancel();
      _callKitEventSubscription?.cancel();

      _callService.disconnect();
    });

    Future.microtask(_checkForPendingAcceptedCall);
    return const CallState();
  }

  Future<void> connectTestRoom() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      state = const CallState(
        status: CallConnectionStatus.failed,
        errorMessage: 'No authenticated Firebase user.',
      );
      return;
    }

    final identity = currentUser.uid;

    state = const CallState(status: CallConnectionStatus.connecting);

    debugPrint('📞 [CallProvider] Starting LiveKit foundation test...');
    debugPrint('👤 Identity: $identity');
    debugPrint('🏠 Room: ${CallConfig.testRoomName}');

    try {
      final tokenResponse = await _tokenService.fetchDevelopmentToken(
        roomName: CallConfig.testRoomName,
        participantIdentity: identity,
      );

      await _callService.connect(roomToken: tokenResponse.participantToken);

      state = const CallState(status: CallConnectionStatus.connected);

      debugPrint('✅ [CallProvider] LiveKit room connected.');
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] LiveKit connection failed: $e');
      debugPrintStack(stackTrace: stackTrace);

      state = CallState(
        status: CallConnectionStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> startVoiceCall({required String calleeId}) async {
    // Cancel any stale timer from a previous call before starting a new one.
    debugPrint('🧹StartVoiceCall-1: Cancelling previous missed-call timer');
    _missedCallTimer?.cancel();
    // Re-entrancy guard — a second invocation while one is already in
    // flight (double-tap, slow rebuild, etc.) must be a no-op, not a
    // second Firestore session + second LiveKit connection.
    if (_startVoiceCallInProgress ||
        state.status == CallConnectionStatus.connecting ||
        state.status == CallConnectionStatus.ringing ||
        state.status == CallConnectionStatus.connected) {
      debugPrint(
        '⚠️ [CallProvider] startVoiceCall ignored — call already in progress.',
      );
      return;
    }
    _startVoiceCallInProgress = true;
    // =======================================================================
    // ⚙️ ECE STATE TRACKING INITIALIZATION
    // =======================================================================
    // ✅ REQUIREMENT MET: Reset call history metrics before engaging network channels!
    _callWasConnected = false;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        state = const CallState(
          status: CallConnectionStatus.failed,
          errorMessage: 'No authenticated Firebase user.',
        );
        return;
      }

      debugPrint('📞 [CallProvider] Starting voice call...');
      debugPrint('👤 Caller: ${currentUser.uid}');
      debugPrint('👤 Callee: $calleeId');

      state = const CallState(status: CallConnectionStatus.connecting);

      // 1. Create the Firestore call session.
      final callSession = await _signalingRepository.createOutgoingCall(
        callerId: currentUser.uid,
        calleeId: calleeId,
        type: CallType.voice,
      );

      _activeCallId = callSession.id;

      debugPrint('📞 [CallProvider] Voice call session created.');
      debugPrint('🆔 [CallProvider] Call ID: ${callSession.id}');
      debugPrint('📡 [CallProvider] State: ${callSession.state.name}');

      // 2. Use the Call ID as the LiveKit room name.
      final roomName = callSession.roomName;

      debugPrint('🏠 [CallProvider] LiveKit room: $roomName');

      // 3. Tell the callee that the call is ringing.
      await _signalingRepository.updateCallState(
        callId: callSession.id,
        state: call_model.CallState.ringing,
      );

      debugPrint('🔔 [CallProvider] Voice call is now ringing.');

      _listenForOutgoingCall(callId: callSession.id);

      // 4. Request the caller's temporary LiveKit token.
      final tokenResponse = await _tokenService.fetchDevelopmentToken(
        roomName: roomName,
        participantIdentity: currentUser.uid,
      );

      debugPrint('🔐 [CallProvider] Caller LiveKit token received.');

      // 5. Connect the caller to the LiveKit room.
      await _callService.connect(roomToken: tokenResponse.participantToken);

      debugPrint('✅ [CallProvider] Caller connected to LiveKit.');

      // 6. Keep microphone disabled until the call is accepted.
      await _callService.setMicrophoneEnabled(false);

      debugPrint('🎤 [CallProvider] Caller microphone waiting for acceptance.');

      // IMPORTANT:
      // We do NOT mark the Firestore call as "connected" here.
      //
      // The caller is only waiting in the LiveKit room.
      // The call becomes connected when the callee accepts it.

      state = const CallState(status: CallConnectionStatus.ringing);

      debugPrint('⏳ [CallProvider] Waiting for callee to accept...');

      debugPrint('🧹StartVoiceCall-2: Cancelling previous missed-call timer');
      _missedCallTimer?.cancel();

      _missedCallTimer = Timer(const Duration(seconds: 30), () async {
        if (state.status != CallConnectionStatus.ringing) {
          debugPrint(
            '⏱️ [CallProvider] Missed-call timer fired, '
            'but call is no longer ringing.',
          );
          return;
        }

        debugPrint(
          '⌛ [CallProvider] 30-second timeout → marking call as missed.',
        );

        try {
          // ------------------------------------------------------------
          // 1. Update Firestore first.
          // ------------------------------------------------------------
          await _signalingRepository.markMissedCall(callId: callSession.id);

          debugPrint(
            '📡 [CallProvider] Call ${callSession.id} marked as missed.',
          );

          // ------------------------------------------------------------
          // 2. Stop the LiveKit connection.
          // ------------------------------------------------------------
          await _callService.disconnect();

          // ------------------------------------------------------------
          // 3. Clean local call state.
          // ------------------------------------------------------------
          _incomingCall = null;
          _activeCallId = null;

          // ------------------------------------------------------------
          // 4. The Firestore listener will receive the actual
          //    CallState.missed and create CallHistory.
          // ------------------------------------------------------------
          state = const CallState(
            status: CallConnectionStatus.ended,
            errorMessage: 'No answer.',
          );

          debugPrint('⌛ [CallProvider] Local call state → missed/no answer.');
        } catch (error, stackTrace) {
          debugPrint('❌ [CallProvider] Failed to process missed call: $error');

          debugPrintStack(stackTrace: stackTrace);
        }
      });
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Failed to start voice call: $e');
      debugPrintStack(stackTrace: stackTrace);

      state = CallState(
        status: CallConnectionStatus.failed,
        errorMessage: e.toString(),
      );
    } finally {
      _startVoiceCallInProgress = false;
    }
  }

  Future<void> acceptVoiceCall({
    required String callId,
    required String roomName,
  }) async {
    if (_acceptVoiceCallInProgress ||
        state.status == CallConnectionStatus.connecting ||
        state.status == CallConnectionStatus.connected) {
      debugPrint(
        '⚠️ [CallProvider] acceptVoiceCall ignored — already connecting/connected.',
      );
      return;
    }
    _acceptVoiceCallInProgress = true;
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        state = const CallState(
          status: CallConnectionStatus.failed,
          errorMessage: 'No authenticated Firebase user.',
        );
        return;
      }
      debugPrint('🧹AcceptVoiceCall-1: Cancelling previous missed-call timer');
      _missedCallTimer?.cancel();
      _activeCallId = callId;
      _listenForActiveCall(callId: callId);
      debugPrint('📞 [CallProvider] Accepting voice call...');
      debugPrint('🆔 [CallProvider] Call ID: $callId');
      debugPrint('🏠 [CallProvider] Room: $roomName');
      debugPrint('👤 [CallProvider] Identity: ${currentUser.uid}');

      state = const CallState(status: CallConnectionStatus.connecting);

      // 1. Tell Firestore that the callee accepted the call.
      await _signalingRepository.updateCallState(
        callId: callId,
        state: call_model.CallState.connecting,
      );

      debugPrint('📡 [CallProvider] Call state → connecting');

      // 2. Request a temporary LiveKit development token.
      final tokenResponse = await _tokenService.fetchDevelopmentToken(
        roomName: roomName,
        participantIdentity: currentUser.uid,
      );

      debugPrint('🔐 [CallProvider] LiveKit token received.');

      // 3. Connect the callee to the LiveKit room.
      await _callService.connect(roomToken: tokenResponse.participantToken);

      debugPrint('✅ [CallProvider] Callee connected to LiveKit.');

      // ✅ REQUIREMENT MET: Track successful handshake parameters locally!
      _callWasConnected = true;

      // 4. Enable microphone for the voice call.
      await _callService.setMicrophoneEnabled(true);

      debugPrint('🎤 [CallProvider] Microphone enabled.');

      // 5. Update Firestore call state.
      await _signalingRepository.updateCallState(
        callId: callId,
        state: call_model.CallState.connected,
      );

      debugPrint('📡 [CallProvider] Call state → connected');

      // 6. Update local provider state.
      state = const CallState(status: CallConnectionStatus.connected);

      debugPrint('🎉 [CallProvider] Voice call connected successfully.');
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Failed to accept voice call: $e');
      debugPrintStack(stackTrace: stackTrace);

      // ❗ A real connection failure is FAILED, not ENDED.
      try {
        await _signalingRepository.updateCallState(
          callId: callId,
          state: call_model.CallState.failed,
        );
      } catch (signalingError) {
        debugPrint(
          '❌ [CallProvider] Failed to update call failure state: '
          '$signalingError',
        );
      }

      state = CallState(
        status: CallConnectionStatus.failed,
        errorMessage: e.toString(),
      );
    } finally {
      // 🧹 Always release the guard.
      _acceptVoiceCallInProgress = false;
    }
  }

  Future<void> rejectVoiceCall({required String callId}) async {
    debugPrint('❌ [CallProvider] Rejecting voice call...');
    debugPrint('🆔 [CallProvider] Call ID: $callId');

    try {
      debugPrint('🧹RejectVoiceCall-1: Cancelling previous missed-call timer');
      _missedCallTimer?.cancel();
      await _signalingRepository.updateCallState(
        callId: callId,
        state: call_model.CallState.rejected,
      );

      debugPrint('📡 [CallProvider] Voice call state → rejected');

      _incomingCall = null;
      state = const CallState(status: CallConnectionStatus.ended);

      debugPrint('☎️ [CallProvider] Incoming voice call rejected.');
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Failed to reject voice call: $e');
      debugPrintStack(stackTrace: stackTrace);

      state = CallState(
        status: CallConnectionStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    try {
      await _callService.setMicrophoneEnabled(enabled);

      debugPrint(
        '🎤 [CallProvider] Microphone: '
        '${enabled ? 'ENABLED' : 'DISABLED'}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Microphone error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> setCameraEnabled(bool enabled) async {
    try {
      await _callService.setCameraEnabled(enabled);

      debugPrint(
        '📷 [CallProvider] Camera: '
        '${enabled ? 'ENABLED' : 'DISABLED'}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Camera error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  StreamSubscription<CallSession?>? _incomingCallSubscription;
  StreamSubscription<CallSession?>? _outgoingCallSubscription;
  StreamSubscription<CallSession?>? _activeCallSubscription;

  CallSession? _incomingCall;
  CallSession? get incomingCall => _incomingCall;

  String? _activeCallId;

  void listenForIncomingCalls() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      debugPrint(
        '⚠️ [CallProvider] Cannot listen for incoming calls: '
        'no authenticated user.',
      );
      return;
    }

    _incomingCallSubscription?.cancel();

    debugPrint('📡 [CallProvider] Listening for incoming voice calls...');

    _incomingCallSubscription = _signalingRepository
        .watchIncomingCall(calleeId: currentUser.uid)
        .listen(
          (callSession) async {
            if (callSession == null) {
              _incomingCall = null;

              state = const CallState(status: CallConnectionStatus.idle);

              return;
            }

            if (callSession.type != CallType.voice) {
              return;
            }

            // final callAge = DateTime.now().difference(
            //   callSession.createdAt.toDate(),
            // );
            // if (callAge > _incomingCallTimeout) {
            //   debugPrint('⏰ [CallProvider] Incoming call expired.');
            //   debugPrint('🆔 [CallProvider] Call ID: ${callSession.id}');
            //   debugPrint('⌛ [CallProvider] Call age: ${callAge.inSeconds}s');
            //   await _signalingRepository.updateCallState(
            //     callId: callSession.id,
            //     state: call_model.CallState.ended,
            //   );
            //   _incomingCall = null;
            //   state = state.copyWith(clearIncomingCall: true);
            //   return;
            // }

            _incomingCall = callSession;

            state = state.copyWith(incomingCall: callSession);

            debugPrint(
              '🔄 [CallProvider] State updated → '
              'incomingCall=${state.incomingCall?.id}, '
              'status=${state.status.name}',
            );

            debugPrint('📞 [CallProvider] Incoming voice call detected!');
            debugPrint('🆔 [CallProvider] Call ID: ${callSession.id}');
            debugPrint('👤 [CallProvider] Caller: ${callSession.callerId}');
            debugPrint('📱 [CallProvider] Type: ${callSession.type.name}');
            debugPrint('📡 [CallProvider] State: ${callSession.state.name}');
            // debugPrint('⌛ [CallProvider] Call age: ${callAge.inSeconds}s');
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('❌ [CallProvider] Incoming call listener error: $error');
            debugPrintStack(stackTrace: stackTrace);
          },
        );
  }

  void _listenForOutgoingCall({required String callId}) {
    _outgoingCallSubscription?.cancel();

    debugPrint('📡 [CallProvider] Watching outgoing call: $callId');

    _outgoingCallSubscription = _signalingRepository
        .watchCall(callId: callId)
        .listen(
          (callSession) async {
            if (callSession == null) {
              return;
            }

            debugPrint(
              '📡 [CallProvider] Outgoing call state: '
              '${callSession.state.name}',
            );

            // ============================================================
            // CONNECTED
            // ============================================================
            if (callSession.state == call_model.CallState.connected) {
              debugPrint(
                '🧹_listenForOutgoingCall-1: '
                'Cancelling previous missed-call timer',
              );

              _missedCallTimer?.cancel();

              _callWasConnected = true;

              debugPrint('🎉 [CallProvider] Callee accepted the voice call!');

              await _callService.setMicrophoneEnabled(true);

              state = const CallState(status: CallConnectionStatus.connected);

              debugPrint('🎤 [CallProvider] Caller microphone enabled.');

              return;
            }

            // ============================================================
            // TERMINAL STATES
            // ============================================================
            if (callSession.state == call_model.CallState.ended ||
                callSession.state == call_model.CallState.missed ||
                callSession.state == call_model.CallState.rejected ||
                callSession.state == call_model.CallState.cancelled ||
                callSession.state == call_model.CallState.failed) {
              await _createCallHistory(
                callSession: callSession,
                status: _historyStatusFor(callSession.state),
              );
              debugPrint(
                '🧹_listenForOutgoingCall: Cancelling missed-call timer',
              );
              _missedCallTimer?.cancel();

              debugPrint(
                '⏳ [CallProvider] Watchdog timer cancelled due to '
                'terminal state: ${callSession.state.name}',
              );

              await _callService.disconnect();

              _activeCallId = null;
              _incomingCall = null;

              state = callSession.state == call_model.CallState.failed
                  ? const CallState(
                      status: CallConnectionStatus.failed,
                      errorMessage: 'Voice call failed.',
                    )
                  : const CallState(status: CallConnectionStatus.ended);

              debugPrint(
                '🔌 [CallProvider] Terminal state reached: ${callSession.state.name}',
              );
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('❌ [CallProvider] Outgoing call listener error: $error');

            debugPrintStack(stackTrace: stackTrace);
          },
        );
  }

  void _listenForActiveCall({required String callId}) {
    _activeCallSubscription?.cancel();

    debugPrint('📡 [CallProvider] Watching active call: $callId');

    _activeCallSubscription = _signalingRepository
        .watchCall(callId: callId)
        .listen(
          (callSession) async {
            if (callSession == null) return;

            debugPrint(
              '📡 [CallProvider] Active call state: '
              '${callSession.state.name}',
            );

            // ============================================================
            // TERMINAL STATES
            // ============================================================
            if (callSession.state == call_model.CallState.ended ||
                callSession.state == call_model.CallState.missed ||
                callSession.state == call_model.CallState.rejected ||
                callSession.state == call_model.CallState.cancelled ||
                callSession.state == call_model.CallState.failed) {
              await _createCallHistory(
                callSession: callSession,
                status: _historyStatusFor(callSession.state),
              );

              _missedCallTimer?.cancel();

              await _callService.disconnect();

              _activeCallId = null;
              _incomingCall = null;

              state = callSession.state == call_model.CallState.failed
                  ? const CallState(
                      status: CallConnectionStatus.failed,
                      errorMessage: 'Voice call failed.',
                    )
                  : const CallState(status: CallConnectionStatus.ended);

              debugPrint(
                '🔌 [CallProvider] Terminal state reached: ${callSession.state.name}',
              );
            }
          },
          onError: (Object error, StackTrace stackTrace) {
            debugPrint('❌ [CallProvider] Active call listener error: $error');

            debugPrintStack(stackTrace: stackTrace);
          },
        );
  }

  Future<void> endCurrentCall() async {
    final callId = _activeCallId;
    _missedCallTimer?.cancel();

    // The one signal that distinguishes "we hung up after talking" from
    // "caller cancelled before it was ever answered."
    final finalState = _callWasConnected
        ? call_model.CallState.ended
        : call_model.CallState.cancelled;

    debugPrint('☎️ [CallProvider] Ending current call ($finalState)...');
    debugPrint('🆔 [CallProvider] Call ID: $callId');

    try {
      if (callId != null) {
        await _signalingRepository.updateCallState(
          callId: callId,
          state: finalState,
        );

        debugPrint('📡 [CallProvider] Firestore call state → $finalState');
      }

      await _callService.disconnect();

      debugPrint('🔌 [CallProvider] LiveKit disconnected.');

      _activeCallId = null;

      state = const CallState(status: CallConnectionStatus.ended);

      debugPrint('☎️ [CallProvider] Current call ended successfully.');
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Failed to end call: $e');
      debugPrintStack(stackTrace: stackTrace);

      state = CallState(
        status: CallConnectionStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await _callService.disconnect();
      state = const CallState(status: CallConnectionStatus.ended);
      debugPrint('☎️ [CallProvider] LiveKit room disconnected.');
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Disconnect error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _createCallHistory({
    required CallSession callSession,
    required CallHistoryStatus status,
  }) async {
    if (_historyCreatedCallIds.contains(callSession.id)) {
      debugPrint(
        '⚠️ [CallProvider] Call history already created '
        'for ${callSession.id}',
      );
      return;
    }

    _historyCreatedCallIds.add(callSession.id);

    try {
      await _historyRepository.createFromCallSession(
        callSession: callSession,
        status: status,
      );

      debugPrint(
        '📚 [CallProvider] Call history saved → '
        '${callSession.id} (${status.name})',
      );
      await _sendCallSystemMessage(callSession: callSession, status: status);
    } catch (error, stackTrace) {
      // Allow a retry if Firestore temporarily fails.
      _historyCreatedCallIds.remove(callSession.id);

      debugPrint('❌ [CallProvider] Failed to save call history: $error');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _sendCallSystemMessage({
    required CallSession callSession,
    required CallHistoryStatus status,
  }) async {
    try {
      // Resolve the authentic 1-to-1 conversation.
      // final conversationRepository = ref.read(conversationRepositoryProvider);

      // // Dynamically resolve or unlock the permanent 1:1 text chat room container ID
      // // ✅ NO MORE GUESSING: Guarantees that system messages are routed to the authentic chat thread!
      // final conversation = await conversationRepository
      //     .createOrOpenConversation(
      //       currentUserId: callSession.callerId,
      //       otherUserId: callSession.calleeId,
      //     );

      // final String conversationId = conversation.id;

      final messageRepository = ref.read(
        conversationMessageRepositoryProvider(callSession.conversationId),
      );
      //final docRef = messageRepository.createMessageDocument();

      // Use the CallSession ID as the message ID.
      //
      // This makes the system message idempotent:
      // caller and callee will target the same Firestore message document.
      final systemMessage = CallSystemMessage(
        id: callSession.id,
        senderId: callSession.callerId,
        senderName: '', // system message — sender identity isn't displayed
        createdAt: callSession.endedAt ?? Timestamp.now(),
        readBy: const [],
        deletedForEveryone: false,
        deletedBy: const [],
        callType: callSession.type,
        status: status,
        durationSeconds: callSession.duration?.inSeconds,
      );

      await messageRepository.sendMessage(systemMessage);
      debugPrint(
        '📞 [CallProvider] Call system message sent → ${systemMessage.id}',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [CallProvider] Failed to send call system message: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _checkForPendingAcceptedCall() async {
    try {
      final callId = await PendingCallService.instance.consumeAcceptedCall();

      if (callId == null) {
        return;
      }

      debugPrint('📞 [CallProvider] Pending accepted call found → $callId');

      await _handlePendingAcceptedCall(callId);
    } catch (e) {
      debugPrint('❌ [CallProvider] Failed to check pending accepted call: $e');
    }
  }

  Future<void> _handlePendingAcceptedCall(String callId) async {
    try {
      debugPrint(
        '📞 [CallProvider] Processing accepted background call → $callId',
      );

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint(
          '⚠️ [CallProvider] Cannot resume accepted call: '
          'no authenticated user.',
        );
        return;
      }

      final callSession = await _signalingRepository.fetchCallOnce(
        callId: callId,
      );

      if (callSession == null) {
        debugPrint('⚠️ [CallProvider] Call session not found → $callId');
        return;
      }

      if (callSession.calleeId != currentUser.uid) {
        debugPrint(
          '⚠️ [CallProvider] Accepted call does not belong '
          'to current user.',
        );
        return;
      }

      //_activeCallId = callId;
      _incomingCall = callSession;
      state = state.copyWith(incomingCall: callSession);
      // NOTE: status is intentionally NOT set here — acceptVoiceCall()
      // owns that transition and has its own re-entrancy guard checking
      // status == connecting. Pre-setting it here would trip that guard
      // and cause acceptVoiceCall() to silently no-op.

      await acceptVoiceCall(
        callId: callSession.id,
        roomName: callSession.roomName,
      );

      debugPrint('✅ [CallProvider] Background accepted call resumed → $callId');
    } catch (e) {
      debugPrint('❌ [CallProvider] Failed to resume accepted call: $e');

      state = CallState(
        status: CallConnectionStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  void _listenForCallKitEvents() {
    _callKitEventSubscription?.cancel();

    _callKitEventSubscription = IncomingCallService().events.listen(
      (event) async {
        if (event == null) {
          return;
        }

        debugPrint('📞 [CallKit] Event received → ${event.runtimeType}');

        switch (event) {
          case CallEventActionCallAccept(:final id):
            debugPrint('📞 [CallKit] Foreground Accept → $id');

            await _handleCallKitAccept(id);

          case CallEventActionCallDecline(:final id):
            debugPrint('❌ [CallKit] Foreground Decline → $id');

            await _handleCallKitDecline(id);

          case CallEventActionCallTimeout(:final id):
            debugPrint('⌛ [CallKit] Foreground Timeout → $id');

            await _handleCallKitTimeout(id);

          default:
            break;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('❌ [CallKit] Event listener error: $error');

        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  Future<void> _handleCallKitAccept(String callId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint(
          '⚠️ [CallKit] Cannot accept call: '
          'no authenticated user.',
        );
        return;
      }

      final callSession = await _signalingRepository.fetchCallOnce(
        callId: callId,
      );

      if (callSession == null) {
        debugPrint('⚠️ [CallKit] Call session not found → $callId');
        return;
      }

      if (callSession.calleeId != currentUser.uid) {
        debugPrint('⚠️ [CallKit] Call does not belong to current user.');
        return;
      }

      _activeCallId = callSession.id;
      _incomingCall = callSession;

      // state = state.copyWith(
      //   incomingCall: callSession,
      //   status: CallConnectionStatus.connecting,
      // );

      await acceptVoiceCall(
        callId: callSession.id,
        roomName: callSession.roomName,
      );

      debugPrint('✅ [CallKit] Foreground call accepted → $callId');
    } catch (e) {
      debugPrint('❌ [CallKit] Foreground Accept failed: $e');
    }
  }

  Future<void> _handleCallKitDecline(String callId) async {
    try {
      final callSession = await _signalingRepository.fetchCallOnce(
        callId: callId,
      );

      if (callSession == null) {
        return;
      }

      await _signalingRepository.updateCallState(
        callId: callId,
        state: call_model.CallState.rejected,
      );

      _incomingCall = null;

      state = const CallState(status: CallConnectionStatus.ended);

      debugPrint('📡 [CallKit] Foreground call rejected → $callId');
    } catch (e) {
      debugPrint('❌ [CallKit] Foreground Decline failed: $e');
    }
  }

  Future<void> _handleCallKitTimeout(String callId) async {
    try {
      await _signalingRepository.markMissedCall(callId: callId);

      _incomingCall = null;

      state = const CallState(status: CallConnectionStatus.ended);

      debugPrint('📡 [CallKit] Foreground call missed → $callId');
    } catch (e) {
      debugPrint('❌ [CallKit] Foreground Timeout failed: $e');
    }
  }
}
