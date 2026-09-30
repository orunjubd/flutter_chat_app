// features/calls/core/models/call_phase.dart
//
// CallPhase enum retired — CallState (from ../../data/models/call_state.dart)
// already has every value a local phase needs, including finer detail
// (dialing vs ringing, real outcomes rejected/cancelled/missed instead of a
// collapsed generic "ended"). Maintaining a second, narrower mirror enum
// was duplicated concept, not a needed separation. This file now only
// defines CallUiState, typed directly against the real CallState.

import 'package:chat_app/features/calls/core/models/call_state.dart'
    as call_model;
import 'call_session.dart';

/// What the LOCAL device is doing, expressed with the same CallState values
/// the signaling layer uses — not always backed by a Firestore write (e.g.
/// `connecting` while dialing out, before any call session exists yet).
class CallUiState {
  const CallUiState({
    this.phase = call_model.CallState.idle,
    this.errorMessage,
    this.incomingCall,
    this.activeCall,
    this.micEnabled = true,
    this.speakerOn = false,
    this.cameraEnabled = false,
    //  this.nativeUiVisible = false,
  });

  final call_model.CallState phase;
  final String? errorMessage;
  final CallSession? incomingCall;
  final CallSession? activeCall;
  //  final bool nativeUiVisible;

  // Media state lives HERE, not in private fields on the notifier, so a
  // rebuild can actually see it change and the mute button repaints reliably.
  final bool micEnabled;
  final bool speakerOn;
  final bool cameraEnabled;

  bool get hasIncomingCall => incomingCall != null;

  CallUiState copyWith({
    call_model.CallState? phase,
    String? errorMessage,
    CallSession? incomingCall,
    CallSession? activeCall,
    bool? micEnabled,
    bool? speakerOn,
    bool? cameraEnabled,
    //  bool? nativeUiVisible,
    bool clearIncomingCall = false,
    bool clearActiveCall = false,
    bool clearError = false,
  }) {
    return CallUiState(
      phase: phase ?? this.phase,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      incomingCall: clearIncomingCall
          ? null
          : (incomingCall ?? this.incomingCall),
      activeCall: clearActiveCall ? null : (activeCall ?? this.activeCall),
      micEnabled: micEnabled ?? this.micEnabled,
      speakerOn: speakerOn ?? this.speakerOn,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      //    nativeUiVisible: nativeUiVisible ?? this.nativeUiVisible,
    );
  }

  /// Reset to idle but keep nothing stale. Used on every terminal transition.
  static const idle = CallUiState();
}
