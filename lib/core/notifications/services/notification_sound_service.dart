import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class NotificationSoundService {
  final AudioPlayer _player = AudioPlayer();
  DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);
  bool _loaded = false;

  /// Plays at most once per 1.5 s, so a burst of messages is one sound.
  Future<void> playMessage() async {
    final now = DateTime.now();
    if (now.difference(_last) < const Duration(milliseconds: 1500)) return;
    _last = now;
    try {
      if (!_loaded) {
        await _player.setAsset('assets/sounds/notification-message.mp3');
        _loaded = true;
      }
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      debugPrint('⚠️ [Notify] sound failed: $e');
    }
  }

  Future<void> dispose() => _player.dispose();
}
