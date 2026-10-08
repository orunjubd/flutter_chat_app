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
import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/calls/core/models/call_session.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/widgets/incoming_call_card.dart';
import 'package:chat_app/features/calls/video_calls/widgets/video_call_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/calls/core/models/call_phase.dart';
import 'package:chat_app/features/calls/voice_calls/widgets/voice_call_controls.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart'; // callProvider
import 'package:chat_app/features/calls/core/models/call_state.dart'; // CallState
import 'package:chat_app/features/calls/core/constants/call_strings.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.peerAvatarUrl,
    required this.isOutgoing,
    this.type = CallType.voice,
  });
  final String peerId;
  final String peerName;
  final String? peerAvatarUrl;
  final bool isOutgoing;
  final CallType type;

  static int instances = 0;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _outgoingCallStarted = false;
  bool _popped = false;
  bool _actionTaken = false;
  Timer? _durationTimer;
  Duration _duration = Duration.zero;
  bool _timerRunning = false;

  bool get _isVideo => widget.type == CallType.video;

  @override
  void initState() {
    // debugPrint('⏱️ CallScreen init ${DateTime.now()}');
    super.initState();
    CallScreen.instances++;
    if (widget.isOutgoing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _outgoingCallStarted) return;
        _outgoingCallStarted = true;
        final call = ref.read(callProvider.notifier);
        if (_isVideo) {
          call.startVideoCall(calleeId: widget.peerId);
        } else {
          call.startVoiceCall(calleeId: widget.peerId);
        }
      });
    }
  }

  @override
  void dispose() {
    CallScreen.instances--;
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

  void _accept(CallSession? incoming) {
    if (_actionTaken || incoming == null) return;
    setState(() => _actionTaken = true);
    ref
        .read(callProvider.notifier)
        .acceptCall(
          callId: incoming.id,
          roomName: incoming.roomName,
          type: incoming.type,
        );
  }

  void _decline(CallSession? incoming) {
    if (_actionTaken || incoming == null) return;
    setState(() => _actionTaken = true);
    ref.read(callProvider.notifier).rejectCall(callId: incoming.id);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CallUiState>(callProvider, (previous, next) {
      if (next.phase == CallState.connected) _startDurationTimerIfNeeded();
      final wasActive = previous != null && previous.phase != CallState.idle;
      final shouldPop =
          next.phase.isTerminal || (wasActive && next.phase == CallState.idle);
      // if (shouldPop) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) => _popOnce());
      // }
      if (shouldPop) {
        final delay = next.errorMessage == CallStrings.busy
            ? const Duration(
                seconds: 4,
              ) // Busy message is too quick to read, so give it a moment
            : Duration.zero;
        Future.delayed(delay, _popOnce);
      }
    });

    final callState = ref.watch(callProvider);
    final incoming = callState.incomingCall;
    final isAwaitingAnswer =
        !widget.isOutgoing && callState.phase == CallState.ringing;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isAwaitingAnswer) {
          _decline(incoming);
        } else {
          ref.read(callProvider.notifier).endCurrentCall();
        }
      },
      child: isAwaitingAnswer
          ? IncomingCallCard(
              title: _isVideo
                  ? CallStrings.incomingVideo
                  : CallStrings.incomingVoice,
              icon: _isVideo ? Icons.videocam : Icons.phone_in_talk,
              callerName: incoming?.callerName ?? widget.peerName,
              actionsEnabled: !_actionTaken && incoming != null,
              onAccept: () => _accept(incoming),
              onDecline: () => _decline(incoming),
            )
          : _buildFullScreen(context, callState),
    );
  }

  Widget _buildFullScreen(BuildContext context, CallUiState callState) {
    final phase = callState.phase;
    final controlsEnabled =
        phase == CallState.connected || phase == CallState.reconnecting;
    final label = _statusLabel(
      phase,
      callState.errorMessage,
      callState.activeCall,
    );
    final call = ref.read(callProvider.notifier);

    if (_isVideo) {
      return VideoCallView(
        peerName: widget.peerName,
        peerAvatarUrl: widget.peerAvatarUrl,
        statusLabel: label,
        controlsEnabled: controlsEnabled,
        micEnabled: callState.micEnabled,
        cameraEnabled: callState.cameraEnabled,
        speakerOn: callState.speakerOn,
        onToggleMute: call.toggleMic,
        onToggleCamera: call.toggleCamera,
        onSwitchCamera: call.switchCamera,
        onToggleSpeaker: call.toggleSpeaker,
        onEndCall: call.endCurrentCall,
      );
    }

    return Scaffold(
      backgroundColor: context.callScreenBackground,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            _PeerAvatar(name: widget.peerName, avatarUrl: widget.peerAvatarUrl),
            const SizedBox(height: 24),
            Text(
              widget.peerName,
              style: TextStyle(
                color: context.theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: context.theme.colorScheme.onSurface.withValues(
                  alpha: 0.7,
                ),
                fontSize: 16,
              ),
            ),
            const Spacer(flex: 3),
            VoiceCallControls(
              controlsEnabled: controlsEnabled,
              onEndCall: () => call.endCurrentCall(),
              onToggleMute: controlsEnabled ? () => call.toggleMic() : null,
              onToggleSpeaker: controlsEnabled
                  ? () => call.toggleSpeaker()
                  : null,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _statusLabel(
    CallState phase,
    String? errorMessage,
    CallSession? activeCall,
  ) {
    switch (phase) {
      case CallState.idle:
        return '';
      case CallState.dialing:
        return CallStrings.calling;
      case CallState.ringing:
        if (!widget.isOutgoing) return CallStrings.incomingCall;
        return activeCall?.calleeRingingAt != null
            ? CallStrings.ringing
            : CallStrings.calling;
      case CallState.connecting:
        return CallStrings.connecting;
      case CallState.connected:
        return _formatDuration(_duration);
      case CallState.reconnecting:
        return CallStrings.reconnecting;
      case CallState.failed:
        return errorMessage ?? CallStrings.callFailed;
      case CallState.ended:
        return CallStrings.callEnded;
      // case CallState.rejected:
      //   return CallStrings.callDeclined;
      case CallState.cancelled:
        return CallStrings.callCancelled;
      case CallState.missed:
        return CallStrings.noAnswer;
      case CallState.rejected:
        return errorMessage ?? CallStrings.callDeclined;
    }
  }
}

class _PeerAvatar extends StatelessWidget {
  const _PeerAvatar({required this.name, this.avatarUrl});
  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 56,
      backgroundColor: context.theme.colorScheme.onSurface.withValues(
        alpha: 0.24,
      ),
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
      child: hasAvatar
          ? null
          : Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 40),
            ),
    );
  }
}
