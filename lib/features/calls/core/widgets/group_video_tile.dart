import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart'
    show VideoTrackRenderer, VideoViewFit;
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/features/calls/core/models/room_participant_view.dart';

class GroupVideoTile extends StatelessWidget {
  const GroupVideoTile({
    super.key,
    required this.participant,
    required this.displayName,
    this.onTap,
  });
  final RoomParticipantView participant;
  final String displayName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final video = participant.video;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(10),
          border: participant.isSpeaking
              ? Border.all(color: AppColors.online, width: 3)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (video != null)
              VideoTrackRenderer(video, fit: VideoViewFit.cover)
            else
              Center(
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
              ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 6,
              child: Row(
                children: [
                  if (participant.isMuted)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(Icons.mic_off, color: Colors.white, size: 14),
                    ),
                  Expanded(
                    child: Text(
                      participant.isLocal ? '$displayName (You)' : displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
