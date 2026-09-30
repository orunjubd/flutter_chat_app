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
//import 'package:chat_app/features/calls/core/models/call_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/calls/core/models/call_phase.dart';
import 'package:chat_app/features/calls/voice_calls/widgets/voice_call_controls.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart'; // callProvider
import 'package:chat_app/features/calls/core/models/call_state.dart'; // CallState

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.peerAvatarUrl,
    required this.isOutgoing,
  });

  final String peerId;
  final String peerName;
  final String? peerAvatarUrl;
  final bool isOutgoing;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _outgoingCallStarted = false;
  bool _popped = false;
  //bool _actionTaken = false; // guards Accept/Decline against a double tap

  Timer? _durationTimer;
  Duration _duration = Duration.zero;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
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

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? '${d.inHours}:$m:$s' : '$m:$s';
  }

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
    ref.listen<CallUiState>(callProvider, (previous, next) {
      if (next.phase == CallState.connected) {
        _startDurationTimerIfNeeded();
      }
      final wasActive = previous != null && previous.phase != CallState.idle;
      final shouldPop =
          next.phase.isTerminal || (wasActive && next.phase == CallState.idle);
      // if (shouldPop) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) => _popOnce());
      // }
      if (shouldPop) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _popOnce());
      }
    });

    final callState = ref.watch(callProvider);
    final phase = callState.phase;
    final controlsEnabled =
        phase == CallState.connected || phase == CallState.reconnecting;
    // Native CallKit owns the incoming-call UI.
    // Keep this Flutter route alive, but render nothing underneath it.
    // if (callState.nativeUiVisible &&
    //     !widget.isOutgoing &&
    //     phase == CallState.ringing) {
    //   return const SizedBox.shrink();
    // }
    // // Incoming, not yet answered: Accept/Decline instead of Mute/Speaker/End.
    // // callId/roomName come off watched state, not a constructor param —
    // // this screen was pushed by GlobalIncomingCallListener the instant the
    // // call started ringing, using exactly this same incomingCall session.
    // final isAwaitingAnswer = !widget.isOutgoing && phase == CallState.ringing;
    // final incoming = callState.incomingCall;

    return PopScope(
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
                _statusLabel(phase, callState.errorMessage),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: (0.7)),
                  fontSize: 16,
                ),
              ),
              const Spacer(flex: 3),
              VoiceCallControls(
                controlsEnabled: controlsEnabled,
                onEndCall: () =>
                    ref.read(callProvider.notifier).endCurrentCall(),
                onToggleMute: controlsEnabled
                    ? () => ref.read(callProvider.notifier).toggleMic()
                    : null,
                onToggleSpeaker: controlsEnabled
                    ? () => ref.read(callProvider.notifier).toggleSpeaker()
                    : null,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(CallState phase, String? errorMessage) {
    switch (phase) {
      case CallState.idle:
        return '';
      case CallState.dialing:
        return 'Calling…';
      case CallState.ringing:
        return widget.isOutgoing ? 'Ringing…' : 'Incoming call…';
      case CallState.connecting:
        return 'Connecting…';
      case CallState.connected:
        return _formatDuration(_duration);
      case CallState.reconnecting:
        return 'Reconnecting…';
      case CallState.failed:
        return errorMessage ?? 'Call failed';
      case CallState.ended:
        return 'Call ended';
      case CallState.rejected:
        return 'Call declined';
      case CallState.cancelled:
        return 'Call cancelled';
      case CallState.missed:
        return 'No answer';
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
