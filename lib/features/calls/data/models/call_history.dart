import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/features/calls/data/models/call_type.dart';
import 'package:chat_app/features/calls/data/models/call_state.dart'
    as call_model;

enum CallHistoryStatus { completed, missed, rejected, cancelled, failed }

class CallHistory {
  const CallHistory({
    required this.id,
    required this.callId,
    required this.callerId,
    required this.calleeId,
    required this.type,
    required this.status,
    required this.startedAt,
    this.connectedAt,
    this.endedAt,
    this.duration,
  });

  final String id;

  /// Reference to the original CallSession.
  final String callId;

  /// User who initiated the call.
  final String callerId;

  /// User who received the call.
  final String calleeId;

  /// Voice or video.
  final CallType type;

  /// Final result of the call.
  final CallHistoryStatus status;

  /// When the call was initiated.
  final Timestamp startedAt;

  /// When both participants became connected.
  final Timestamp? connectedAt;

  /// When the call ended.
  final Timestamp? endedAt;

  /// Duration of the connected call.
  final Duration? duration;

  // =======================================================================
  // ⚡ ECE STANDARD: UNIFIED INDUSTRIAL DATA MAPPER FACTORY
  // =======================================================================
  // ✅ REQUIREMENT MET: Maps terminal firestore call states straight into history statuses natively!
  static CallHistoryStatus fromCallState(call_model.CallState state) {
    return switch (state) {
      call_model.CallState.ended => CallHistoryStatus.completed,
      call_model.CallState.missed => CallHistoryStatus.missed,
      call_model.CallState.rejected => CallHistoryStatus.rejected,
      call_model.CallState.cancelled => CallHistoryStatus.cancelled,
      call_model.CallState.failed => CallHistoryStatus.failed,
      _ =>
        CallHistoryStatus
            .failed, // Fallback guard safely intercepts non-terminal states
    };
  }
}
