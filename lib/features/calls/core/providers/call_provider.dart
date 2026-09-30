// //import 'dart:collection';
// import 'dart:async';
// import 'package:chat_app/features/calls/core/controllers/call_lifecycle_controller.dart';
// import 'package:chat_app/features/calls/core/controllers/call_media_controller.dart';
// import 'package:chat_app/features/calls/core/services/call_audio_coordinator.dart';
// import 'package:chat_app/features/calls/core/services/call_audio_service.dart';
// import 'package:chat_app/features/calls/core/services/call_history_recorder.dart';
// import 'package:chat_app/features/calls/core/services/call_signaling_listner.dart';
// import 'package:chat_app/features/calls/core/services/callkit_bridge.dart';
// //import 'package:chat_app/features/chat/providers/user_provider.dart';
// //import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// //import 'package:flutter/material.dart';
// //import 'package:flutter_callkit_incoming_maintained/entities/call_event.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// //import 'package:flutter_callkit_incoming_maintained/flutter_callkit_incoming_maintained.dart';

// import 'package:chat_app/features/calls/core/models/call_history.dart';
// import 'package:chat_app/features/calls/core/models/call_session.dart';
// import 'package:chat_app/features/calls/core/repositories/call_history_repository.dart';
// //import 'package:chat_app/features/chat/data/models/message.dart';
// import 'package:chat_app/features/chat/providers/conversation_message_provider.dart';
// import 'package:chat_app/features/chat/providers/conversation_provider.dart';
// import 'package:chat_app/core/config/call_config.dart';
// import 'package:chat_app/features/calls/core/services/call_token_service.dart';
// import 'package:chat_app/features/calls/core/services/livekit_call_service.dart';
// import 'package:chat_app/features/calls/core/repositories/call_signaling_repository.dart';
// import 'package:chat_app/features/calls/core/models/call_type.dart';
// import 'package:chat_app/features/calls/core/models/call_state.dart'
//     as call_model;
// import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
// import 'package:chat_app/features/calls/core/services/pending_call_service.dart';

// enum CallConnectionStatus {
//   idle,
//   ringing,
//   connecting,
//   connected,
//   reconnecting,
//   failed,
//   ended,
// }

// class CallUiState {
//   const CallUiState({
//     this.status = CallConnectionStatus.idle,
//     this.errorMessage,
//     this.incomingCall,
//   });

//   final CallConnectionStatus status;
//   final String? errorMessage;
//   final CallSession? incomingCall;

//   CallUiState copyWith({
//     CallConnectionStatus? status,
//     String? errorMessage,
//     CallSession? incomingCall,
//     bool clearIncomingCall = false,
//   }) {
//     return CallUiState(
//       status: status ?? this.status,
//       errorMessage: errorMessage ?? this.errorMessage,
//       incomingCall: clearIncomingCall
//           ? null
//           : incomingCall ?? this.incomingCall,
//     );
//   }
// }

// final callTokenServiceProvider = Provider<CallTokenService>(
//   (ref) => const CallTokenService(),
// );

// final liveKitCallServiceProvider = Provider<LiveKitCallService>(
//   (ref) => LiveKitCallService(),
// );

// final callSignalingRepositoryProvider = Provider<CallSignalingRepository>((
//   ref,
// ) {
//   return CallSignalingRepository(
//     conversationRepository: ref.read(conversationRepositoryProvider),
//   );
// });

// final callProvider = NotifierProvider<CallNotifier, CallUiState>(
//   CallNotifier.new,
// );

// class CallNotifier extends Notifier<CallUiState> {
//   //static const Duration _incomingCallTimeout = Duration(seconds: 30);
//   //Timer? _missedCallTimer;
//   StreamSubscription<User?>? _authStateSubscription;
//   StreamSubscription<void>? _peerGoneSubscription;
//   StreamSubscription<RemoteMessage>? _foregroundPushSubscription;
//   StreamSubscription<void>? _reconnectingSubscription;
//   StreamSubscription<void>? _reconnectedSubscription;

//   late final CallTokenService _tokenService;
//   late final LiveKitCallService _callService;
//   late final CallSignalingRepository _signalingRepository;
//   late final CallKitBridge _callKitBridge;
//   // ============================================================
//   late final CallAudioService _audio;
//   late final CallAudioCoordinator _audioCoordinator;
//   late final CallSignalingListener _signalingListener;
//   // ============================================================
//   late final CallHistoryRecorder _historyRecorder;
//   late final CallMediaController _mediaController;
//   late final CallLifecycleController _lifecycleController;  

