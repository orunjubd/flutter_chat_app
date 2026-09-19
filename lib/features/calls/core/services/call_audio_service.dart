// features/calls/core/services/call_audio_service.dart
//
// STEP 1 — the missing ringtone layer.
//
// Four distinct sounds, often confused:
//   ringback   -> CALLER hears this while the callee's phone rings. Always ours.
//   ringtone   -> CALLEE hears this. On iOS/Android CallKit the OS plays it,
//                 so ours is ONLY for the in-app foreground fallback dialog.
//   tones      -> short one-shots: connected, ended, busy, reconnecting.
//   vibration  -> callee only, and only when we own the ringtone.
//
// Everything routes through one class so there is exactly one place that can
// leave a sound playing after the call ends.
//
// MIGRATION NOTE (audioplayers -> just_audio):
// audioplayers let each AudioPlayer carry its own AudioContext
// (AudioContextAndroid / AudioContextIOS), so the loop player and the tone
// player could each declare their own routing independently.
//
// just_audio has no per-player context. Audio routing/focus on both platforms
// is controlled by ONE app-wide AudioSession (package: audio_session), which
// every AudioPlayer instance implicitly shares. So instead of attaching a
// context to a player, we now *configure the shared session* right before we
// start whichever sound needs it, and activate it. This is functionally the
// same "one place that decides routing" guarantee, just expressed globally
// instead of per-player.
//
// pubspec.yaml:
//   just_audio: ^0.10.6
//   audio_session: ^0.2.3
//   vibration: ^3.1.5

import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

enum CallTone { connected, ended, busy, reconnecting, declined }

final callAudioServiceProvider = Provider<CallAudioService>((ref) {
  final service = CallAudioService();
  ref.onDispose(service.dispose);
  return service;
});

class CallAudioService {
  CallAudioService();

  final AudioPlayer _loopPlayer = AudioPlayer();
  final AudioPlayer _tonePlayer = AudioPlayer();

  Timer? _vibrationTimer;
  bool _vibrating = false;
  String? _currentLoop;
  bool _disposed = false;

  // --- audio session configurations -------------------------------------------
  //
  // audio_session 0.2.3 no longer lets you build a standalone
  // AndroidAudioAttributes/AndroidAudioContentType pair and hand it to a
  // player the way audioplayers did. Instead they're nested inside an
  // AudioSessionConfiguration, which is what actually gets applied to the
  // shared session via `session.configure(...)`.

