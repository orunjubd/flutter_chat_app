// features/calls/core/controllers/call_media_controller.dart
//
// Owns everything the user can toggle during a call. Small on purpose — this is
// the class that grows when video lands, and it must stay the ONLY place that
// touches tracks.
//
// Fixes 8(i): camera state is now tracked, not fire-and-forget.

import 'package:flutter/foundation.dart';

import 'package:chat_app/features/calls/core/services/call_service.dart';

class CallMediaSnapshot {
  const CallMediaSnapshot({
    this.micEnabled = true,
    this.speakerOn = false,
    this.cameraEnabled = false,
  });

  final bool micEnabled;
  final bool speakerOn;
  final bool cameraEnabled;

  CallMediaSnapshot copyWith({
    bool? micEnabled,
    bool? speakerOn,
    bool? cameraEnabled,
  }) => CallMediaSnapshot(
    micEnabled: micEnabled ?? this.micEnabled,
    speakerOn: speakerOn ?? this.speakerOn,
    cameraEnabled: cameraEnabled ?? this.cameraEnabled,
  );
}

class CallMediaController {
  CallMediaController({required CallService callService})
    : _callService = callService;

  final CallService _callService;

  CallMediaSnapshot _snapshot = const CallMediaSnapshot();
  CallMediaSnapshot get snapshot => _snapshot;

  /// Called when a new call starts. Without this, the second call of a session
  /// inherits the first call's mute state.
  void reset({bool speakerOn = false}) {
    _snapshot = CallMediaSnapshot(speakerOn: speakerOn);
  }

  Future<CallMediaSnapshot> setMicrophoneEnabled(bool enabled) async {
    try {
      await _callService.setMicrophoneEnabled(enabled);
      _snapshot = _snapshot.copyWith(micEnabled: enabled);
      debugPrint('🎤 [Media] mic ${enabled ? "on" : "off"}');
    } catch (e, st) {
      debugPrint('❌ [Media] mic failed: $e');
      debugPrintStack(stackTrace: st);
    }
    return _snapshot;
  }

  Future<CallMediaSnapshot> setSpeakerphoneEnabled(bool enabled) async {
    try {
      await _callService.setSpeakerphoneEnabled(enabled);
      _snapshot = _snapshot.copyWith(speakerOn: enabled);
      debugPrint('🔊 [Media] speaker ${enabled ? "on" : "off"}');
    } catch (e, st) {
      debugPrint('❌ [Media] speaker failed: $e');
      debugPrintStack(stackTrace: st);
    }
    return _snapshot;
  }

  Future<CallMediaSnapshot> setCameraEnabled(bool enabled) async {
    try {
      await _callService.setCameraEnabled(enabled);
      _snapshot = _snapshot.copyWith(cameraEnabled: enabled);
      debugPrint('📷 [Media] camera ${enabled ? "on" : "off"}');
    } catch (e, st) {
      debugPrint('❌ [Media] camera failed: $e');
      debugPrintStack(stackTrace: st);
    }
    return _snapshot;
  }

  Future<void> switchCamera() => _callService.switchCamera();
  Future<CallMediaSnapshot> toggleMic() =>
      setMicrophoneEnabled(!_snapshot.micEnabled);

  Future<CallMediaSnapshot> toggleSpeaker() =>
      setSpeakerphoneEnabled(!_snapshot.speakerOn);

  Future<CallMediaSnapshot> toggleCamera() =>
      setCameraEnabled(!_snapshot.cameraEnabled);
}
