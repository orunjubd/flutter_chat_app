import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
import 'package:chat_app/features/calls/core/utils/app_lifecycle_utils.dart';
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

bool _pushScheduled = false; // top-level in the file

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

      final justStartedRinging =
          next.phase == CallState.ringing &&
          next.incomingCall != null &&
          isAppInForeground; // same check the controller used

      if (!justAccepted && !justStartedRinging) return;

      final call = justAccepted ? previous!.incomingCall! : next.incomingCall!;

      if (_pushScheduled) return;
      _pushScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pushScheduled = false;
        if (CallScreen.instances > 0) return; // foreground card already open
        final navigator = appNavigatorKey.currentState;
        if (navigator == null) {
          debugPrint('❌ [GlobalIncomingCallListener] navigator is null');
          return;
        }
        debugPrint(
          '🎯 [GlobalIncomingCallListener] pushing CallScreen (instances=${CallScreen.instances})',
        );
        navigator.push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'call_screen'),
            builder: (_) => CallScreen(
              peerId: call.callerId,
              peerName: call.callerName ?? 'Unknown User',
              isOutgoing: false,
              type: call.type,
            ),
          ),
        );
      });
    });
    return child;
  }
}
