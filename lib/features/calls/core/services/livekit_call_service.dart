// features/call/services/livekit_call_service.dart
import 'dart:async';

import 'package:chat_app/features/calls/core/models/call_video_tracks.dart';
import 'package:chat_app/features/calls/core/models/room_participant_view.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:chat_app/core/config/call_config.dart';
import 'package:chat_app/features/calls/core/services/call_service.dart';

@override
class LiveKitCallService implements CallService {
  Room? _room;
  EventsListener<RoomEvent>? _roomListener;
  @override
  bool groupMode = false; // in a group call one person leaving must NOT end the call

  Timer? _peerGoneTimer;
  final _peerGoneController = StreamController<void>.broadcast();
  final _reconnectingController = StreamController<void>.broadcast();
  final _reconnectedController = StreamController<void>.broadcast();
  final _videoTracksController = StreamController<CallVideoTracks>.broadcast();
  bool _frontCamera = true;

  final _participantsController =
      StreamController<List<RoomParticipantView>>.broadcast();

  @override
  Stream<List<RoomParticipantView>> get onParticipantsChanged =>
      _participantsController.stream;

  @override
  List<RoomParticipantView> get participants {
    final room = _room;
    if (room == null) return const [];

    RoomParticipantView view(Participant p, {required bool local}) {
      VideoTrack? video;
      for (final pub in p.videoTrackPublications) {
        final t = pub.track;
        if (t is VideoTrack && // also covers null
            !pub.muted &&
            (local || pub.subscribed) &&
            pub.source != TrackSource.screenShareVideo) {
          video = t;
          break;
        }
      }
      final muted =
          p.audioTrackPublications.isEmpty ||
          p.audioTrackPublications.every((a) => a.muted);
      return RoomParticipantView(
        identity: p.identity,
        name: p.name.isNotEmpty ? p.name : p.identity,
        video: video,
        isMuted: muted,
        isSpeaking: p.isSpeaking,
        isLocal: local,
      );
    }

    final me = room.localParticipant;
    return [
      if (me != null) view(me, local: true),
      for (final p in room.remoteParticipants.values) view(p, local: false),
    ];
  }

  void _emitParticipants() {
    if (!_participantsController.isClosed) {
      _participantsController.add(participants);
    }
  }

  @override
  Stream<CallVideoTracks> get onVideoTracksChanged =>
      _videoTracksController.stream;

  @override
  CallVideoTracks get videoTracks {
    final room = _room;
    if (room == null) return const CallVideoTracks();
    VideoTrack? local;
    final lp = room.localParticipant;
    if (lp != null) {
      for (final pub in lp.videoTrackPublications) {
        final t = pub.track;
        if (t != null && !pub.muted) {
          local = t;
          break;
        }
      }
    }
    VideoTrack? remote;
    for (final p in room.remoteParticipants.values) {
      for (final pub in p.videoTrackPublications) {
        final t = pub.track;
        if (t != null && pub.subscribed && !pub.muted) {
          remote = t;
          break;
        }
      }
      if (remote != null) break;
    }
    return CallVideoTracks(local: local, remote: remote);
  }

  void _emitTracks() {
    if (!_videoTracksController.isClosed) {
      _videoTracksController.add(videoTracks);
    }
    _emitParticipants();
  }

  @override
  Future<void> switchCamera() async {
    final lp = _room?.localParticipant;
    if (lp == null) return;
    for (final pub in lp.videoTrackPublications) {
      final track = pub.track;
      if (track == null) continue;
      try {
        _frontCamera = !_frontCamera;
        await track.setCameraPosition(
          _frontCamera ? CameraPosition.front : CameraPosition.back,
        );
        debugPrint('📷 [LiveKit] camera → ${_frontCamera ? "front" : "back"}');
      } catch (e) {
        _frontCamera = !_frontCamera; // revert
        debugPrint('❌ [LiveKit] switchCamera failed: $e');
      }
      break;
    }
    _emitTracks();
  }

  // How long to wait after the peer disconnects before treating the call as
  // actually over. Long enough to ride out a brief network blip / LiveKit's
  // own reconnect attempt; short enough that a genuinely-gone peer (sign-out,
  // crash, force-quit) doesn't leave the other side hanging for too long.
  static const _peerGoneGracePeriod = Duration(seconds: 8);

  @override
  Stream<void> get onPeerGone => _peerGoneController.stream;
  @override
  Stream<void> get onRoomReconnecting => _reconnectingController.stream;

  @override
  Stream<void> get onRoomReconnected => _reconnectedController.stream;
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
        if (groupMode) {
          _emitParticipants();
          return;
        }
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
        _emitParticipants();
      })
      ..on<RoomDisconnectedEvent>((event) {
        // The whole room went away (server closed it, we lost our own
        // connection, etc.) — no grace period here, there's nothing left to
        // wait on.
        debugPrint('🔌 [LiveKit] Room disconnected: ${event.reason}');
        _peerGoneTimer?.cancel();
        _peerGoneTimer = null;
        if (!_peerGoneController.isClosed) _peerGoneController.add(null);
      })
      ..on<RoomReconnectingEvent>((event) {
        debugPrint('🔄 [LiveKit] Reconnecting to room...');
        if (!_reconnectingController.isClosed) {
          _reconnectingController.add(null);
        }
      })
      ..on<RoomReconnectedEvent>((event) {
        debugPrint('✅ [LiveKit] Reconnected to room.');
        if (!_reconnectedController.isClosed) _reconnectedController.add(null);
      })
      ..on<ActiveSpeakersChangedEvent>((_) => _emitParticipants())
      ..on<LocalTrackPublishedEvent>((_) => _emitTracks())
      ..on<LocalTrackUnpublishedEvent>((_) => _emitTracks())
      ..on<TrackSubscribedEvent>((_) => _emitTracks())
      ..on<TrackUnsubscribedEvent>((_) => _emitTracks())
      ..on<TrackMutedEvent>((_) => _emitTracks())
      ..on<TrackUnmutedEvent>((_) => _emitTracks());
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
    _emitTracks();
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
    _emitParticipants();
    _emitTracks();
    debugPrint('✅ [LiveKit] Disconnected.');
  }

  /// Call once, when the service itself is being torn down for good (app
  /// shutdown) — not per-call. Closing the controller mid-call would break
  /// the next call's subscription.
  Future<void> dispose() async {
    await disconnect();
    await _participantsController.close();
    await _peerGoneController.close();
    await _reconnectingController.close();
    await _reconnectedController.close();
    await _videoTracksController.close();
  }
}
