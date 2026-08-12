import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_player_service.dart';
import '../services/audio_recorder_service.dart';

final audioRecorderServiceProvider = Provider<AudioRecorderService>((ref) {
  final service = AudioRecorderService();

  ref.onDispose(service.dispose);

  return service;
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();

  ref.onDispose(service.dispose);

  return service;
});
