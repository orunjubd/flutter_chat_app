import 'package:chat_app/features/calls/screens/call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/calls/providers/call_provider.dart';
import 'package:chat_app/features/calls/widgets/incoming_voice_call_dialog.dart';

// class GlobalIncomingCallListener extends ConsumerStatefulWidget {
//   const GlobalIncomingCallListener({super.key, required this.child});

//   final Widget child;

//   @override
//   ConsumerState<GlobalIncomingCallListener> createState() =>
//       _GlobalIncomingCallListenerState();
// }

// class _GlobalIncomingCallListenerState
//     extends ConsumerState<GlobalIncomingCallListener> {
//   bool _listenerStarted = false;

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authStateProvider);
//     final callState = ref.watch(callProvider);

//     // Start the incoming-call listener only for an authenticated user.
//     authState.whenData((user) {
//       if (user != null && !_listenerStarted) {
//         _listenerStarted = true;

//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (!mounted) return;

//           ref.read(callProvider.notifier).listenForIncomingCalls();
//         });
//       }
//     });

//     final incomingCall = callState.incomingCall;
//     final shouldShowIncomingCall =
//         incomingCall != null && callState.status == CallConnectionStatus.idle;
//     return Stack(
//       children: [
//         widget.child,
//         if (shouldShowIncomingCall)
//           Positioned.fill(
//             child: IncomingVoiceCallDialog(incomingCall: incomingCall),
//           ),
//       ],

//     );
//   }
// }
// class GlobalIncomingCallListener extends ConsumerWidget {
//   const GlobalIncomingCallListener({super.key, required this.child});
//   final Widget child;

//   static const _busyStatuses = {
//     CallConnectionStatus.connecting,
//     CallConnectionStatus.connected,
//     CallConnectionStatus.ringing, // caller's own outgoing-ringing state
//   };

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final callState = ref.watch(callProvider);
//     final incomingCall = callState.incomingCall;

//     final shouldShowIncomingCall =
//         incomingCall != null && !_busyStatuses.contains(callState.status);

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

    // Single source of truth for "a call just became connected" —
    // covers BOTH the in-app dialog Accept and the background/
    // killed-app CallKit resume path. IncomingVoiceCallDialog no
    // longer navigates itself, to avoid double-navigation.
    ref.listen<CallState>(callProvider, (previous, next) {
      if (next.status == CallConnectionStatus.connected &&
          previous?.status != CallConnectionStatus.connected) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) =>
                CallScreen(otherUserId: next.incomingCall?.callerId ?? ''),
          ),
        );
      }

      if (next.status == CallConnectionStatus.connected &&
          previous?.status != CallConnectionStatus.connected &&
          previous?.incomingCall != null) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) =>
                CallScreen(otherUserId: previous!.incomingCall!.callerId),
          ),
        );
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
