import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:chat_app/features/authentication/providers/auth_provider.dart';
import 'package:chat_app/features/calls/providers/call_provider.dart';
import 'package:chat_app/features/calls/widgets/incoming_voice_call_dialog.dart';
import 'package:chat_app/features/calls/screens/call_screen.dart';
import 'package:chat_app/core/navigation/app_navigator_key.dart';
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

// ============================================================================
// class GlobalIncomingCallListener extends ConsumerStatefulWidget {
//   const GlobalIncomingCallListener({super.key, required this.child});

//   final Widget child;

//   @override
//   ConsumerState<GlobalIncomingCallListener> createState() =>
//       _GlobalIncomingCallListenerState();
// }

// class _GlobalIncomingCallListenerState
//     extends ConsumerState<GlobalIncomingCallListener> {
//   static const _busyStatuses = {
//     CallConnectionStatus.connecting,
//     CallConnectionStatus.connected,
//     CallConnectionStatus.ringing,
//   };

//   bool _navigationScheduled = false;
//   ProviderSubscription<CallState>? _callSub;

//   @override
//   void initState() {
//     super.initState();

//     _callSub = ref.listenManual<CallState>(callProvider, (previous, next) {
//       final justConnected =
//           previous?.status != CallConnectionStatus.connected &&
//           next.status == CallConnectionStatus.connected;

//       if (justConnected && next.incomingCall != null && !_navigationScheduled) {
//         _navigationScheduled = true;

//         final callerId = next.incomingCall!.callerId;

//         debugPrint(
//           '🎯 [GlobalIncomingCallListener] Navigating to CallScreen for caller=$callerId',
//         );

//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (!mounted) return;

//           Navigator.of(context, rootNavigator: true).push(
//             MaterialPageRoute(
//               builder: (_) => CallScreen(otherUserId: callerId),
//             ),
//           );
//         });
//       }

//       if (next.status == CallConnectionStatus.ended ||
//           next.status == CallConnectionStatus.failed) {
//         _navigationScheduled = false;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _callSub?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final callState = ref.watch(callProvider);
//     final incomingCall = callState.incomingCall;

//     final shouldShowIncomingCall =
//         incomingCall != null && !_busyStatuses.contains(callState.status);

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

//=================================================================
// class GlobalIncomingCallListener extends ConsumerWidget {
//   const GlobalIncomingCallListener({super.key, required this.child});

//   final Widget child;

//   static const _busyStatuses = {
//     CallConnectionStatus.connecting,
//     CallConnectionStatus.connected,
//     CallConnectionStatus.ringing,
//   };

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final callState = ref.watch(callProvider);
//     final incomingCall = callState.incomingCall;

//     // ref.listen must be called directly here — Riverpod asserts it
//     // can only run inside a ConsumerWidget's own build(), not from a
//     // nested Builder/closure. Navigation uses appNavigatorKey instead
//     // of `context`, since THIS widget's context sits above
//     // MaterialApp's own Navigator (it's literally what gets passed
//     // into MaterialApp.builder) and can't push routes into it.
//     ref.listen<CallState>(callProvider, (previous, next) {
//       if (next.status == CallConnectionStatus.connected &&
//           previous?.status != CallConnectionStatus.connected &&
//           previous?.incomingCall != null) {
//         appNavigatorKey.currentState?.push(
//           MaterialPageRoute(
//             builder: (_) =>
//                 CallScreen(otherUserId: previous!.incomingCall!.callerId),
//           ),
//         );
//       }

//       if (next.status == CallConnectionStatus.ended &&
//           previous?.status != CallConnectionStatus.ended) {
//         final navigator = appNavigatorKey.currentState;
//         if (navigator != null && navigator.canPop()) {
//           navigator.popUntil((route) => route.isFirst);
//         }
//       }
//     });

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
//============================================
// class GlobalIncomingCallListener extends ConsumerWidget {
//   const GlobalIncomingCallListener({super.key, required this.child});

//   final Widget child;

//   static const _busyStatuses = {
//     CallConnectionStatus.connecting,
//     CallConnectionStatus.connected,
//     CallConnectionStatus.ringing,
//   };

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final callState = ref.watch(callProvider);
//     final incomingCall = callState.incomingCall;

//     ref.listen<CallState>(callProvider, (previous, next) {
//       final justConnected =
//           previous?.status != CallConnectionStatus.connected &&
//           next.status == CallConnectionStatus.connected;