  /// Incoming ringtone. Routes to the RINGER stream on Android, so it obeys
  /// silent mode and ringer volume instead of media volume. On iOS it ducks
  /// other audio rather than stopping it.
  static final _ringtoneSessionConfig = AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.sonification,
      usage: AndroidAudioUsage.notificationRingtone,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    androidWillPauseWhenDucked: false,
  );

  /// Outgoing ringback. Routes to the VOICE CALL stream so it comes out of the
  /// earpiece on a voice call and follows the in-call volume rocker — exactly
  /// like a real phone.
  static final _ringbackSessionConfig = AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
    avAudioSessionCategoryOptions:
        AVAudioSessionCategoryOptions.allowBluetooth |
        AVAudioSessionCategoryOptions.duckOthers,
    avAudioSessionMode: AVAudioSessionMode.voiceChat,
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.speech,
      usage: AndroidAudioUsage.voiceCommunicationSignalling,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    androidWillPauseWhenDucked: false,
  );

  /// Short in-call tones. Must never steal focus from the LiveKit session.
  static final _toneSessionConfig = AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    avAudioSessionMode: AVAudioSessionMode.voiceChat,
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.sonification,
      usage: AndroidAudioUsage.voiceCommunicationSignalling,
    ),
    //androidAudioFocusGainType: AndroidAudioFocusGainType.none,
    androidWillPauseWhenDucked: false,
  );

  // just_audio's setAsset() wants the FULL path as declared in pubspec.yaml
  // (no implicit "assets/" prefix like audioplayers' AssetSource did).
  static const _assets = {
    'ringback': 'assets/sounds/ringback.mp3',
    'ringtone': 'assets/sounds/ringtone.mp3',
    CallTone.connected: 'assets/sounds/call_connected.mp3',
    CallTone.ended: 'assets/sounds/call_ended.mp3',
    CallTone.busy: 'assets/sounds/call_busy.mp3',
    CallTone.reconnecting: 'assets/sounds/call_reconnecting.mp3',
    CallTone.declined: 'assets/sounds/call_declined.mp3',
  };

  Future<void> _applySession(AudioSessionConfiguration config) async {
    final session = await AudioSession.instance;
    await session.configure(config);
    await session.setActive(true);
  }

  // --- caller side -------------------------------------------------------------

  /// Start ringback. Safe to call repeatedly — a second call is a no-op while
  /// the same loop is already playing.
  Future<void> startRingback({bool speakerOn = false}) async {
    if (_currentLoop == 'ringback') return;
    await stopLoop();
    _currentLoop = 'ringback';

    try {
      await _applySession(_ringbackSessionConfig);
      await _loopPlayer.setLoopMode(LoopMode.one);
      await _loopPlayer.setVolume(speakerOn ? 0.8 : 0.5);
      await _loopPlayer.setAsset(_assets['ringback']!);
      unawaited(_loopPlayer.play());
    } catch (e) {
      _log('ringback failed: $e');
      _currentLoop = null;
    }
  }

  // --- callee side ---------------------------------------------------------------

  /// Start the incoming ringtone + vibration.
  ///
  /// [handledByOs] MUST be true whenever CallKit / ConnectionService is showing
  /// the native incoming screen. The OS is already ringing; ringing again gives
  /// the user two overlapping ringtones and two vibration patterns.
  Future<void> startRingtone({
    required bool handledByOs,
    bool vibrate = true,
  }) async {
    if (handledByOs) {
      _log('ringtone skipped — OS is ringing');
      return;
    }
    if (_currentLoop == 'ringtone') return;
    await stopLoop();
    _currentLoop = 'ringtone';

    try {
      await _applySession(_ringtoneSessionConfig);
      await _loopPlayer.setLoopMode(LoopMode.one);
      await _loopPlayer.setVolume(1.0);
      await _loopPlayer.setAsset(_assets['ringtone']!);
      unawaited(_loopPlayer.play());
    } catch (e) {
      _log('ringtone failed: $e');
      _currentLoop = null;
    }

    if (vibrate) await _startVibration();
  }

  Future<void> _startVibration() async {
    if (_vibrating) return;
    if (!(await Vibration.hasVibrator())) return;
    _vibrating = true;

    // Classic ring pattern: buzz 1s, pause 1s. Re-armed by a timer because
    // repeating patterns are unreliable across OEM Android builds.
    Future<void> pulse() async {
      if (!_vibrating || _disposed) return;
      try {
        await Vibration.vibrate(pattern: const [0, 800, 1000, 800]);
      } catch (_) {}
    }

    await pulse();
    _vibrationTimer = Timer.periodic(
      const Duration(milliseconds: 2600),
      (_) => pulse(),
    );
  }

  Future<void> _stopVibration() async {
    _vibrating = false;
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  // --- one-shot tones --------------------------------------------------------------

  Future<void> playTone(CallTone tone) async {
    try {
      await _applySession(_toneSessionConfig);
      await _tonePlayer.setLoopMode(LoopMode.off);
      await _tonePlayer.setVolume(0.6);
      await _tonePlayer.setAsset(_assets[tone]!);
      unawaited(_tonePlayer.play());
    } catch (e) {
      _log('tone $tone failed: $e');
    }
  }

  /// Plays the end tone and waits for it, so the screen doesn't pop before the
  /// user hears it.
  Future<void> playEndToneAndWait(CallTone tone) async {
    await playTone(tone);
    try {
      await _tonePlayer.playerStateStream
          .firstWhere((s) => s.processingState == ProcessingState.completed)
          .timeout(const Duration(milliseconds: 1200));
    } catch (_) {
      // Timed out or stream closed before completion — fine, we tried.
    }
  }

  // --- teardown ----------------------------------------------------------------------

  Future<void> stopLoop() async {
    _currentLoop = null;
    await _stopVibration();
    try {
      await _loopPlayer.stop();
    } catch (_) {}
  }

  /// Call this on EVERY path out of a call. Belt and braces.
  Future<void> stopAll() async {
    await stopLoop();
    try {
      await _tonePlayer.stop();
    } catch (_) {}
  }

  Future<void> dispose() async {
    _disposed = true;
    await stopAll();
    await _loopPlayer.dispose();
    await _tonePlayer.dispose();
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[CallAudio] $msg');
  }
}
