import 'package:chat_app/core/extensions/theme_extensions.dart';
import 'package:chat_app/features/calls/core/constants/call_strings.dart';
import 'package:flutter/material.dart';

class VideoCallControls extends StatelessWidget {
  const VideoCallControls({
    super.key,
    required this.controlsEnabled,
    required this.micEnabled,
    required this.cameraEnabled,
    required this.speakerOn,
    required this.onToggleMute,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onToggleSpeaker,
    required this.onEndCall,
  });
  final bool controlsEnabled, micEnabled, cameraEnabled, speakerOn;
  final VoidCallback onToggleMute,
      onToggleCamera,
      onSwitchCamera,
      onToggleSpeaker,
      onEndCall;

  @override
  Widget build(BuildContext context) {
    VoidCallback? gated(VoidCallback f) => controlsEnabled ? f : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Btn(
          icon: micEnabled ? Icons.mic : Icons.mic_off,
          label: CallStrings.mute,
          onPressed: gated(onToggleMute),
        ),
        _Btn(
          icon: cameraEnabled ? Icons.videocam : Icons.videocam_off,
          label: CallStrings.camera,
          onPressed: gated(onToggleCamera),
        ),
        _Btn(
          icon: Icons.cameraswitch,
          label: CallStrings.flip,
          onPressed: cameraEnabled ? gated(onSwitchCamera) : null,
        ),
        _Btn(
          icon: speakerOn ? Icons.volume_up : Icons.hearing,
          label: CallStrings.speaker,
          onPressed: gated(onToggleSpeaker),
        ),
        Material(
          color: context.callDeclineColor,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onEndCall,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.call_end, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final on = onPressed != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          iconSize: 28,
          color: on
              ? context.theme.colorScheme.onSurface
              : context.theme.colorScheme.onSurface.withValues(alpha: 0.24),
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: on
                ? context.theme.colorScheme.onSurface
                : context.theme.colorScheme.onSurface.withValues(alpha: 0.24),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
