//import 'dart:async';

//import 'package:chat_app/features/calls/core/services/call_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/calls/providers/call_provider.dart';
import 'package:chat_app/features/calls/widgets/incoming_voice_call_dialog.dart';
import 'package:chat_app/features/calls/screens/call_screen.dart';
import 'package:chat_app/core/navigation/app_navigator_key.dart';

class GlobalIncomingCallListener extends ConsumerWidget {
  const GlobalIncomingCallListener({super.key, required this.child});

  final Widget child;

  static const _busyStatuses = {
    CallConnectionStatus.connecting,
    CallConnectionStatus.connected,
    CallConnectionStatus.ringing,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callProvider);
    final incomingCall = callState.incomingCall;

    debugPrint(
      '👀 [GlobalIncomingCallListener.build] status=${callState.status}, incomingCall=$incomingCall',
    );
    ref.listen<CallState>(callProvider, (previous, next) {
      //final callAudio = ref.read(callAudioServiceProvider);

      debugPrint(
        '🔔 [GlobalIncomingCallListener.listen] '
        'previous=${previous?.status} → next=${next.status}',
      );

      debugPrint(
        '🔔 [GlobalIncomingCallListener.listen] '
        'next.incomingCall=${next.incomingCall}',
      );

      // ============================================================
      // 1. INCOMING CALL → START RINGTONE
      // ============================================================
      if (next.incomingCall != null &&
          next.status == CallConnectionStatus.ringing &&
          (previous?.incomingCall == null ||
              previous?.status != CallConnectionStatus.ringing)) {
        debugPrint(
          '🔔 [GlobalIncomingCallListener] '
          'Incoming call detected → starting ringtone',
        );

        //unawaited(callAudio.playRingtone());
      }

      // ============================================================
      // 2. INCOMING CALL → ACCEPTED / CONNECTED
      // ============================================================
      if (next.status == CallConnectionStatus.connected &&
          previous?.status != CallConnectionStatus.connected) {
        debugPrint(
          '🔇 [GlobalIncomingCallListener] '
          'Call connected → stopping ringtone',
        );

        //unawaited(callAudio.stop());

        if (next.incomingCall != null) {
          final callerId = next.incomingCall!.callerId;

          debugPrint(
            '🎯 [GlobalIncomingCallListener] '
            'Navigating to CallScreen for $callerId',
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navigator = appNavigatorKey.currentState;

            if (navigator != null) {
              navigator.push(
                MaterialPageRoute(
                  builder: (_) => CallScreen(otherUserId: callerId),
                ),
              );
            } else {
              debugPrint(
                '❌ [GlobalIncomingCallListener] '
                'appNavigatorKey.currentState is null',
              );
            }
          });
        }
      }

      // ============================================================
      // 3. INCOMING CALL → REJECTED / ENDED / FAILED
      // ============================================================
      if (next.status == CallConnectionStatus.ended ||
          next.status == CallConnectionStatus.failed) {
        //next.status == CallConnectionStatus.rejected ||
        //next.status == CallConnectionStatus.cancelled ||
        //next.status == CallConnectionStatus.missed

        debugPrint(
          '🔇 [GlobalIncomingCallListener] '
          'Call became terminal → stopping ringtone',
        );

        //unawaited(callAudio.stop());
      }
    });

    final shouldShowIncomingCall =
        incomingCall != null && !_busyStatuses.contains(callState.status);

    return Stack(
      children: [
        child,
        if (shouldShowIncomingCall)
          Positioned.fill(
            child: IncomingVoiceCallDialog(incomingCall: incomingCall),
          ),
      ],
    );
  }
}
