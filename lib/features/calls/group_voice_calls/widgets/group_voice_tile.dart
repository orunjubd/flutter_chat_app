import 'package:chat_app/features/calls/group_voice_calls/widgets/sine_wave.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/features/calls/core/models/room_participant_view.dart';

class GroupVoiceTile extends StatelessWidget {
  const GroupVoiceTile({
    super.key,
    required this.participant,
    required this.displayName,
  });
  final RoomParticipantView participant;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: participant.isSpeaking
            ? Border.all(color: AppColors.online, width: 3)
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white24,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          participant.isLocal
                              ? '$displayName (You)'
                              : displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      if (participant.isSpeaking && !participant.isMuted) ...[
                        const SizedBox(width: 6),

                        SizedBox(
                          width: 28,
                          height: 18,
                          child: SineWave(
                            active: true,
                            color: AppColors.online,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (participant.isMuted)
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.mic_off, color: Colors.white70, size: 18),
            ),
        ],
      ),
    );
  }
}
