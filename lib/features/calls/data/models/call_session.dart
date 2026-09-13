// features/calls/data/models/call_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'call_type.dart';
import 'call_direction.dart';
import 'call_state.dart';

class CallSession {
  const CallSession({
    required this.id,
    required this.conversationId,
    required this.roomName,
    required this.callerId,
    required this.calleeId,
    required this.type,
    required this.direction,
    required this.state,
    required this.createdAt,
    this.connectedAt,
    this.endedAt,
  });

  final String id;
  final String conversationId;
  final String roomName;
  final String callerId;
  final String calleeId;
  final CallType type;
  final CallDirection direction;
  final CallState state;
  final Timestamp createdAt;
  final Timestamp? connectedAt;
  final Timestamp? endedAt;

  CallSession.fromMap(String id, Map<String, dynamic> data)
    : this(
        id: id,
        conversationId: data['conversationId'] as String,
        roomName: data['roomName'] as String,
        callerId: data['callerId'] as String,
        calleeId: data['calleeId'] as String,
        type: CallType.values.firstWhere((t) => t.name == data['type']),
        direction: CallDirection.values.firstWhere(
          (d) => d.name == data['direction'],
        ),
        state: CallState.values.firstWhere((s) => s.name == data['state']),
        createdAt: data['createdAt'] as Timestamp,
        connectedAt: data['connectedAt'] as Timestamp?,
        endedAt: data['endedAt'] as Timestamp?,
      );

  Duration? get duration {
    if (connectedAt == null || endedAt == null) return null;
    return endedAt!.toDate().difference(connectedAt!.toDate());
  }
}
