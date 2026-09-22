//import 'package:livekit_client/livekit_client.dart';

// features/calls/services/call_service.dart
/// Common contract for all RTC providers. Swapping LiveKit for
/// Agora/self-hosted later means writing one new class here and
/// changing one line in the provider — nothing else in the app
/// (UI, call state, Firestore signaling) needs to change.
abstract class CallService {
  //Room? get room;   // comment this out to avoid exposing the Room object to the UI layer
  Future<void> connect({required String roomToken});
  Future<void> setMicrophoneEnabled(bool enabled);
  Future<void> setCameraEnabled(bool enabled);
  Future<void> setSpeakerphoneEnabled(bool enabled); // NEW
  //Future<void> switchCamera();
  Future<void> disconnect();
  // Use EventsListener<RoomEvent> instead of RoomListener
  //void addListener(EventsListener<RoomEvent> listener);
  //void removeListener(EventsListener<RoomEvent> listener);

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
}
