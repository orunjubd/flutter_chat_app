import 'package:flutter/material.dart';
import 'package:chat_app/features/calls/core/models/room_participant_view.dart';
import 'group_video_tile.dart';

class GroupVideoSpotlight extends StatelessWidget {
  const GroupVideoSpotlight({
    super.key,
    required this.main,
    required this.others,
    required this.nameOf,
    required this.onTapParticipant,
    required this.onUnpin,
  });
  final RoomParticipantView main;
  final List<RoomParticipantView> others;
  final String Function(String uid) nameOf;
  final void Function(String uid) onTapParticipant;
  final VoidCallback onUnpin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GroupVideoTile(
            participant: main,
            displayName: nameOf(main.identity),
            onTap: onUnpin,
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final p in others)
                SizedBox(
                  width: 86,
                  child: GroupVideoTile(
                    participant: p,
                    displayName: nameOf(p.identity),
                    onTap: () => onTapParticipant(p.identity),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
