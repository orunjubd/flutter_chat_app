import 'package:chat_app/features/calls/core/models/call_video_tracks.dart';
import 'package:chat_app/features/calls/video_calls/providers/call_video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart'
    show VideoTrackRenderer, VideoViewFit;
import 'video_call_controls.dart';
// + imports for callVideoTracksProvider and CallVideoTracks

class VideoCallView extends ConsumerWidget {
  const VideoCallView({
    super.key,
    required this.peerName,
    this.peerAvatarUrl,
    required this.statusLabel,
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
  final String peerName;
  final String? peerAvatarUrl;
  final String statusLabel;
  final bool controlsEnabled, micEnabled, cameraEnabled, speakerOn;
  final VoidCallback onToggleMute,
      onToggleCamera,
      onSwitchCamera,
      onToggleSpeaker,
      onEndCall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref
        .watch(callVideoTracksProvider)
        .maybeWhen(data: (t) => t, orElse: () => const CallVideoTracks());
    final remote = tracks.remote;
    final local = tracks.local;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (remote != null)
            VideoTrackRenderer(remote, fit: VideoViewFit.cover)
          else
            _Waiting(
              name: peerName,
              avatarUrl: peerAvatarUrl,
              status: statusLabel,
            ),
          if (remote != null)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        peerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        statusLabel,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (local != null)
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 110,
                    height: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: VideoTrackRenderer(local, fit: VideoViewFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: VideoCallControls(
                  controlsEnabled: controlsEnabled,
                  micEnabled: micEnabled,
                  cameraEnabled: cameraEnabled,
                  speakerOn: speakerOn,
                  onToggleMute: onToggleMute,
                  onToggleCamera: onToggleCamera,
                  onSwitchCamera: onSwitchCamera,
                  onToggleSpeaker: onToggleSpeaker,
                  onEndCall: onEndCall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({required this.name, this.avatarUrl, required this.status});
  final String name;
  final String? avatarUrl;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: Colors.white24,
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl!.trim()) : null,
          child: hasAvatar
              ? null
              : Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 40),
                ),
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          status,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}
