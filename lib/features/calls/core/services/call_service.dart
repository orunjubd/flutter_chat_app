//import 'package:livekit_client/livekit_client.dart';

// features/calls/services/call_service.dart
import 'package:chat_app/features/calls/core/models/call_video_tracks.dart';
import 'package:chat_app/features/calls/core/models/room_participant_view.dart';

/// Common contract for all RTC providers. Swapping LiveKit for
/// Agora/self-hosted later means writing one new class here and
/// changing one line in the provider — nothing else in the app
/// (UI, call state, Firestore signaling) needs to change.
abstract class CallService {
  //Room? get room;   // comment this out to avoid exposing the Room object to the UI layer
  Future<void> connect({required String roomToken});
  Future<void> setMicrophoneEnabled(bool enabled);
  Future<void> setCameraEnabled(bool enabled);
  Future<void> setSpeakerphoneEnabled(bool enabled);
  Future<void> disconnect();
  Future<void> switchCamera();
  CallVideoTracks get videoTracks;
  Stream<CallVideoTracks> get onVideoTracksChanged;

  /// Indicates whether the active session layout operates as a one-to-one call or a group room.
  /// Refactored from a literal value to an abstract getter to maintain safe interface bounds.
  bool get groupMode;

  /// A structured array containing all currently active participants inside the streaming room.
  List<RoomParticipantView> get participants;

  /// Fires real-time state stream updates whenever a participant joins, leaves, or alters media tracks.
  Stream<List<RoomParticipantView>> get onParticipantsChanged;

  /// Fires once when the remote participant is gone and hasn't come back
  /// within a short grace period — NOT on every raw disconnect event, which
  /// also fires on ordinary reconnects. This is what lets a client notice
  /// "the call is actually over" even when the *other* side never manages
  /// to write that to Firestore (sign-out, crash, force-quit, dead network —
  /// anything that stops their client from writing).
  ///
  /// Only meaningful after connect() and before disconnect(); implementers
  /// should treat a stream event here as one-shot per call.
  Stream<void> get onPeerGone;

  /// Fires when THIS client's own connection to the LiveKit server drops and
  /// it starts attempting to reconnect — distinct from onPeerGone, which is
  /// about the OTHER participant leaving. A local network blip on either
  /// side is still something both clients should see reflected in the
  /// shared call state, since the call is degraded either way.
  Stream<void> get onRoomReconnecting;

  /// Fires when a reconnect started via onRoomReconnecting succeeds.
  Stream<void> get onRoomReconnected;
}
