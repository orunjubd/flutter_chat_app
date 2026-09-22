// features/call/services/livekit_call_service.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:chat_app/core/config/call_config.dart';
import 'package:chat_app/features/calls/services/call_service.dart';

@override
class LiveKitCallService implements CallService {
  Room? _room;
  EventsListener<RoomEvent>? _roomListener;
  Timer? _peerGoneTimer;
  final _peerGoneController = StreamController<void>.broadcast();

  // How long to wait after the peer disconnects before treating the call as
  // actually over. Long enough to ride out a brief network blip / LiveKit's
  // own reconnect attempt; short enough that a genuinely-gone peer (sign-out,
  // crash, force-quit) doesn't leave the other side hanging for too long.
  static const _peerGoneGracePeriod = Duration(seconds: 8);

  @override
  Stream<void> get onPeerGone => _peerGoneController.stream;

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
    await room.connect(CallConfig.livekitUrl, roomToken);
    _room = room;
    _bindRoomEvents(room);
    debugPrint('✅ [LiveKit] Connected successfully.');
  }

  void _bindRoomEvents(Room room) {
    _roomListener?.dispose();
    final listener = room.createListener();
    _roomListener = listener;

    listener
      ..on<ParticipantDisconnectedEvent>((event) {
        debugPrint(
          '👤 [LiveKit] Remote participant disconnected: '
          '${event.participant.identity} — starting grace period',
        );
        _peerGoneTimer?.cancel();
        _peerGoneTimer = Timer(_peerGoneGracePeriod, () {
          debugPrint(
            '⏰ [LiveKit] Peer did not return within grace period — '
            'treating call as ended.',
          );
          if (!_peerGoneController.isClosed) _peerGoneController.add(null);
        });
      })
      ..on<ParticipantConnectedEvent>((event) {
        // Same peer (or anyone) rejoined — the disconnect was transient.
        // Cancel any pending "peer is gone" timer.
        if (_peerGoneTimer != null) {
          debugPrint(
            '👤 [LiveKit] Participant reconnected before grace period '
            'elapsed — cancelling peer-gone timer.',
          );
        }
        _peerGoneTimer?.cancel();
        _peerGoneTimer = null;
      })
      ..on<RoomDisconnectedEvent>((event) {
        // The whole room went away (server closed it, we lost our own
        // connection, etc.) — no grace period here, there's nothing left to
        // wait on.
        debugPrint('🔌 [LiveKit] Room disconnected: ${event.reason}');
        _peerGoneTimer?.cancel();
        _peerGoneTimer = null;
        if (!_peerGoneController.isClosed) _peerGoneController.add(null);
      });
  }

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      throw StateError('Cannot change microphone before joining a room.');
    }
    await participant.setMicrophoneEnabled(enabled);
    debugPrint('🎤 [LiveKit] Microphone ${enabled ? 'enabled' : 'disabled'}.');
  }

  @override
  Future<void> setCameraEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) {
      throw StateError('Cannot change camera before joining a room.');
    }
    await participant.setCameraEnabled(enabled);
    debugPrint('📷 [LiveKit] Camera ${enabled ? 'enabled' : 'disabled'}.');
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
    _peerGoneTimer?.cancel();
    _peerGoneTimer = null;
    await _roomListener?.dispose();
    _roomListener = null;

    final room = _room;
    if (room == null) return;
    debugPrint('🔌 [LiveKit] Disconnecting...');
    await room.disconnect();
    _room = null;
    debugPrint('✅ [LiveKit] Disconnected.');
  }

  /// Call once, when the service itself is being torn down for good (app
  /// shutdown) — not per-call. Closing the controller mid-call would break
  /// the next call's subscription.
  Future<void> dispose() async {
    await disconnect();
    await _peerGoneController.close();
  }
}