//   // ===========================================================
//   // bool _speakerOn = false;
//   // ============================================================
//   // bool _micEnabled = true;
//   bool get micEnabled => _mediaController.snapshot.micEnabled;
//   bool get speakerOn => _mediaController.snapshot.speakerOn;
//   CallHistoryStatus _historyStatusFor(call_model.CallState state) {
//     return CallHistory.fromCallState(state);
//   }

//   @override
//   CallUiState build() {
//     _tokenService = ref.read(callTokenServiceProvider);
//     _callService = ref.read(liveKitCallServiceProvider);
//     _signalingRepository = ref.read(callSignalingRepositoryProvider);
//     _mediaController = CallMediaController(callService: _callService);
//     _audio = ref.read(callAudioServiceProvider);
//     _callKitBridge = CallKitBridge(
//       onAccept: _handleCallKitAccept,
//       onDecline: _handleCallKitDecline,
//       onTimeout: _handleCallKitTimeout,
//     )..start();
//     _foregroundPushSubscription = FirebaseMessaging.onMessage.listen((message) {
//       if (message.data['type'] != 'incoming_call') return;
//       unawaited(
//         _callKitBridge.show(
//           callId: message.data['callId'] ?? '',
//           callerName: message.data['callerName'] ?? 'Unknown',
//           callerAvatarUrl: message.data['callerAvatarUrl'],
//           isVideoCall: message.data['callType'] == 'video',
//         ),
//       );
//     });
//     _audioCoordinator = CallAudioCoordinator(
//       audio: _audio,
//       localUserId: () => FirebaseAuth.instance.currentUser?.uid,
//       // Your in-app IncomingVoiceCallDialog is the foreground ringtone
//       // fallback, so this coordinator only ever runs while that's the path
//       // in play — CallKit's native screen isn't tracked here. If you later
//       // add a real "CallKit is currently showing" flag, wire it in instead.
//       isNativeIncomingUiVisible: () => _callKitBridge.isShowingNativeUi,
//     );
//     _historyRecorder = CallHistoryRecorder(
//       repository: ref.read(
//         callHistoryRepositoryProvider,
//       ), // adjust to your actual repository provider name
//       sendSystemMessage: (conversationId, message) async {
//         final messageRepository = ref.read(
//           conversationMessageRepositoryProvider(conversationId),
//         );
//         await messageRepository.sendMessage(message);
//       },
//       maxTrackedIds: 200,
//     );
//     _signalingListener = CallSignalingListener(
//       repository: _signalingRepository,
//       onIncoming: _handleIncomingCallDetected,
//       onIncomingCleared: _handleIncomingCallCleared,
//       onTransition: _handleCallTransition,
//       onConnected: _handleCallConnected,
//       onTerminal: _handleCallTerminal,
//     );
//     _lifecycleController = CallLifecycleController(
//       signaling: _signalingRepository,
//       tokenService: _tokenService,
//       callService: _callService,
//       media: _mediaController,
//       ringTimeout: const Duration(seconds: 30),
//     );
//     // Don't rely on a synchronous currentUser check at build time —
//     // Firebase Auth's persisted session may not have finished restoring
//     // yet on a fresh app start, so currentUser can briefly be null even
//     // for an already-logged-in user. Reacting to authStateChanges means
//     // the incoming-call listener reliably (re)starts once auth actually
//     // resolves, rather than failing once and never retrying.
//     _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen((
//       user,
//     ) {
//       if (user != null) {
//         // ✅ STEP 1: Eagerly attaches the core signaling mailbox connection channel
//         _signalingListener.watchInbox(userId: user.uid);
//       } else {
//         // Signed out — no Firestore write from this client can succeed anymore.
//         // Tear down everything locally instead of routing through
//         // endCurrentCall(), which would just fail with PERMISSION_DENIED.
//         _signalingListener.stopInbox();
//         _signalingListener.stopActive();
//   _peerGoneSubscription?.cancel();       // <-- add
//   _reconnectingSubscription?.cancel();   // <-- add
//   _reconnectedSubscription?.cancel();    // <-- add
//         _activeCallId = null;
//         _incomingCall = null;
//         unawaited(_audioCoordinator.reset());
//         unawaited(_callService.disconnect());
//         state = const CallUiState(status: CallConnectionStatus.idle);
//       }
//     });

