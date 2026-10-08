import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chat_app/core/theme/app_colors.dart';
import 'package:chat_app/features/calls/core/constants/call_strings.dart';
import 'package:chat_app/features/calls/core/models/call_type.dart';
import 'package:chat_app/features/calls/core/models/participant_status.dart';
import 'package:chat_app/features/calls/core/providers/joinable_group_call_provider.dart';
import 'package:chat_app/features/calls/core/widgets/group_call_join_button.dart';
import 'package:chat_app/features/calls/core/widgets/pulsing_dot.dart';
import 'package:chat_app/features/calls/core/models/group_call_session.dart';

class GroupCallJoinBanner extends ConsumerStatefulWidget {
  const GroupCallJoinBanner({super.key});
  @override
  ConsumerState<GroupCallJoinBanner> createState() => _BannerState();
}

class _BannerState extends ConsumerState<GroupCallJoinBanner> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Newest first; calls owned by a conversation tile are skipped.
    final calls = [
      for (final c
          in ref.watch(joinableGroupCallsProvider).value ??
              const <GroupCallSession>[])
        if (c.conversationId == null) c,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (calls.isEmpty) return const SizedBox.shrink();
    if (_index >= calls.length) _index = calls.length - 1;

    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.online.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.online.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _page,
            itemCount: calls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _row(context, calls[i]),
          ),
          if (calls.length > 1)
            Positioned(
              right: 8,
              top: 2,
              child: Text(
                '${_index + 1} of ${calls.length}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, GroupCallSession s) {
    final joined = s.statuses.values
        .where((v) => v == ParticipantStatus.joined)
        .length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const PulsingDot(color: AppColors.online),
          const SizedBox(width: 10),
          Icon(s.type == CallType.video ? Icons.videocam : Icons.ring_volume),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.type == CallType.video
                      ? CallStrings.liveGroupVideo
                      : CallStrings.liveGroupVoice,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${s.callerName ?? CallStrings.unknownCaller} · $joined in call',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          GroupCallJoinButton(session: s),
        ],
      ),
    );
  }
}
