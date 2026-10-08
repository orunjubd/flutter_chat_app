import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/group_voice_calls/screens/group_voice_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/navigation/app_navigator_key.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/group_video_calls/screens/group_video_call_screen.dart';

bool _scheduled = false;

class GlobalGroupCallListener extends ConsumerWidget {
  const GlobalGroupCallListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // =======================================================================
    // 📡 DYNAMIC CALL LIFECYCLE INTERCEPTOR ENGINE (REFACTORED HERE!)
    // =======================================================================
    ref.listen<GroupCallUiState>(groupCallProvider, (prev, next) {
      // Captures the precise transition instance when the group call transitions into active phases

      final started = next.phase.isBusy && !(prev?.phase.isBusy ?? false);
      if (!started || _scheduled) return;
      _scheduled = true;

      // Atomic UI polling router execution thread
      void tryPush(int attempt) {
        // Short-circuit immediately if either of the group call UI viewports are already mounted active

        if (GroupVideoCallScreen.instances + GroupVoiceCallScreen.instances >
            0) {
          _scheduled = false; // outgoing screen already open
          return;
        }
        final nav = appNavigatorKey.currentState;
        final resumed =
            WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
        // 🛑 RETRY MATRIX BRANCH: If application context state is sleeping/detached, delay and poll again!

        if (nav == null || !resumed) {
          if (attempt >= 40) {
            _scheduled = false;
            return;
          }
          // Delay for 500 milliseconds and trigger attempt calculation recursively

          Future.delayed(
            const Duration(milliseconds: 500),
            () => tryPush(attempt + 1),
          );
          return;
        }
        // Clean pipeline release flag reset prior to rendering navigation viewports

        _scheduled = false;
        // 🎯 ECE DUAL-MODE ROUTER: Checks database session type to open voice vs video screens dynamically

        final isVoice =
            ref.read(groupCallProvider).session?.type == CallType.voice;
        nav.push(
          MaterialPageRoute(
            settings: const RouteSettings(name: 'group_call_screen'),
            builder: (_) => isVoice
                ? const GroupVoiceCallScreen()
                : const GroupVideoCallScreen(),
          ),
        );
      }
      // Dispatches the presentation thread as a safe asynchronous microtask stack loop

      Future.microtask(() => tryPush(0));
    });
    return child;
  }
}