//     ref.onDispose(() {
//       _authStateSubscription?.cancel();
//       _foregroundPushSubscription?.cancel();
//       _peerGoneSubscription?.cancel();
//       _reconnectingSubscription?.cancel();
//       _reconnectedSubscription?.cancel();
//       unawaited(_callKitBridge.dispose());
//       _callService.disconnect();
//       unawaited(_callService.disconnect());
//       unawaited(_signalingListener.dispose());    // <-- missing
//   _lifecycleController.dispose(); 
//       unawaited(_audioCoordinator.dispose());
//     });

//     Future.microtask(_checkForPendingAcceptedCall);
//     return const CallUiState();
//   }

//   void _handleIncomingCallDetected(CallSession session) {
//     if (session.type != CallType.voice) return;
//     _incomingCall = session;
//     unawaited(
//       _audioCoordinator.onSession(
//         session,
//         speakerOn: _mediaController.snapshot.speakerOn,
//       ),
//     );
//     state = state.copyWith(incomingCall: session);
//   }

//   void _handleIncomingCallCleared(String callId) {
//     unawaited(_callKitBridge.dismiss(callId));
//     _incomingCall = null;
//     unawaited(_audioCoordinator.reset());
//     state = const CallUiState(status: CallConnectionStatus.idle);
//   }

//   void _handleCallTransition(CallSession session) {
//     unawaited(
//       _audioCoordinator.onSession(
//         session,
//         speakerOn: _mediaController.snapshot.speakerOn,
//       ),
//     );
//     debugPrint('📡 [CallProvider] Call state: ${session.state.name}');
//     if (session.state == call_model.CallState.reconnecting) {
//       state = state.copyWith(status: CallConnectionStatus.reconnecting);
//     }
//   }

//   void _handleCallConnected(CallSession session) {
//     unawaited(_lifecycleController.onCallConnected());
//     state = state.copyWith(status: CallConnectionStatus.connected);
//   }

//   Future<void> _handleCallTerminal(
//     CallSession session,
//     call_model.CallState reason,
//   ) async {
//     unawaited(_callKitBridge.dismiss(session.id));

