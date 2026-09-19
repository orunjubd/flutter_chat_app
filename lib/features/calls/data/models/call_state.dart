// features/calls/data/models/call_state.dart
enum CallState {
  idle,
  dialing,
  ringing,
  connecting,
  connected,
  reconnecting, // NEW: the call was connected, but the connection dropped and is trying to re-establish
  ended, // now means ONLY: was connected, then hung up normally
  rejected, // NEW: receiver actively declined
  cancelled, // NEW: caller hung up before receiver answered
  failed,
  missed, // ring timeout, unchanged
}

/// Optional, richer "why did it end" detail — additive to CallState, not a
/// replacement. A terminal CallState value (rejected/cancelled/failed/missed/
/// ended) is still enough on its own for audio/UI to react correctly; this
/// enum exists for cases where you want a more specific reason than the
/// state alone carries — e.g. `failed` covers both `busy` and `networkLost`,
/// which you may eventually want to tell apart (different history label,
/// different tone). Nullable everywhere it's used: nothing breaks if you
/// never populate it.
enum CallEndReason {
  hangup, // someone pressed end while connected
  rejected, // callee actively declined
  cancelled, // caller hung up before the callee answered
  missed, // ring timeout expired
  busy, // callee already in another call
  failed, // token/permission/transport error
  networkLost, // reconnect budget exhausted
  answeredElsewhere, // another device of the same user took it
}

extension CallEndReasonX on CallEndReason {
  String get wire => name;

  static CallEndReason? parse(String? value) {
    if (value == null) return null;
    for (final r in CallEndReason.values) {
      if (r.name == value) return r;
    }
    return null;
  }
}
