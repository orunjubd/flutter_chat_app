import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';

enum GroupCallOutcome { joined, missed, declined }

class GroupCallHistoryEntry {
  const GroupCallHistoryEntry({
    required this.callId,
    required this.type,
    required this.outcome,
    required this.startedAt,
    required this.participantNames,
    this.durationSeconds,
    this.callerName,
    this.conversationId, // filled later by the group-chat feature
  });

  final String callId;
  final CallType type;
  final GroupCallOutcome outcome;
  final Timestamp startedAt;
  final List<String> participantNames;
  final int? durationSeconds;
  final String? callerName;
  final String? conversationId;

  factory GroupCallHistoryEntry.fromMap(String id, Map<String, dynamic> d) =>
      GroupCallHistoryEntry(
        callId: id,
        type: CallType.values.firstWhere(
          (t) => t.name == d['type'],
          orElse: () => CallType.video,
        ),
        outcome: GroupCallOutcome.values.firstWhere(
          (o) => o.name == d['outcome'],
          orElse: () => GroupCallOutcome.missed,
        ),
        startedAt: d['startedAt'] as Timestamp? ?? Timestamp.now(),
        participantNames: List<String>.from(d['participantNames'] ?? const []),
        durationSeconds: (d['durationSeconds'] as num?)?.toInt(),
        callerName: d['callerName'] as String?,
        conversationId: d['conversationId'] as String?,
      );
}
