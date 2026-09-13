import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/config/call_config.dart';
import 'package:chat_app/features/calls/providers/call_provider.dart';

class LiveKitTestScreen extends ConsumerWidget {
  const LiveKitTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);
    final notifier = ref.read(callProvider.notifier);

    final isConnected = callState.status == CallConnectionStatus.connected;

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

          _StatusCard(status: callState.status),

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
            onPressed: callState.status == CallConnectionStatus.connecting
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

  final CallConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      CallConnectionStatus.idle => 'Idle',
      CallConnectionStatus.ringing => 'Ringing...',
      CallConnectionStatus.connecting => 'Connecting...',
      CallConnectionStatus.connected => 'Connected',
      CallConnectionStatus.failed => 'Failed',
      CallConnectionStatus.ended => 'Ended',
    };

    final icon = switch (status) {
      CallConnectionStatus.idle => Icons.phone_disabled,
      CallConnectionStatus.ringing => Icons.phone_callback,
      CallConnectionStatus.connecting => Icons.sync,
      CallConnectionStatus.connected => Icons.phone_in_talk,
      CallConnectionStatus.failed => Icons.error_outline,
      CallConnectionStatus.ended => Icons.call_end,
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
