// features/call/services/livekit_call_service.dart
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:chat_app/core/config/call_config.dart';
import 'package:chat_app/features/calls/services/call_service.dart';

class LiveKitCallService implements CallService {
  Room? _room;
  // final _listeners = <RoomListener>{};
  //@override
  //Room? get room => _room;

  @override
  Future<void> connect({required String roomToken}) async {
    if (_room != null) {
      await disconnect();
    }
    debugPrint('🔌 [LiveKit] Connecting...');
    debugPrint('🌐 [LiveKit] URL: ${CallConfig.livekitUrl}');

    final Room room = Room(
      roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
    );

    // 🚀 CLEAN CONNECT: Fire the connection stream cleanly with just the URL and token paths!
    await room.connect(CallConfig.livekitUrl, roomToken);
    _room = room;
    debugPrint('✅ [LiveKit] Connected successfully.');
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    final participant = _room?.localParticipant;

    if (participant == null) {
      throw StateError('Cannot change microphone before joining a room.');
    }

    await participant.setMicrophoneEnabled(enabled);

    debugPrint(
      '🎤 [LiveKit] Microphone '
      '${enabled ? 'enabled' : 'disabled'}.',
    );
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    final participant = _room?.localParticipant;

    if (participant == null) {
      throw StateError('Cannot change camera before joining a room.');
    }

    await participant.setCameraEnabled(enabled);

    debugPrint(
      '📷 [LiveKit] Camera '
      '${enabled ? 'enabled' : 'disabled'}.',
    );
  }

  @override
  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    try {
      await AudioManager.instance.setSpeakerOutputPreferred(
        enabled,
        force: enabled,
      );
      debugPrint(
        '🔊 [LiveKit] Speakerphone ${enabled ? 'enabled' : 'disabled'} (force: $enabled).',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [LiveKit] Failed to set speakerphone: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> disconnect() async {
    final room = _room;

    if (room == null) return;

    debugPrint('🔌 [LiveKit] Disconnecting...');

    // for (final listener in _listeners) {
    //   room.removeListener(listener);
    // }
    await room.disconnect();

    _room = null;

    debugPrint('✅ [LiveKit] Disconnected.');
  }
}
