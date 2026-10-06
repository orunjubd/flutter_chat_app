import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_type.dart';
import 'participant_status.dart';

class GroupCallSession {
  const GroupCallSession({
    required this.id,
    this.conversationId, // null for ad-hoc group calls
    required this.roomName,
    required this.callerId,
    required this.type,
    required this.participantIds,
    required this.statuses,
    required this.names,
    required this.isEnded,
    required this.createdAt,
    this.callerName,
  });

  final String id;
  final String? conversationId;
  final String roomName;
  final String callerId;
  final String? callerName;
  final CallType type;
  final List<String> participantIds;
  final Map<String, ParticipantStatus> statuses;
  final Map<String, String> names;
  final bool isEnded;
  final Timestamp createdAt;

  String nameOf(String uid) => names[uid] ?? uid;

  GroupCallSession.fromMap(String id, Map<String, dynamic> d)
    : this(
        id: id,
        conversationId: d['conversationId'] as String?,
        roomName: d['roomName'] as String,
        callerId: d['callerId'] as String,
        callerName: d['callerName'] as String?,
        type: CallType.values.firstWhere((t) => t.name == d['type']),
        participantIds: List<String>.from(d['participantIds'] as List),
        statuses: (d['statuses'] as Map).map(
          (k, v) =>
              MapEntry(k as String, ParticipantStatusX.parse(v as String?)),
        ),
        names: Map<String, String>.from((d['names'] as Map?) ?? const {}),
        isEnded: d['state'] == 'ended',
        createdAt: d['createdAt'] as Timestamp,
      );
}
