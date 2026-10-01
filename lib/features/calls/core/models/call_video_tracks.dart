import 'package:livekit_client/livekit_client.dart' show VideoTrack;

/// The only LiveKit type allowed past CallService: the renderer needs it.
class CallVideoTracks {
  const CallVideoTracks({this.local, this.remote});
  final VideoTrack? local;
  final VideoTrack? remote;
}
