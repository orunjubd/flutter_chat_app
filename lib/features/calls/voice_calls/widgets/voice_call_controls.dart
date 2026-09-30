// features/calls/voice_calls/widgets/voice_call_controls.dart
//
// Extracted from call_screen.dart — pure UI, no logic change. Every control
// besides End Call shares one enabled/disabled switch (controlsEnabled).
// Adding a new button later (video toggle, add participant, etc.) means
// adding one more _ControlButton here with the same controlsEnabled — never
// its own bespoke readiness check.

import 'package:flutter/material.dart';

class VoiceCallControls extends StatelessWidget {
  const VoiceCallControls({
    super.key,
    required this.controlsEnabled,
    required this.onEndCall,
    required this.onToggleMute,
    required this.onToggleSpeaker,
  });

  final bool controlsEnabled;
  final VoidCallback onEndCall;
  final VoidCallback? onToggleMute;
  final VoidCallback? onToggleSpeaker;

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
        _EndCallButton(onPressed: onEndCall),
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
          //         ),
          //       ],
          //     );
          //   }
          // }

          // /// Shown instead of VoiceCallControls while an incoming call hasn't been
          // /// answered yet — Accept/Decline, not Mute/Speaker/End. Once accepted, the
          // /// screen swaps to VoiceCallControls automatically as `phase` changes.
          // class IncomingCallActions extends StatelessWidget {
          //   const IncomingCallActions({
          //     super.key,
          //     required this.enabled,
          //     required this.onAccept,
          //     required this.onDecline,
          //   });

          //   final bool enabled;
          //   final VoidCallback onAccept;
          //   final VoidCallback onDecline;

          //   @override
          //   Widget build(BuildContext context) {
          //     return Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         _RoundIconButton(
          //           icon: Icons.call_end,
          //           color: Colors.red,
          //           onPressed: enabled ? onDecline : null,
          //         ),
          //         _RoundIconButton(
          //           icon: Icons.call,
          //           color: Colors.green,
          //           onPressed: enabled ? onAccept : null,
        ),
      ],
    );
  }
}

// class _RoundIconButton extends StatelessWidget {
//   const _RoundIconButton({
//     required this.icon,
//     required this.color,
//     required this.onPressed,
//   });

//   final IconData icon;
//   final Color color;
//   final VoidCallback? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     final enabled = onPressed != null;
//     return Material(
//       color: enabled ? color : color.withValues(alpha: 0.4),
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onPressed,
//         child: Padding(
//           padding: const EdgeInsets.all(18),
//           child: Icon(icon, color: Colors.white, size: 32),
//         ),
//       ),
//     );
//   }
// }

class _EndCallButton extends StatelessWidget {
  const _EndCallButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Icon(Icons.call_end, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
