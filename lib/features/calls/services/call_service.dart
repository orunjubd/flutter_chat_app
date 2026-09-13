import 'package:livekit_client/livekit_client.dart';

// features/calls/services/call_service.dart
/// Common contract for all RTC providers. Swapping LiveKit for
/// Agora/self-hosted later means writing one new class here and
/// changing one line in the provider — nothing else in the app
/// (UI, call state, Firestore signaling) needs to change.
abstract class CallService {
  Room? get room;
  Future<void> connect({required String roomToken});
  Future<void> setMicrophoneEnabled(bool enabled);
  Future<void> setCameraEnabled(bool enabled);
  //Future<void> switchCamera();
  Future<void> disconnect();
  // Use EventsListener<RoomEvent> instead of RoomListener
  //void addListener(EventsListener<RoomEvent> listener);
  //void removeListener(EventsListener<RoomEvent> listener);
}
