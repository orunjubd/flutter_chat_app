import 'package:flutter/material.dart';
import 'package:chat_app/features/calls/core/models/room_participant_view.dart';
import 'group_video_tile.dart';

class GroupVideoGrid extends StatelessWidget {
  const GroupVideoGrid({
    super.key,
    required this.participants,
    required this.nameOf,
    required this.onTapParticipant,
  });
  final List<RoomParticipantView> participants;
  final String Function(String uid) nameOf;
  final void Function(String uid) onTapParticipant;

  @override
  Widget build(BuildContext context) {
    final cols = participants.length <= 1 ? 1 : 2;
    final rows = <List<RoomParticipantView>>[];
    for (var i = 0; i < participants.length; i += cols) {
      rows.add(
        participants.sublist(i, (i + cols).clamp(0, participants.length)),
      );
    }
    return Column(
      children: [
        for (final row in rows)
          Expanded(
            child: Row(
              children: [
                for (final p in row)
                  Expanded(
                    child: GroupVideoTile(
                      participant: p,
                      displayName: nameOf(p.identity),
                      onTap: () => onTapParticipant(p.identity),
                    ),
                  ),
                for (var i = row.length; i < cols; i++) const Spacer(),
              ],
            ),
          ),
      ],
    );
  }
}
