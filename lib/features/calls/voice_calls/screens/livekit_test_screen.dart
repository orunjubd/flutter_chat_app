import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/config/call_config.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart'; // callProvider
//import 'package:chat_app/features/calls/core/models/call_phase.dart'; // CallUiState
import 'package:chat_app/features/calls/core/models/call_state.dart'; // CallState

//import 'package:chat_app/features/calls/core/controllers/call_media_controller.dart';
class LiveKitTestScreen extends ConsumerWidget {
  const LiveKitTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Belt and braces alongside connectTestRoom()'s own kDebugMode guard
    // (8e) — this screen shouldn't even render its real content, let alone
    // let someone tap into a dev-only token path, outside a debug build.
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(child: Text('Not available in this build.')),
      );
    }
    final callState = ref.watch(callProvider);
    final notifier = ref.read(callProvider.notifier);

    final isConnected = callState.phase == CallState.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('LiveKit Foundation Test')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '4.9.1 LiveKit Foundation',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Room: ${CallConfig.testRoomName}',
            style: const TextStyle(fontSize: 15),
          ),

          const SizedBox(height: 24),

          _StatusCard(status: callState.phase),

          if (callState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  callState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: callState.phase == CallState.connecting
                ? null
                : () {
                    notifier.connectTestRoom();
                  },
            icon: const Icon(Icons.login),
            label: const Text('Connect to Test Room'),
          ),

          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: isConnected
                ? () {
                    notifier.setMicrophoneEnabled(true);
                  }
                : null,
            icon: const Icon(Icons.mic),
            label: const Text('Enable Microphone'),
          ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: isConnected
                ? () {
                    notifier.setMicrophoneEnabled(false);
                  }
                : null,
            icon: const Icon(Icons.mic_off),
            label: const Text('Disable Microphone'),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: isConnected
                ? () {
                    notifier.setCameraEnabled(true);
                  }
                : null,
            icon: const Icon(Icons.videocam),
            label: const Text('Enable Camera'),
          ),

          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: isConnected
                ? () {
                    notifier.setCameraEnabled(false);
                  }
                : null,
            icon: const Icon(Icons.videocam_off),
            label: const Text('Disable Camera'),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: isConnected
                ? () {
                    notifier.disconnect();
                  }
                : null,
            icon: const Icon(Icons.call_end),
            label: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final CallState status;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      CallState.idle => 'Idle',
      CallState.dialing => 'Dialing...',
      CallState.ringing => 'Ringing...',
      CallState.connecting => 'Connecting...',
      CallState.connected => 'Connected',
      CallState.reconnecting => 'Reconnecting...',
      CallState.failed => 'Failed',
      CallState.ended => 'Ended',
      CallState.rejected => 'Rejected',
      CallState.cancelled => 'Cancelled',
      CallState.missed => 'Missed',
    };
    final icon = switch (status) {
      CallState.idle => Icons.phone_disabled,
      CallState.dialing => Icons.phone_forwarded,
      CallState.ringing => Icons.phone_callback,
      CallState.connecting => Icons.sync,
      CallState.connected => Icons.phone_in_talk,
      CallState.reconnecting => Icons.sync_problem,
      CallState.failed => Icons.error_outline,
      CallState.ended => Icons.call_end,
      CallState.rejected => Icons.call_missed_outgoing,
      CallState.cancelled => Icons.cancel_outlined,
      CallState.missed => Icons.call_missed,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
