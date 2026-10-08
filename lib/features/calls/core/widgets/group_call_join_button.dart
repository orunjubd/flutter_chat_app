import 'package:chat_app/features/calls/core/models/call_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/features/calls/core/constants/call_strings.dart';
import 'package:chat_app/features/calls/core/controllers/call_controller.dart';
import 'package:chat_app/features/calls/core/controllers/group_call_controller.dart';
import 'package:chat_app/features/calls/core/models/group_call_session.dart';

class GroupCallJoinButton extends ConsumerWidget {
  const GroupCallJoinButton({super.key, required this.session});
  final GroupCallSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCall =
        ref.watch(callProvider.select((s) => s.phase.isBusy)) ||
        ref.watch(groupCallProvider.select((s) => s.phase.isBusy));
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.online,
        minimumSize: const Size(64, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      onPressed: inCall
          ? null
          : () => ref.read(groupCallProvider.notifier).joinActive(session),
      child: const Text(CallStrings.join),
    );
  }
}
