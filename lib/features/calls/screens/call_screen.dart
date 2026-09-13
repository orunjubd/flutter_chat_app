import 'dart:async';

import 'package:chat_app/features/chat/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chat_app/features/calls/providers/call_provider.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key, required this.otherUserId});

  final String otherUserId;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  Timer? _callTimer;

  Duration _elapsed = Duration.zero;
  bool _isMicrophoneEnabled = true;
  bool _isEndingCall = false;

  @override
  void initState() {
    super.initState();

    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleMicrophone() async {
    final newState = !_isMicrophoneEnabled;

    setState(() {
      _isMicrophoneEnabled = newState;
    });

    await ref.read(callProvider.notifier).setMicrophoneEnabled(newState);
  }

  Future<void> _endCall() async {
    if (_isEndingCall) return;
    setState(() {
      _isEndingCall = true;
    });
    await ref.read(callProvider.notifier).endCurrentCall();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final otherUserAsync = ref.watch(userByIdProvider(widget.otherUserId));

    ref.listen<CallState>(callProvider, (previous, next) {
      if (next.status == CallConnectionStatus.ended &&
          previous?.status != CallConnectionStatus.ended) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Voice Call'), centerTitle: true),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              const CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 48),
              ),

              const SizedBox(height: 20),

              Text(
                otherUserAsync.when(
                  loading: () => 'Calling...',
                  error: (_, _) => 'Unknown User',
                  data: (user) => user?.username ?? 'Unknown User',
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 12),

              Text('Connected', style: Theme.of(context).textTheme.bodyLarge),

              const SizedBox(height: 8),

              Text(
                _formatDuration(_elapsed),
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CallControlButton(
                      icon: _isMicrophoneEnabled
                          ? Icons.mic_outlined
                          : Icons.mic_off_outlined,
                      label: _isMicrophoneEnabled ? 'Mute' : 'Unmute',
                      onPressed: _toggleMicrophone,
                    ),

                    const SizedBox(width: 24),

                    _CallControlButton(
                      icon: Icons.volume_up_outlined,
                      label: 'Speaker',
                      onPressed: () {},
                    ),

                    const SizedBox(width: 24),

                    _CallControlButton(
                      icon: Icons.call_end_outlined,
                      label: 'End',
                      onPressed: _isEndingCall ? null : _endCall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filled(onPressed: onPressed, icon: Icon(icon), iconSize: 28),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