//       if (justConnected && next.incomingCall != null) {
//         final callerId = next.incomingCall!.callerId;

//         debugPrint(
//           '🎯 [GlobalIncomingCallListener] connected -> opening CallScreen for $callerId',
//         );

//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           final navigator = appNavigatorKey.currentState;
//           if (navigator == null) {
//             debugPrint(
//               '❌ [GlobalIncomingCallListener] appNavigatorKey.currentState is null',
//             );
//             return;
//           }

//           navigator.push(
//             MaterialPageRoute(
//               builder: (_) => CallScreen(otherUserId: callerId),
//             ),
//           );
//         });
//       }

//       final becameTerminal =
//           next.status == CallConnectionStatus.ended ||
//           next.status == CallConnectionStatus.failed; // ||
//       // next.status == CallConnectionStatus.cancelled;

//       if (becameTerminal && previous?.status != next.status) {
//         final navigator = appNavigatorKey.currentState;
//         if (navigator != null && navigator.canPop()) {
//           debugPrint(
//             '🧹 [GlobalIncomingCallListener] terminal state -> popping current route if possible',
//           );
//           navigator.popUntil((route) => route.isFirst);
//         }
//       }
//     });

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

//==============================================================================
// --- OLD COLD CODE
// class GlobalIncomingCallListener extends ConsumerWidget {
//   const GlobalIncomingCallListener({super.key, required this.child});

//   final Widget child;

//   static const _busyStatuses = {
//     CallConnectionStatus.connecting,
//     CallConnectionStatus.connected,
//     CallConnectionStatus.ringing,
//   };

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final callState = ref.watch(callProvider);
//     final incomingCall = callState.incomingCall;

//     // Single source of truth for "a call just became connected" —
//     // covers BOTH the in-app dialog Accept and the background/
//     // killed-app CallKit resume path. IncomingVoiceCallDialog no
//     // longer navigates itself, to avoid double-navigation.
//     ref.listen<CallState>(callProvider, (previous, next) {
//       if (next.status == CallConnectionStatus.connected &&
//           previous?.status != CallConnectionStatus.connected) {
//         Navigator.of(context, rootNavigator: true).push(
//           MaterialPageRoute(
//             builder: (_) =>
//                 CallScreen(otherUserId: next.incomingCall?.callerId ?? ''),
//           ),
//         );
//       }

//       if (next.status == CallConnectionStatus.connected &&
//           previous?.status != CallConnectionStatus.connected &&
//           previous?.incomingCall != null) {
//         Navigator.of(context, rootNavigator: true).push(
//           MaterialPageRoute(
//             builder: (_) =>
//                 CallScreen(otherUserId: previous!.incomingCall!.callerId),
//           ),
//         );
//       }
//     });

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

// ================================================================

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
      debugPrint(
        '🔔 [GlobalIncomingCallListener.listen] previous=${previous?.status} → next=${next.status}',
      );
      debugPrint(
        '🔔 [GlobalIncomingCallListener.listen] next.incomingCall=${next.incomingCall}',
      );
      // Transition to connected with an incoming call
      if (next.status == CallConnectionStatus.connected &&
          previous?.status != CallConnectionStatus.connected &&
          next.incomingCall != null) {
        final callerId = next.incomingCall!.callerId;

        debugPrint(
          '🎯 [GlobalIncomingCallListener] Navigating to CallScreen for $callerId',
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
              '❌ [GlobalIncomingCallListener] appNavigatorKey.currentState is null',
            );
          }
        });
      } else {
        debugPrint(
          '⚠️ [GlobalIncomingCallListener] Condition NOT met: '
          'connected=${next.status == CallConnectionStatus.connected}, '
          'statusChanged=${previous?.status != CallConnectionStatus.connected}, '
          'hasIncomingCall=${next.incomingCall != null}',
        );
      }

      // Pop on terminal states
      // if (
      //   (next.status == CallConnectionStatus.ended || next.status == CallConnectionStatus.failed) &&
      //     previous?.status != next.status) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     final navigator = appNavigatorKey.currentState;
      //     if (navigator != null && navigator.canPop()) {
      //       debugPrint(
      //         '🧹 [GlobalIncomingCallListener] Popping on terminal state',
      //       );
      //       navigator.pop();
      //     }
      //   });
      // }
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
