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
        ),
      ],
    );
  }
}

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
