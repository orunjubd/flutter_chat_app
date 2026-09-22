// features/calls/ui/call_screen.dart
//
// ONE screen for the entire call lifecycle — replaces the old pair of
// OutgoingCallScreen + CallScreen. Outgoing is a STATE this screen renders,
// not a separate destination: push it exactly once (caller: right when the
// call starts; callee: right after they accept), never again for that call.
//
// Control-enablement rule, applied uniformly so a future button (video
// toggle, add-call, etc.) doesn't need its own bespoke logic:
//
//   controlsEnabled = status == CallConnectionStatus.connected
//
// "End call" is the one exception — it's always live, at every status,
// because CallNotifier.endCurrentCall() already knows how to pick
// `cancelled` vs `ended` for you. The screen never has to ask "are we still
// just ringing?" before deciding what pressing End should do.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/call_provider.dart'; // callProvider, CallState, CallConnectionStatus

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.peerAvatarUrl,
    required this.isOutgoing,
    this.onLongPress,
  });

  /// The other participant — caller sees the callee's info and vice versa.
  final String peerId;
  final String peerName;
  final String? peerAvatarUrl;

  final VoidCallback? onLongPress;

  /// True if THIS device is the one that placed the call. Decides whether
  /// this screen kicks off startVoiceCall itself on first frame, or just
  /// renders a call that's already being accepted elsewhere.
  final bool isOutgoing;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _outgoingCallStarted = false;
  bool _popped = false;

  Timer? _durationTimer;
  Duration _duration = Duration.zero;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    // Kick off the call on the very next frame, not in initState directly —
    // starting an async provider action mid-build is asking for trouble.
    if (widget.isOutgoing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _outgoingCallStarted) return;
        _outgoingCallStarted = true;
        ref.read(callProvider.notifier).startVoiceCall(calleeId: widget.peerId);
      });
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  void _startDurationTimerIfNeeded() {
    if (_timerRunning) return;
    _timerRunning = true;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _duration += const Duration(seconds: 1));
    });
  }

  // Client-side clock, not server connectedAt — CallConnectionStatus doesn't
  // carry the underlying CallSession, so this is "close enough for display,"
  // not what you'd want for billing or call history duration.
  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

  /// Pop exactly once, defensively — guards against the call ending twice in
  /// quick succession (e.g. a Firestore snapshot AND a local disconnect both
  /// landing) trying to pop an already-popped route.
  void _popOnce() {
    if (_popped || !mounted) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) return;
    if (!Navigator.of(context).canPop()) return;
    _popped = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen for side effects (pop on terminal status); ref.watch below
    // for what actually gets rendered. Keeping side effects out of build's
    // main body avoids "setState during build" class of bugs.
    ref.listen<CallUiState>(callProvider, (previous, next) {
      // =======================================================================
      // 🛡️ 1. CENTRAL TERMINAL STATE GUARD CHANNELS (PLACE AT THE VERY TOP)
      // =======================================================================

      final wasActive =
          previous != null && previous.status != CallConnectionStatus.idle;
      final shouldPop =
          next.status == CallConnectionStatus.ended ||
          next.status == CallConnectionStatus.failed ||
          (wasActive && next.status == CallConnectionStatus.idle);
      if (shouldPop) {
        // Future.delayed(const Duration(milliseconds: 900), _popOnce); // hold the pop for a short,900ms roughly; user sees the "Call ended" label flash briefly before the screen disappears. UX nicety, not load-bearing.
        WidgetsBinding.instance.addPostFrameCallback((_) => _popOnce());
      }
      // =======================================================================
      // ⏱️ 2. ACTIVE HANDSHAKE LIFECYCLE CONTROLS
      // =======================================================================

      if (next.status == CallConnectionStatus.connected) {
        _startDurationTimerIfNeeded();
      }
      // if (next.status == CallConnectionStatus.ended ||
      //     next.status == CallConnectionStatus.failed) {
      //   // Let the terminal UI (see _statusLabel) flash briefly rather than
      //   // popping mid-frame — small UX nicety, not load-bearing.
      //   WidgetsBinding.instance.addPostFrameCallback((_) => _popOnce());
      // }
    });

    final callState = ref.watch(callProvider);
    final status = callState.status;
    final controlsEnabled = status == CallConnectionStatus.connected;

    return PopScope(
      // Swallow the system back gesture — leaving a call needs to go
      // through endCurrentCall(), not a bare pop, or the call keeps running
      // with no screen driving it.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ref.read(callProvider.notifier).endCurrentCall();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _PeerAvatar(
                name: widget.peerName,
                avatarUrl: widget.peerAvatarUrl,
              ),
              const SizedBox(height: 24),
              Text(
                widget.peerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _statusLabel(status, callState.errorMessage),
                style: TextStyle(
                  color: Colors.white..withValues(alpha: (0.7)),
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 3),
              _Controls(
                controlsEnabled: controlsEnabled,
                onEndCall: () =>
                    ref.read(callProvider.notifier).endCurrentCall(),

                // =======================================================================
                // 🧪 TEST AUTOMATION GAUGE LAYER (MID-CALL AUTOMATED LOGOUT)
                // =======================================================================
                // ✅ REQUIREMENT MET: Safely injects the sign-out trigger directly into the view layout parameters!
                onLongPress: () async {
                  debugPrint('🧪 LONG PRESS → Signing out...');
                  await FirebaseAuth.instance.signOut();
                  debugPrint('🧪 LONG PRESS → Sign-out completed.');
                },
                // Wire these to real toggle state once mic/speaker booleans
                // are exposed on CallNotifier the same way _speakerOn is —
                // right now they're fire-and-forget calls with no read-back.
                // call_screen.dart — read current state, flip it
                onToggleMute: controlsEnabled
                    ? () => ref
                          .read(callProvider.notifier)
                          .setMicrophoneEnabled(
                            !ref.read(callProvider.notifier).micEnabled,
                          )
                    : null,
                onToggleSpeaker: controlsEnabled
                    ? () => ref
                          .read(callProvider.notifier)
                          .setSpeakerphoneEnabled(
                            !ref.read(callProvider.notifier).speakerOn,
                          )
                    : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(CallConnectionStatus status, String? errorMessage) {
    switch (status) {
      case CallConnectionStatus.idle:
        return '';
      case CallConnectionStatus.ringing:
        return widget.isOutgoing ? 'Ringing…' : 'Incoming call…';
      case CallConnectionStatus.connecting:
        return 'Connecting…';
      case CallConnectionStatus.connected:
        return _formatDuration(_duration);
      case CallConnectionStatus.failed:
        return errorMessage ?? 'Call failed';
      case CallConnectionStatus.ended:
        return 'Call ended';
    }
  }
}

class _PeerAvatar extends StatelessWidget {
  const _PeerAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 56,
      backgroundColor: Colors.white24,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 40),
            )
          : null,
    );
  }
}

/// Every control besides End Call shares one enabled/disabled switch. Adding
/// a new button later (video toggle, add participant, etc.) means adding one
/// more _ControlButton here with the same `controlsEnabled` — never its own
/// bespoke readiness check.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.controlsEnabled,
    required this.onEndCall,
    required this.onToggleMute,
    required this.onToggleSpeaker,
    this.onLongPress,
  });

  final bool controlsEnabled;
  final VoidCallback onEndCall;
  final VoidCallback? onToggleMute;
  final VoidCallback? onToggleSpeaker;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: Icons.mic_off,
          label: 'Mute',
          onPressed: onToggleMute,
        ),
        _EndCallButton(onPressed: onEndCall, onLongPress: onLongPress),
        _ControlButton(
          icon: Icons.volume_up,
          label: 'Speaker',
          onPressed: onToggleSpeaker,
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Column(
      children: [
        IconButton(
          iconSize: 32,
          color: enabled ? Colors.white : Colors.white24,
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white70 : Colors.white24,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EndCallButton extends StatelessWidget {
  const _EndCallButton({required this.onPressed, this.onLongPress});

  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        onLongPress: onLongPress,
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Icon(Icons.call_end, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
