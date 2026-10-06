import 'package:livekit_client/livekit_client.dart' show VideoTrack;

class RoomParticipantView {
  const RoomParticipantView({
    required this.identity,
    required this.name,
    required this.isMuted,
    required this.isSpeaking,
    required this.isLocal,
    this.video,
  });
  final String identity; // Firebase uid
  final String name;
  final bool isMuted;
  final bool isSpeaking;
  final bool isLocal;
  final VideoTrack? video;
}

// class RoomParticipantViewFactory {
//   static RoomParticipantView fromParticipant(Participant participant) => RoomParticipantView(
//         identity: participant.identity,
//         name: participant.identity,
//         isMuted: participant.isMuted,
//         isSpeaking: participant.isSpeaking,
//         isLocal: participant.isLocal,
//         video: participant.videoTracks.firstOrNull,
//       );
// }
