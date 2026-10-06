import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/navigation/app_navigator_key.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/group_video_calls/screens/group_video_call_screen.dart';

class GlobalGroupCallListener extends ConsumerWidget {
  const GlobalGroupCallListener({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<GroupCallUiState>(groupCallProvider, (prev, next) {
      final becameIncoming =
          next.phase == GroupCallPhase.incoming &&
          prev?.phase != GroupCallPhase.incoming;
      if (!becameIncoming || GroupVideoCallScreen.instances > 0) return;
      appNavigatorKey.currentState?.push(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'group_call_screen'),
          builder: (_) => const GroupVideoCallScreen(),
        ),
      );
    });
    return child;
  }
}
