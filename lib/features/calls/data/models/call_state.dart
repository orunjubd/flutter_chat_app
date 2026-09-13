// features/calls/data/models/call_state.dart
enum CallState {
  idle,
  dialing,
  ringing,
  connecting,
  connected,
  ended, // now means ONLY: was connected, then hung up normally
  rejected, // NEW: receiver actively declined
  cancelled, // NEW: caller hung up before receiver answered
  failed,
  missed, // ring timeout, unchanged
}
