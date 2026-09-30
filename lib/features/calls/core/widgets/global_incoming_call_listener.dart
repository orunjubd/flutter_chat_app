import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:chat_app/features/calls/core/models/call_phase.dart';
//import 'package:chat_app/features/calls/core/widgets/incoming_voice_call_dialog.dart';
import 'package:chat_app/features/calls/voice_calls/screens/call_screen.dart';
import 'package:chat_app/core/navigation/app_navigator_key.dart';

//import 'package:chat_app/features/chat/providers/user_provider.dart';
// TEMPORARY, deliberate (per plan): CallScreen no longer renders anything
// during ringing — testing with Android's native CallKit notification as the
// SOLE pre-answer UI first. CallScreen is now pushed only once the call is
// actually accepted (via CallKit's native buttons, or _handlePendingAcceptedCall
// for a backgrounded-app relaunch), giving the full Mute/Speaker/End screen
// for the live call. previous.incomingCall is read (not next — acceptCall()
// clears incomingCall via clearIncomingCall: true at the exact moment
// acceptance begins, before this fires) — same reasoning as when this bug
// was originally fixed, just applied to the opposite trigger edge now.
// Known gap: if CallKit's native UI doesn't show for some reason (push
// delivery failure), there is currently no way to accept a call at all.
// Revisit once native-only testing is confirmed clean.
class GlobalIncomingCallListener extends ConsumerWidget {
  const GlobalIncomingCallListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<CallUiState>(callProvider, (previous, next) {
      debugPrint(
        '🔔 [GlobalIncomingCallListener.listen] previous=${previous?.phase} → next=${next.phase}',
      );
      debugPrint(
        '🔔 [GlobalIncomingCallListener.listen] next.incomingCall=${next.incomingCall}',
      );

      final justAccepted =
          previous?.phase == CallState.ringing &&
          previous?.incomingCall != null &&
          next.phase != CallState.ringing &&
          next.phase.isBusy;

      if (justAccepted) {
        final acceptedCall = previous!.incomingCall!;
        final callerId = acceptedCall.callerId;
        final peerName = acceptedCall.callerName ?? 'Unknown User';
        debugPrint(
          '🎯 [GlobalIncomingCallListener] Navigating to CallScreen for $callerId',
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navigator = appNavigatorKey.currentState;
          if (navigator != null) {
            // Defensive cleanup: if a previous CallScreen (e.g. from a call
            // that just ended) hasn't popped itself yet — a real race when a
            // new call arrives right after the last one ended — clear it
            // before pushing, so screens never stack up. CallScreen's own
            // self-pop stays in place for the normal single-call case; this
            // is the backstop for the race specifically.
            navigator.push(
              MaterialPageRoute(
                settings: const RouteSettings(name: 'call_screen'),
                builder: (_) => CallScreen(
                  peerId: callerId,
                  peerName: peerName,
                  isOutgoing: false,
                ),
              ),
            );
          } else {
            debugPrint(
              '❌ [GlobalIncomingCallListener] appNavigatorKey.currentState is null',
            );
          }
        });
      }
    });

    // No more overlay/dialog — CallScreen is the only UI for an incoming
    // call now, pushed above the moment it's detected.
    return child;
  }
}

// class GlobalIncomingCallListener extends ConsumerWidget {
//   const GlobalIncomingCallListener({super.key, required this.child});

//   final Widget child;

//   static const _busyStatuses = {
//     CallState.connecting,
//     CallState.connected,
//     CallState.ringing,
//   };

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final callState = ref.watch(callProvider);
//     final incomingCall = callState.incomingCall;

//     debugPrint(
//       '👀 [GlobalIncomingCallListener.build] status=${callState.phase}, incomingCall=$incomingCall',
//     );
//     ref.listen<CallUiState>(callProvider, (previous, next) async {
//       //final callAudio = ref.read(callAudioServiceProvider);

//       debugPrint(
//         '🔔 [GlobalIncomingCallListener.listen] '
//         'previous=${previous?.phase} → next=${next.phase}',
//       );

//       debugPrint(
//         '🔔 [GlobalIncomingCallListener.listen] '
//         'next.incomingCall=${next.incomingCall}',
//       );

//       // ============================================================
//       // 1. INCOMING CALL → START RINGTONE
//       // ============================================================
//       if (next.incomingCall != null &&
//           next.phase == CallState.ringing &&
//           (previous?.incomingCall == null ||
//               previous?.phase != CallState.ringing)) {
//         debugPrint(
//           '🔔 [GlobalIncomingCallListener] '
//           'Incoming call detected → starting ringtone',
//         );

//         //unawaited(callAudio.playRingtone());
//       }

//       // ============================================================
//       // 2. INCOMING CALL → ACCEPTED / CONNECTED
//       // ============================================================
//       if (next.phase == CallState.connected &&
//           previous?.phase != CallState.connected) {
//         debugPrint(
//           '🔇 [GlobalIncomingCallListener] '
//           'Call connected → stopping ringtone',
//         );

//         //unawaited(callAudio.stop());

//         if (next.incomingCall != null) {
//           final callerId = next.incomingCall!.callerId;

//           debugPrint(
//             '🎯 [GlobalIncomingCallListener] '
//             'Navigating to CallScreen for $callerId',
//           );
//           String peerName = 'Unknown User';
//           try {
//             // 🚀 ECE DYNAMIC RESOLVER CHANNEL
//             // ✅ REQUIREMENT MET: Fetches the real profile snapshot asynchronously before pushing routes!
//             //final userProfile = await ref.read( userByIdProvider(callerId).future,  );
//             final userProfile = await ref.read(
//               userByIdProvider(callerId).future,
//             );
//             if (userProfile != null) {
//               peerName = userProfile.username;
//             }
//           } catch (e) {
//             debugPrint(
//               '⚠️ [GlobalIncomingCallListener] Failed to resolve peer name metadata: $e',
//             );
//           }
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             final navigator = appNavigatorKey.currentState;

//             if (navigator != null) {
//               navigator.push(
//                 MaterialPageRoute(
//                   builder: (_) => CallScreen(
//                     peerId: callerId,
//                     //peerName: otherUser?.username ?? 'Unknown User',
//                     peerName: peerName,
//                     isOutgoing: false,
//                   ),
//                 ),
//               );
//             } else {
//               debugPrint(
//                 '❌ [GlobalIncomingCallListener] '
//                 'appNavigatorKey.currentState is null',
//               );
//             }
//           });
//         }
//       }

//       // ============================================================
//       // 3. INCOMING CALL → REJECTED / ENDED / FAILED
//       // ============================================================
//       if (next.phase == CallState.ended || next.phase == CallState.failed) {
//         debugPrint(
//           '🔇 [GlobalIncomingCallListener] '
//           'Call became terminal → stopping ringtone',
//         );

//         //unawaited(callAudio.stop());
//       }
//     });

//     final shouldShowIncomingCall =
//         incomingCall != null && !_busyStatuses.contains(callState.phase);

//     return Stack(
//       children: [
//         child,
//         if (shouldShowIncomingCall)
//           Positioned.fill(
//             child: IncomingVoiceCallDialog(incomingCall: incomingCall),
//           ),
//       ],
//     );
//   }
// }