//     // Everything below must happen immediately — the person sees/hears the
//     // call end right away, regardless of how long history recording takes.
//     // _missedCallTimer?.cancel();
//     unawaited(_peerGoneSubscription?.cancel());
//     unawaited(_reconnectingSubscription?.cancel());
//     unawaited(_reconnectedSubscription?.cancel());
//     await _callService.disconnect();
//     _activeCallId = null;
//     _incomingCall = null;
//     state = state.copyWith(
//       status: reason == call_model.CallState.failed
//           ? CallConnectionStatus.failed
//           : CallConnectionStatus.ended,
//       clearIncomingCall: true,
//     );
//     debugPrint('🔌 [CallProvider] Terminal state reached: ${reason.name}');
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid != null) {
//       _signalingListener.watchInbox(
//         userId: uid,
//       ); // re-arm — this replaces the old explicit listenForIncomingCalls() call
//     }
//     unawaited(
//       _historyRecorder.record(
//         session: session,
//         status: _historyStatusFor(reason),
//         localUserId: FirebaseAuth.instance.currentUser?.uid ?? '',
//       ),
//     );
//     // Bookkeeping — best-effort, doesn't block the call from visibly ending.
//     // if future we need senderName to historyRecorder then use below line
//     // unawaited(_recordCallHistory(session: session, reason: reason));
//   }

//   Future<void> connectTestRoom() async {
//     if (!kDebugMode) {
//       state = const CallUiState(
//         status: CallConnectionStatus.failed,
//         errorMessage: 'Test room is unavailable outside debug builds.',
//       );
//       return;
//     }
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       state = const CallUiState(
//         status: CallConnectionStatus.failed,
//         errorMessage: 'No authenticated Firebase user.',
//       );
//       return;
//     }

//     final identity = currentUser.uid;

//     state = const CallUiState(status: CallConnectionStatus.connecting);

//     debugPrint('📞 [CallProvider] Starting LiveKit foundation test...');
//     debugPrint('👤 Identity: $identity');
//     debugPrint('🏠 Room: ${CallConfig.testRoomName}');

//     try {
//       final tokenResponse = await _tokenService.fetchDevelopmentToken(
//         roomName: CallConfig.testRoomName,
//         participantIdentity: identity,
//       );

//       await _callService.connect(roomToken: tokenResponse.participantToken);

//       state = const CallUiState(status: CallConnectionStatus.connected);

//       debugPrint('✅ [CallProvider] LiveKit room connected.');
//     } catch (e, stackTrace) {
//       debugPrint('❌ [CallProvider] LiveKit connection failed: $e');
//       debugPrintStack(stackTrace: stackTrace);

//       state = CallUiState(
//         status: CallConnectionStatus.failed,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   Future<void> startVoiceCall({required String calleeId}) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) {
//       state = const CallUiState(
//         status: CallConnectionStatus.failed,
//         errorMessage: 'No authenticated user.',
//       );
//       return;
//     }
//     state = state.copyWith(status: CallConnectionStatus.connecting);
//     final result = await _lifecycleController.startCall(
//       callerId: currentUser.uid,
//       calleeId: calleeId,
//       type: CallType.voice,
//       //onTimeout: () => unawaited(_onRingTimeout()),
//       onTimeout: _onRingTimeout,
//       onSessionCreated: (session) =>
//           _activeCallId = session.id, // fixes the gap in #4
//     );
//     if (!result.ok || result.session == null) {
//       state = CallUiState(
//         status: CallConnectionStatus.failed,
//         errorMessage: result.error ?? 'Failed to start call.',
//       );
//       return;
//     }
//     state = state.copyWith(status: CallConnectionStatus.ringing);
//     _signalingListener.watchActive(callId: result.session!.id);
//     _subscribeToRoomEvents(); // fixes the gap in #4
//   }

//   Future<void> acceptVoiceCall({
//     required String callId,
//     required String roomName,
//   }) async {
//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser == null) return;
//     _activeCallId =
//         callId; // set immediately here too — acceptCall has no equivalent in-flight window issue since callId already exists going in, but keep it consistent
//     state = state.copyWith(status: CallConnectionStatus.connecting);
//     final error = await _lifecycleController.acceptCall(
//       callId: callId,
//       roomName: roomName,
//       userId: currentUser.uid,
//     );
//     if (error != null) {
//       state = CallUiState(
//         status: CallConnectionStatus.failed,
//         errorMessage: error,
//       );
//       return;
//     }
//     _signalingListener.watchActive(callId: callId);
//     _subscribeToRoomEvents();
//   }
// void _subscribeToRoomEvents() {
//     _peerGoneSubscription?.cancel();
//     _peerGoneSubscription = _callService.onPeerGone.listen((_) {
//       if (_activeCallId != null) endCurrentCall();
//     });

//     _reconnectingSubscription?.cancel();
//     _reconnectingSubscription = _callService.onRoomReconnecting.listen((_) {
//       if (_activeCallId == null) return;
//       unawaited(
//         _signalingRepository.updateCallState(
//           callId: _activeCallId!,
//           state: call_model.CallState.reconnecting,
//         ),
//       );
//     });

//     _reconnectedSubscription?.cancel();
//     _reconnectedSubscription = _callService.onRoomReconnected.listen((_) {
//       if (_activeCallId == null) return;
//       unawaited(
//         _signalingRepository.updateCallState(
//           callId: _activeCallId!,
//           state: call_model.CallState.connected,
//         ),
//       );
//     });
//   }
//   Future<String?> rejectVoiceCall({required String callId}) async {
//     final error = await _lifecycleController.rejectCall(callId: callId);
//     _incomingCall = null;
//     state = error != null
//         ? CallUiState(status: CallConnectionStatus.failed, errorMessage: error)
//         : const CallUiState(status: CallConnectionStatus.ended);
//     return null;
//   }

//   Future<void> setMicrophoneEnabled(bool enabled) =>
//       _mediaController.setMicrophoneEnabled(enabled);

//   Future<void> setCameraEnabled(bool enabled) =>
//       _mediaController.setCameraEnabled(enabled);

//   CallSession? _incomingCall;
//   CallSession? get incomingCall => _incomingCall;

//   String? _activeCallId;

//   Future<void> endCurrentCall() async {
//     final callId = _activeCallId;
//     unawaited(
//       _audioCoordinator.reset(),
//     ); // ring/tone can't outlive the button press
//     await _lifecycleController.endCall(callId: callId);
//     _activeCallId = null;
//     state = const CallUiState(status: CallConnectionStatus.ended);
//   }

//   Future<void> disconnect() async {
//     try {
//       await _callService.disconnect();
//       if (state.status != CallConnectionStatus.failed) {
//         state = state.copyWith(status: CallConnectionStatus.ended);
//       }
//       debugPrint('☎️ [CallProvider] LiveKit room disconnected.');
//     } catch (e, stackTrace) {
//       debugPrint('❌ [CallProvider] Disconnect error: $e');
//       debugPrintStack(stackTrace: stackTrace);
//     }
//   } 

//   Future<void> _checkForPendingAcceptedCall() async {
//     try {
//       final callId = await PendingCallService.instance.consumeAcceptedCall();

//       if (callId == null) {
//         return;
//       }

//       debugPrint('📞 [CallProvider] Pending accepted call found → $callId');

//       await _handlePendingAcceptedCall(callId);
//     } catch (e) {
//       debugPrint('❌ [CallProvider] Failed to check pending accepted call: $e');
//     }
//   }

//   Future<void> _handlePendingAcceptedCall(String callId) async {
//     try {
//       debugPrint(
//         '📞 [CallProvider] Processing accepted background call → $callId',
//       );
//       // =======================================================================
//       // 🛡️ CIRCUIT-BREAKER: Cancel active listener instantly at entry point!
//       // =======================================================================
//       final currentUser = FirebaseAuth.instance.currentUser;

//       if (currentUser == null) {
//         debugPrint(
//           '⚠️ [CallProvider] Cannot resume accepted call: '
//           'no authenticated user.',
//         );
//         return;
//       }

//       final callSession = await _signalingRepository.fetchCallOnce(
//         callId: callId,
//       );

//       if (callSession == null) {
//         debugPrint('⚠️ [CallProvider] Call session not found → $callId');
//         return;
//       }

//       if (callSession.calleeId != currentUser.uid) {
//         debugPrint(
//           '⚠️ [CallProvider] Accepted call does not belong '
//           'to current user.',
//         );
//         return;
//       }

//       _incomingCall = callSession;
//       state = state.copyWith(incomingCall: callSession);
//       // NOTE: status is intentionally NOT set here — acceptVoiceCall()
//       // owns that transition and has its own re-entrancy guard checking
//       // status == connecting. Pre-setting it here would trip that guard
//       // and cause acceptVoiceCall() to silently no-op.

//       await acceptVoiceCall(
//         callId: callSession.id,
//         roomName: callSession.roomName,
//       );

//       debugPrint('✅ [CallProvider] Background accepted call resumed → $callId');
//     } catch (e) {
//       debugPrint('❌ [CallProvider] Failed to resume accepted call: $e');

//       state = CallUiState(
//         status: CallConnectionStatus.failed,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   Future<void> _handleCallKitAccept(String callId) async {
//     try {
//       // =======================================================================
//       // 🛡️ CIRCUIT-BREAKER: Cancel active listener instantly at entry point!
//       // =======================================================================
//       // _incomingCallSubscription?.cancel();
//       // _incomingCallSubscription = null;

//       final currentUser = FirebaseAuth.instance.currentUser;

//       if (currentUser == null) {
//         debugPrint(
//           '⚠️ [CallKit] Cannot accept call: '
//           'no authenticated user.',
//         );
//         return;
//       }

//       final callSession = await _signalingRepository.fetchCallOnce(
//         callId: callId,
//       );

//       if (callSession == null) {
//         debugPrint('⚠️ [CallKit] Call session not found → $callId');
//         return;
//       }

//       if (callSession.calleeId != currentUser.uid) {
//         debugPrint('⚠️ [CallKit] Call does not belong to current user.');
//         return;
//       }

//       _activeCallId = callSession.id;
//       _incomingCall = callSession;

//       await acceptVoiceCall(
//         callId: callSession.id,
//         roomName: callSession.roomName,
//       );

//       debugPrint('✅ [CallKit] Foreground call accepted → $callId');
//     } catch (e) {
//       debugPrint('❌ [CallKit] Foreground Accept failed: $e');
//     }
//   }

//   Future<void> _handleCallKitDecline(String callId) async {
//     try {
//       final callSession = await _signalingRepository.fetchCallOnce(
//         callId: callId,
//       );

//       if (callSession == null) {
//         return;
//       }

//       await rejectVoiceCall(callId: callId);

//       debugPrint('📡 [CallKit] Foreground call rejected → $callId');
//     } catch (e) {
//       debugPrint('❌ [CallKit] Foreground Decline failed: $e');
//     }
//   }

//   Future<void> _handleCallKitTimeout(String callId) async {
//     try {
//       await _signalingRepository.markMissedCall(callId: callId);

//       _incomingCall = null;

//       state = const CallUiState(status: CallConnectionStatus.ended);

//       debugPrint('📡 [CallKit] Foreground call missed → $callId');
//     } catch (e) {
//       debugPrint('❌ [CallKit] Foreground Timeout failed: $e');
//     }
//   }

//   Future<void> setSpeakerphoneEnabled(bool enabled) =>
//       _mediaController.setSpeakerphoneEnabled(enabled);
// }
