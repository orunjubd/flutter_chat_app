import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/voice_player_service.dart';

final voicePlayerServiceProvider = Provider<VoicePlayerService>((ref) {
  final service = VoicePlayerService();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
