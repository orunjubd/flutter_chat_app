import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoicePlayerService {
  VoicePlayerService() {
    _playerStateSubscription = _player.playerStateStream.listen(
      _handlePlayerState,
    );
  }

  final AudioPlayer _player = AudioPlayer();

  final StreamController<String?> _currentUrlController =
      StreamController<String?>.broadcast();

  String? _currentUrl;

  late final StreamSubscription<PlayerState> _playerStateSubscription;

  /// Changes whenever the active playback session changes.
  ///
  /// This protects us from stale asynchronous player events, especially
  /// ProcessingState.completed events that can arrive around seek/stop/load.
  //int _playbackGeneration = 0;

  // ---------------------------------------------------------------------------
  // PUBLIC STATE
  // ---------------------------------------------------------------------------

  String? get currentUrl => _currentUrl;

  bool get isPlaying => _player.playing;

  Duration get position => _player.position;

  Duration? get duration => _player.duration;

  Stream<String?> get currentUrlStream => _currentUrlController.stream;

  Stream<bool> get playingStream => _player.playingStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // ---------------------------------------------------------------------------
  // PLAYER STATE
  // ---------------------------------------------------------------------------

  Future<void> _handlePlayerState(PlayerState state) async {
    if (state.processingState != ProcessingState.completed) {
      return;
    }

    // 🛡️ CIRCUIT BREAKER: Double check that the track position actually matched the end boundary
    // If the player position is still behind the total duration, this was a fake platform codec completion error!
    final totalDuration = _player.duration ?? Duration.zero;
    final currentPos = _player.position;

    if (totalDuration > Duration.zero &&
        currentPos < totalDuration - const Duration(milliseconds: 250)) {
      debugPrint(
        '🛡️ [AudioEngine] Intercepted and blocked spurious native completion event during seek operation.',
      );
      return;
    }

    //if (generationAtCompletion == _playbackGeneration) {
    _setCurrentUrl(null);
    //}
  }

  // ---------------------------------------------------------------------------
  // PLAY
  // ---------------------------------------------------------------------------

  Future<void> play(String url) async {
    if (url.isEmpty) {
      throw ArgumentError('Voice URL cannot be empty.');
    }

    // Same voice.
    if (_currentUrl == url) {
      await _player.play();
      return;
    }

    //_playbackGeneration++;

    // Different voice.
    await _player.stop();

    _setCurrentUrl(url);

    await _player.setUrl(url);
    await _player.play();
  }

  // ---------------------------------------------------------------------------
  // PAUSE
  // ---------------------------------------------------------------------------

  Future<void> pause() async {
    if (_currentUrl == null) {
      return;
    }

    await _player.pause();
  }

  // ---------------------------------------------------------------------------
  // RESUME
  // ---------------------------------------------------------------------------

  Future<void> resume() async {
    if (_currentUrl == null) {
      return;
    }

    await _player.play();
  }

  // ---------------------------------------------------------------------------
  // TOGGLE
  // ---------------------------------------------------------------------------

  Future<void> toggle(String url) async {
    if (url.isEmpty) {
      throw ArgumentError('Voice URL cannot be empty.');
    }

    if (_currentUrl != url) {
      await play(url);
      return;
    }

    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  // ---------------------------------------------------------------------------
  // SEEK
  // ---------------------------------------------------------------------------

  // in VoicePlayerService
  final _bufferingController = StreamController<bool>.broadcast();
  Stream<bool> get bufferingStream => _bufferingController.stream;
  //StreamSubscription<ProcessingState>? _readySub;

  Future<void> seek(Duration position) async {
    final activeUrl = _currentUrl;
    if (activeUrl == null || activeUrl.isEmpty) return;

    final safePosition = _clampToDuration(position);
    final wasPlaying = _player.playing;
    final isBackwardSeek = safePosition < _player.position;

    try {
      if (isBackwardSeek) {
        await _seekBackwardViaReload(activeUrl, safePosition, wasPlaying);
      } else {
        await _seekForward(safePosition, wasPlaying);
      }
    } catch (e) {
      debugPrint('[VoicePlayerService] seek failed: $e');
      await _recoverFromFailedSeek(activeUrl, safePosition, wasPlaying);
    }
  }

  /// Clamps [position] into the valid range [0, duration].
  Duration _clampToDuration(Duration position) {
    final total = _player.duration;
    if (position < Duration.zero) return Duration.zero;
    if (total != null && position > total) return total;
    return position;
  }

  /// Some OEM decoders (e.g. Mi 9e's AAC path) emit a spurious
  /// "completed" state after a native backward seek. Reloading the
  /// source at the target position avoids that corrupted decoder
  /// state entirely, at the cost of a fresh load.
  Future<void> _seekBackwardViaReload(
    String url,
    Duration target,
    bool resumeAfter,
  ) async {
    _bufferingController.add(true);

    try {
      await _player.stop();

      await _player.setUrl(url, initialPosition: target);

      _bufferingController.add(false);

      if (resumeAfter) {
        await _player.play();
      }
    } catch (e) {
      _bufferingController.add(false);
      rethrow;
    }
  }

  Future<void> _seekForward(Duration target, bool resumeAfter) async {
    await _player.seek(target);
    if (resumeAfter) await _player.play();
  }

  /// Fallback if a seek throws: force a clean reload at the target position.
  Future<void> _recoverFromFailedSeek(
    String url,
    Duration target,
    bool resumeAfter,
  ) async {
    try {
      await _player.stop();

      await _player.setUrl(url, initialPosition: target);

      if (resumeAfter) {
        await _player.play();
      }
    } finally {
      _bufferingController.add(false);
    }
  }

  // ---------------------------------------------------------------------------
  // STOP
  // ---------------------------------------------------------------------------

  Future<void> stop() async {
    /*
     * Invalidate all pending asynchronous completion handling first.
     */
    //_playbackGeneration++;

    await _player.stop();

    _setCurrentUrl(null);
  }

  // ---------------------------------------------------------------------------
  // INTERNAL STATE
  // ---------------------------------------------------------------------------

  void _setCurrentUrl(String? url) {
    if (_currentUrl == url) {
      return;
    }

    _currentUrl = url;

    if (!_currentUrlController.isClosed) {
      _currentUrlController.add(url);
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  Future<void> dispose() async {
    //_playbackGeneration++;

    await _playerStateSubscription.cancel();

    await _currentUrlController.close();

    await _player.dispose();
  }
}
